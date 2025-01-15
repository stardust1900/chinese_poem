import 'package:meta/meta.dart';
import 'dart:core';

import 'package:args/args.dart';

// 定义 TTSConfig 数据类
@immutable
class TTSConfig {
  final String voice;
  final String rate;
  final String volume;
  final String pitch;

  // 静态方法用于验证字符串参数
  static String validateStringParam(
      String paramName, String paramValue, String pattern) {
    if (!RegExp(pattern).hasMatch(paramValue)) {
      throw FormatException('Invalid $paramName: $paramValue');
    }
    return paramValue;
  }

  // 构造函数并进行初始化后的验证
  TTSConfig({
    required String inputVoice,
    required this.rate,
    required this.volume,
    required this.pitch,
  }) : voice = _formatVoice(inputVoice) {
    // 验证 rate, volume, pitch 参数
    validateStringParam('rate', rate, r"^[+-]\d+%$");
    validateStringParam('volume', volume, r"^[+-]\d+%$");
    validateStringParam('pitch', pitch, r"^[+-]\d+Hz$");
  }

  // 辅助方法用于格式化 voice
  static String _formatVoice(String inputVoice) {
    // 验证 voice 格式
    final match =
        RegExp(r"^([a-z]{2,})-([A-Z]{2,})-(.+Neural)$").firstMatch(inputVoice);
    if (match != null) {
      final lang = match.group(1)!;
      var region = match.group(2)!;
      var name = match.group(3)!;
      if (name.contains('-')) {
        final parts = name.split('-');
        region = '$region-${parts[0]}';
        name = parts.sublist(1).join('-');
      }
      return "Microsoft Server Speech Text to Speech Voice ($lang-$region, $name)";
    } else {
      // 如果输入的 voice 不符合预期格式，直接返回原值
      return inputVoice;
    }
  }

// 验证 TTS 设置（可以根据需要添加更多验证逻辑）
  factory TTSConfig.validate(
      String voice, String rate, String volume, String pitch) {
    if (voice.isEmpty) {
      throw ArgumentError("voice cannot be empty");
    }
    return TTSConfig(
        inputVoice: voice, rate: rate, volume: volume, pitch: pitch);
  }

  @override
  String toString() {
    return 'TTSConfig{voice: $voice, rate: $rate, volume: $volume, pitch: $pitch}';
  }
}

// 定义 UtilArgs 类
class UtilArgs {
  final String text;
  final String file;
  final String voice;
  final bool listVoices;
  final String rate;
  final String volume;
  final String pitch;
  final int wordsInCue;
  final String writeMedia;
  final String writeSubtitles;
  final String proxy;

  UtilArgs({
    required this.text,
    required this.file,
    required this.voice,
    required this.listVoices,
    required this.rate,
    required this.volume,
    required this.pitch,
    required this.wordsInCue,
    required this.writeMedia,
    required this.writeSubtitles,
    required this.proxy,
  });

  // 工厂方法用于从 ArgResults 创建 UtilArgs 实例
  factory UtilArgs.fromArgResults(ArgResults results) {
    return UtilArgs(
      text: results['text'] as String? ?? '',
      file: results['file'] as String? ?? '',
      voice: results['voice'] as String? ?? '',
      listVoices: results['list-voices'] as bool? ?? false,
      rate: results['rate'] as String? ?? '+0%',
      volume: results['volume'] as String? ?? '+0%',
      pitch: results['pitch'] as String? ?? '+0Hz',
      wordsInCue: results['words-in-cue'] as int? ?? 0,
      writeMedia: results['write-media'] as String? ?? '',
      writeSubtitles: results['write-subtitles'] as String? ?? '',
      proxy: results['proxy'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return '''
    UtilArgs{
      text: $text,
      file: $file,
      voice: $voice,
      listVoices: $listVoices,
      rate: $rate,
      volume: $volume,
      pitch: $pitch,
      wordsInCue: $wordsInCue,
      writeMedia: $writeMedia,
      writeSubtitles: $writeSubtitles,
      proxy: $proxy
    }
    ''';
  }
}

// 定义命令行解析器
void parseCommandLine(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('text', help: 'Text to synthesize')
    ..addOption('file', help: 'File containing the text to synthesize')
    ..addOption('voice', help: 'Voice to use for synthesis')
    ..addFlag('list-voices', help: 'List available voices', negatable: false)
    ..addOption('rate', help: 'Speech rate (e.g., +10%)', defaultsTo: '+0%')
    ..addOption('volume', help: 'Speech volume (e.g., +10%)', defaultsTo: '+0%')
    ..addOption('pitch', help: 'Speech pitch (e.g., +10Hz)', defaultsTo: '+0Hz')
    ..addOption('words-in-cue',
        help: 'Number of words in each cue', defaultsTo: '0')
    ..addOption('write-media', help: 'Path to write the media file')
    ..addOption('write-subtitles', help: 'Path to write the subtitles file')
    ..addOption('proxy', help: 'Proxy server to use');

  final results = parser.parse(arguments);

  // 创建 UtilArgs 实例
  final utilArgs = UtilArgs.fromArgResults(results);

  // 打印解析后的参数
  print(utilArgs);
}
