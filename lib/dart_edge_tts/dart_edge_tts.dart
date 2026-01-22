import 'package:chinese_poems/dart_edge_tts/communicate.dart';
import 'package:chinese_poems/dart_edge_tts/constants.dart';
import 'package:chinese_poems/dart_edge_tts/drm.dart';
import 'package:chinese_poems/dart_edge_tts/voices.dart';

int calculate() {
  return 6 * 7;
}

void main() {
  //print('Hello, Dart Edge TTS!');
  // final c = Communicate(text: 'hello');
  // c.save('hello.mp3');
  // testSound();
  // final secMsGec = DRM.generateSecMsGec();
  // print('Sec-MS-GEC: $secMsGec');
  final headers = DRM.headersWithMuid(wssHeaders);
  print('WebSocket Headers with DRM: $headers');
}

void testSound() {
  final communicator = Communicate(
    text: 'Hello, this is a test of the Dart Edge TTS package.',
    voice: 'en-US-EmmaMultilingualNeural',
  );

  communicator.save('test_output.mp3').then((_) {
    print('Audio saved to test_output.mp3');
  }).catchError((error) {
    print('Error generating audio: $error');
  });
}

void testVoice() {
  listVoices().then((voices) {
    if (voices != null) {
      for (var voice in voices) {
        print('Voice: ${voice.name}, Language: ${voice.locale}');
      }
    } else {
      print('No voices found.');
    }
  }).catchError((error) {
    print('Error fetching voices: $error');
  });
}
