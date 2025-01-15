import 'package:intl/intl.dart';
import 'dart:core';

import 'typing.dart';

// 定义 TTSChunk 类
// class TTSChunk {
//   final String type;
//   final int offset;
//   final int duration;
//   final String text;

//   TTSChunk({
//     required this.type,
//     required this.offset,
//     required this.duration,
//     required this.text,
//   });

//   factory TTSChunk.fromJson(Map<String, dynamic> json) {
//     return TTSChunk(
//       type: json['type'],
//       offset: json['offset'],
//       duration: json['duration'],
//       text: json['text'],
//     );
//   }
// }

// 定义 Subtitle 类
class Subtitle {
  final int index;
  final Duration start;
  final Duration end;
  final String content;

  Subtitle({
    required this.index,
    required this.start,
    required this.end,
    required this.content,
  });

  @override
  String toString() {
    return '${_formatTime(start)} --> ${_formatTime(end)}\n$content\n';
  }

  // 辅助方法用于格式化时间
  static String _formatTime(Duration time) {
    final hours = time.inHours.toString().padLeft(2, '0');
    final minutes = (time.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds =
        (time.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$milliseconds';
  }
}

class SubMaker {
  List<Subtitle> cues = [];

  void feed(TTSChunk msg) {
    if (msg.type != "WordBoundary") {
      throw ArgumentError("Invalid message type, expected 'WordBoundary'");
    }

    cues.add(
      Subtitle(
        index: cues.length + 1,
        start: Duration(microseconds: msg.offset ~/ 10),
        end: Duration(microseconds: (msg.offset + msg.duration) ~/ 10),
        content: msg.text,
      ),
    );
  }

  void mergeCues(int words) {
    if (words <= 0) {
      throw ArgumentError("Invalid number of words to merge, expected > 0");
    }

    if (cues.isEmpty) {
      return;
    }

    List<Subtitle> newCues = [];
    Subtitle currentCue = cues[0];

    for (var cue in cues.skip(1)) {
      if (currentCue.content.split(' ').length < words) {
        currentCue = Subtitle(
          index: currentCue.index,
          start: currentCue.start,
          end: cue.end,
          content: '${currentCue.content} ${cue.content}',
        );
      } else {
        newCues.add(currentCue);
        currentCue = cue;
      }
    }

    newCues.add(currentCue);
    cues = newCues;
  }

  String get srt {
    final buffer = StringBuffer();
    for (var cue in cues) {
      buffer.write('${cue.index}\n${cue}\n\n');
    }
    return buffer.toString().trim();
  }

  @override
  String toString() {
    return srt;
  }
}
