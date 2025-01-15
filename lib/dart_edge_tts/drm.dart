import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

import 'constants.dart'; // 假设 constants.dart 文件中定义了 TRUSTED_CLIENT_TOKEN
import 'exceptions.dart'; // 假设 exceptions.dart 文件中定义了 SkewAdjustmentError

const int WIN_EPOCH = 11644473600;
const double S_TO_NS = 1e9;

class DRM {
  static double clockSkewSeconds = 0.0;

  /// Adjust the clock skew in seconds in case the system clock is off.
  ///
  /// This method updates the `clockSkewSeconds` attribute of the DRM class
  /// to the specified number of seconds.
  ///
  /// Args:
  ///   skewSeconds (double): The number of seconds to adjust the clock skew to.
  static void adjClockSkewSeconds(double skewSeconds) {
    DRM.clockSkewSeconds += skewSeconds;
  }

  /// Gets the current timestamp in Unix format with clock skew correction.
  ///
  /// Returns:
  ///   double: The current timestamp in Unix format with clock skew correction.
  static double getUnixTimestamp() {
    return DateTime.now().toUtc().microsecondsSinceEpoch / 1000000 +
        DRM.clockSkewSeconds;
  }

  /// Parses an RFC 2616 date string into a Unix timestamp.
  ///
  /// Args:
  ///   date (String): RFC 2616 date string to parse.
  ///
  /// Returns:
  ///   double?: Unix timestamp of the parsed date string, or null if parsing failed.
  static double? parseRfc2616Date(String date) {
    try {
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      final parsedDate = format.parse(date).toUtc();
      return parsedDate.millisecondsSinceEpoch / 1000;
    } catch (e) {
      return null;
    }
  }

  /// Handle a client response error.
  ///
  /// This method adjusts the clock skew based on the server date in the response headers
  /// and raises a SkewAdjustmentError if the server date is missing or invalid.
  ///
  /// Args:
  ///   e (Exception): The client response error to handle.
  static Future<void> handleClientResponseError(http.Response response) async {
    if (!response.headers.containsKey('date')) {
      throw SkewAdjustmentError("No server date in headers.");
    }
    final serverDate = response.headers['date'];
    if (serverDate == null) {
      throw SkewAdjustmentError("No server date in headers.");
    }
    final serverDateParsed = DRM.parseRfc2616Date(serverDate);
    if (serverDateParsed == null) {
      throw SkewAdjustmentError("Failed to parse server date: $serverDate");
    }
    final clientDate = DRM.getUnixTimestamp();
    DRM.adjClockSkewSeconds(serverDateParsed - clientDate);
  }

  /// Generates the Sec-MS-GEC token value.
  ///
  /// This function generates a token value based on the current time in Windows file time format
  /// adjusted for clock skew, and rounded down to the nearest 5 minutes. The token is then hashed
  /// using SHA256 and returned as an uppercased hex digest.
  ///
  /// Returns:
  ///   String: The generated Sec-MS-GEC token value.
  static String generateSecMsGec() {
    // Get the current timestamp in Unix format with clock skew correction
    double ticks = DRM.getUnixTimestamp();
    // Switch to Windows file time epoch (1601-01-01 00:00:00 UTC)
    ticks += WIN_EPOCH;
    // Round down to the nearest 5 minutes (300 seconds)
    ticks = ticks - (ticks % 300);
    // Convert the ticks to 100-nanosecond intervals (Windows file time format)
    ticks *= S_TO_NS / 100;
    // Create the string to hash by concatenating the ticks and the trusted client token
    String strToHash = "${ticks.toInt()}$trustedClientToken";
    // Compute the SHA256 hash and return the uppercased hex digest
    final bytes = utf8.encode(strToHash);
    final digest = sha256.convert(bytes);
    return digest.toString().toUpperCase();
  }
}

void main(List<String> args) {
  DRM.generateSecMsGec();
}
