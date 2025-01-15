// Custom exceptions for the edge-tts package.

/// Base exception for the edge-tts package.
class EdgeTTSException implements Exception {
  final String message;

  EdgeTTSException([this.message = ""]);

  @override
  String toString() {
    if (message.isEmpty) {
      return runtimeType.toString();
    } else {
      return '$runtimeType: $message';
    }
  }
}

/// Raised when an unknown response is received from the server.
class UnknownResponse extends EdgeTTSException {
  UnknownResponse(
      [String message = "Unknown response received from the server."])
      : super(message);
}

/// Raised when an unexpected response is received from the server.
///
/// This hasn't happened yet, but it's possible that the server will
/// change its response format in the future.
class UnexpectedResponse extends EdgeTTSException {
  UnexpectedResponse(
      [String message = "Unexpected response received from the server."])
      : super(message);
}

/// Raised when no audio is received from the server.
class NoAudioReceived extends EdgeTTSException {
  NoAudioReceived([String message = "No audio received from the server."])
      : super(message);
}

/// Raised when a WebSocket error occurs.
class WebSocketError extends EdgeTTSException {
  WebSocketError([String message = "WebSocket error occurred."])
      : super(message);
}

/// Raised when an error occurs while adjusting the clock skew.
class SkewAdjustmentError extends EdgeTTSException {
  SkewAdjustmentError(
      [String message = "Error occurred while adjusting the clock skew."])
      : super(message);
}
