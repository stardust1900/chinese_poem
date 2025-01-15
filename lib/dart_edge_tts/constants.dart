// Constants for the edge_tts package in Dart

const String baseUrl =
    "speech.platform.bing.com/consumer/speech/synthesize/readaloud";
const String trustedClientToken = "6A5AA1D4EAFF4E9FB37E23D68491D6F4";

final String wssUrl =
    "wss://$baseUrl/edge/v1?TrustedClientToken=$trustedClientToken";
final String voiceListUrl =
    "https://$baseUrl/voices/list?trustedclienttoken=$trustedClientToken";

const String defaultVoice = "en-US-EmmaMultilingualNeural";

const String chromiumFullVersion = "130.0.2849.68";
final String chromiumMajorVersion = chromiumFullVersion.split('.')[0];
const String secMsGecVersion = "1-$chromiumFullVersion";

// Base headers
final Map<String, String> baseHeaders = {
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
      " (KHTML, like Gecko) Chrome/$chromiumMajorVersion.0.0.0 Safari/537.36"
      " Edg/$chromiumMajorVersion.0.0.0",
  "Accept-Encoding": "gzip, deflate, br",
  "Accept-Language": "en-US,en;q=0.9",
};

// WSS headers
final Map<String, String> wssHeaders = {
  ...baseHeaders,
  "Pragma": "no-cache",
  "Cache-Control": "no-cache",
  "Origin": "chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold",
};

// Voice headers
final Map<String, String> voiceHeaders = {
  ...baseHeaders,
  "Authority": "speech.platform.bing.com",
  "Sec-CH-UA":
      '" Not;A Brand";v="99", "Microsoft Edge";v="$chromiumMajorVersion",'
          ' "Chromium";v="$chromiumMajorVersion"',
  "Sec-CH-UA-Mobile": "?0",
  "Accept": "*/*",
  "Sec-Fetch-Site": "none",
  "Sec-Fetch-Mode": "cors",
  "Sec-Fetch-Dest": "empty",
};
