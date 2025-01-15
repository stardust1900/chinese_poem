import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

import 'constants.dart';
import 'data_classes.dart';
import 'drm.dart';
import 'typing.dart';

Map<String, dynamic> getHeadersAndData(Uint8List data, int headerLength) {
  final headers = <String, String>{};
  final headerBytes = data.sublist(0, headerLength);

  Uint8List bodyBytes = Uint8List(0);
  // 调用方法时已经减掉2位，这里不要再加2了
  if (data.length > headerLength) {
    bodyBytes = data.sublist(headerLength);
  }
  // print("headerBytes:$headerBytes");
  final headerLines = utf8.decode(headerBytes).split("\r\n");
  for (final line in headerLines) {
    if (line.isNotEmpty) {
      final parts = line.split(":");
      if (parts.length == 2) {
        headers[parts[0].trim()] = parts[1].trim();
      }
    }
  }
  // print("headers:$headers");
  return {'headers': headers, 'data': bodyBytes};
}

String removeIncompatibleCharacters(String input) {
  final chars = input.runes.map((rune) {
    final code = rune;
    if ((0 <= code && code <= 8) ||
        (11 <= code && code <= 12) ||
        (14 <= code && code <= 31)) {
      return " ";
    }
    return String.fromCharCode(code);
  }).join();

  return chars;
}

String connectId() {
  return Uuid().v4().replaceAll("-", "");
}

Iterable<Uint8List> splitTextByByteLength(String text, int byteLength) sync* {
  if (byteLength <= 0) {
    throw ArgumentError("byte_length 必须大于 0");
  }

  // 将字符串转换为 UTF-8 编码的字节列表
  List<int> encodedText = utf8.encode(text);

  while (encodedText.length > byteLength) {
    int splitAt = byteLength;
    // print(encodedText);
    // 查找前 byteLength 个字节中的最后一个空格位置
    int lastSpace = encodedText.lastIndexOf(32, byteLength - 1);
    // print("lastSpace:$lastSpace");
    if (lastSpace >= 0 && lastSpace < byteLength) {
      splitAt = lastSpace;
    }
    // print("length:${encodedText.length} splitAt:$splitAt");
    if (splitAt > encodedText.length) {
      splitAt = encodedText.length;
    }
    // print("===length:${encodedText.length} splitAt:$splitAt");
    // 确保所有 & 都被终止符 ; 结束
    for (int i = splitAt - 1; i >= 0; i--) {
      if (encodedText[i] == 38 /* '&' */) {
        // 检查 & 和 splitAt 之间的子列表中是否包含 ;
        bool isTerminated = encodedText.sublist(i, splitAt).contains(59);
        if (!isTerminated) {
          splitAt = i - 1;
          if (splitAt < 0) {
            throw ArgumentError("最大字节长度太小或文本格式无效");
          }
          if (splitAt == 0) {
            break;
          }
        } else {
          break;
        }
      }
    }

    // 确保 splitAt 不会切断多字节字符
    while (splitAt > 0) {
      try {
        // 尝试解码以验证 splitAt 是否有效
        utf8.decode(encodedText.sublist(0, splitAt));
        break;
      } catch (e) {
        // 如果解码失败，向前调整 splitAt
        splitAt--;
        if (splitAt < 0) {
          throw ArgumentError("最大字节长度太小或文本格式无效");
        }
      }
    }

    // 提取并返回新的段落
    Uint8List newSegment = Uint8List.fromList(encodedText.sublist(0, splitAt));
    if (newSegment.isNotEmpty) {
      yield newSegment;
    }

    // 如果 splitAt 为 0，避免无限循环
    if (splitAt == 0) {
      splitAt = 1;
    }

    // 移除已处理的部分
    encodedText = encodedText.sublist(splitAt);
  }

  // 返回剩余的字节
  if (encodedText.isNotEmpty) {
    Uint8List remainingSegment = Uint8List.fromList(encodedText);
    if (remainingSegment.isNotEmpty) {
      yield remainingSegment;
    }
  }
}

String mkssml(TTSConfig tc, String escapedText) {
  String xml =
      "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='en-US'>"
      "<voice name='${tc.voice}'>"
      "<prosody pitch='${tc.pitch}' rate='${tc.rate}' volume='${tc.volume}'>"
      "$escapedText"
      "</prosody>"
      "</voice>"
      "</speak>";

  // 构建并返回完整的 XML 字符串
  return xml;
}

String dateToString() {
  // 获取当前的 UTC 时间
  DateTime now = DateTime.now().toUtc();

  // 定义日期格式，不使用 Z，而是手动添加 GMT+0000
  DateFormat dateFormat = DateFormat(
      "EEE MMM dd yyyy HH:mm:ss 'GMT+0000' '(Coordinated Universal Time)'");

  // 格式化日期并返回
  return dateFormat.format(now);
}

// 模拟 ssml_headers_plus_data 函数
String ssmlHeadersPlusData(String requestId, String timestamp, String ssml) {
  // 构建 SSML 请求头和数据
  return "X-RequestId:$requestId\r\n"
          "Content-Type:application/ssml+xml\r\n"
          "X-Timestamp:${timestamp}Z\r\n"
          "Path:ssml\r\n\r\n"
          "$ssml"
      .trim();
}

// 计算最大消息大小
int calcMaxMessageSize(TTSConfig ttsConfig) {
  final websocketMaxSize = pow(2, 16).toInt(); // 2^16
  final overheadPerMessage = ssmlHeadersPlusData(
        connectId(),
        dateToString(),
        mkssml(ttsConfig, ""),
      ).length +
      50; // margin of error

  return websocketMaxSize - overheadPerMessage;
}

// 定义 Communicate 类
class Communicate {
  late final TTSConfig ttsConfig;
  late final Iterable<Uint8List> texts;
  final String? proxy;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final http.BaseClient? connector;
  late final CommunicateState state;

  // XML 转义
  static String escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  // 构造函数
  Communicate({
    required String text,
    String voice = defaultVoice,
    String rate = '+0%',
    String volume = '+0%',
    String pitch = '+0Hz',
    this.connector,
    this.proxy,
    int? connectTimeoutSeconds = 10,
    int? receiveTimeoutSeconds = 60,
  })  : connectTimeout = Duration(seconds: connectTimeoutSeconds ?? 10),
        receiveTimeout = Duration(seconds: receiveTimeoutSeconds ?? 60) {
    // 验证 TTS 设置并初始化 ttsConfig
    final ttsConfig_ = TTSConfig.validate(voice, rate, volume, pitch);

    // 验证 proxy 参数
    if (proxy != null && proxy!.isEmpty) {
      throw ArgumentError("proxy must be a non-empty string");
    } else if (proxy != null && proxy is! String) {
      throw ArgumentError("proxy must be a string");
    }
    // 验证 timeout 参数
    if (connectTimeout <= Duration.zero) {
      throw ArgumentError("connect_timeout must be a positive integer");
    }
    if (receiveTimeout <= Duration.zero) {
      throw ArgumentError("receive_timeout must be a positive integer");
    }

    // 验证 connector 参数
    if (connector != null && connector.runtimeType != http.BaseClient) {
      throw ArgumentError("connector must be an instance of http.BaseClient");
    }

    // 初始化 texts 和 state
    final texts_ = _initializeTexts(text, ttsConfig_);
    final state_ = CommunicateState(
      partialText: texts_.first,
      offsetCompensation: 0,
      lastDurationOffset: 0,
      streamWasCalled: false,
    );

    // 在构造函数体中赋值给 final 字段
    ttsConfig = ttsConfig_;
    texts = texts_;
    state = state_;
  }

  // 初始化 texts
  static Iterable<Uint8List> _initializeTexts(
      String text, TTSConfig ttsConfig) {
    final escapedText = escape(removeIncompatibleCharacters(text));
    final maxMessageSize = calcMaxMessageSize(ttsConfig);
    print("maxMessageSize:$maxMessageSize escapedText:$escapedText");
    return splitTextByByteLength(escapedText, maxMessageSize);
  }

  TTSChunk _parseMetadata(Uint8List data) {
    try {
      // 将 Uint8List 转换为字符串
      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString);
      print('jsonData:$jsonData');
      //{Metadata: [{Type: WordBoundary, Data: {Offset: 625000, Duration: 4500000, text: {Text: 今天, Length: 2, BoundaryType: WordBoundary}}}]}
      // 解析 JSON 数据
      final metadata = jsonData['Metadata'];

      // 创建 Type 映射表
      final Map<String, TTSChunkType> typeMapping = {
        'audio': TTSChunkType.audio,
        'WordBoundary': TTSChunkType.wordBoundary,
      };

      for (var metaObj in metadata) {
        final metaTypeStr = metaObj['Type'] as String?;
        if (metaTypeStr == "SessionEnd") {
          continue;
        }
        if (metaTypeStr == null) {
          throw Exception("Invalid metadata format: Type is missing");
        }
        // 将字符串类型的 Type 转换为 TTSChunkType 枚举
        final metaType = typeMapping[metaTypeStr];
        if (metaType == null) {
          throw Exception("Invalid metadata format: Type is missing");
        }

        if (metaType == TTSChunkType.wordBoundary) {
          final data = metaObj['Data'] as Map<String, dynamic>?;
          if (data == null) {
            throw Exception("Invalid metadata format: Data is missing");
          }

          final currentOffset =
              (data['Offset'] as int?)?.toInt() ?? 0 + state.offsetCompensation;
          final currentDuration = data['Duration'] as int? ?? 0;
          final text = data['text']['Text'] as String?;

          if (text == null) {
            throw Exception("Invalid metadata format: Text is missing");
          }
          return TTSChunk(
            type: metaType,
            offset: currentOffset,
            duration: currentDuration,
            text: text,
          );
        }
        throw Exception("Unknown metadata type: $metaType");
      }
      throw Exception("No WordBoundary metadata found");
    } catch (e, stackTrace) {
      print('_parseMetadata异常：$e');
      print('_parseMetadata堆栈跟踪：$stackTrace');
      throw Exception("Error parsing metadata: $e");
    }
  }

  Stream<TTSChunk> _stream() async* {
    // Create a new connection to the service.
    final sslContext = SecurityContext.defaultContext;
    // sslContext
    //     .setTrustedCertificates("${Directory.current.path}/lib/cacert.pem");

    final webSocketUrl = Uri.parse(
      "$wssUrl&Sec-MS-GEC=${DRM.generateSecMsGec()}"
      "&Sec-MS-GEC-Version=$secMsGecVersion"
      "&ConnectionId=${connectId()}",
    );
    print("webSocketUrl:${webSocketUrl.toString()}");
    final webSocket = IOWebSocketChannel.connect(webSocketUrl,
        customClient: HttpClient(context: sslContext), headers: wssHeaders);

    try {
      webSocket.sink.add(
        "X-Timestamp:${dateToString()}\r\n"
        "Content-Type:application/json; charset=utf-8\r\n"
        "Path:speech.config\r\n\r\n"
        '{"context":{"synthesis":{"audio":{"metadataoptions":{'
        '"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},'
        '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"'
        "}}}}\r\n",
      );

      print("partialText:${utf8.decode(state.partialText)}");
      webSocket.sink.add(
        ssmlHeadersPlusData(
          connectId(),
          dateToString(),
          mkssml(ttsConfig, utf8.decode(state.partialText)),
        ),
      );
      await for (final message in webSocket.stream) {
        if (webSocket.closeCode != null) {
          print(
              "WebSocket connection was closed with code: ${webSocket.closeCode}");
          break;
        }
        // print("message:$message");
        if (message is String) {
          final encodedData = utf8.encode(message);
          final headerEndIndex = message.indexOf("\r\n\r\n");
          final headersAndData = getHeadersAndData(encodedData, headerEndIndex);
          final headers = headersAndData["headers"];
          final data = headersAndData["data"];

          final path = headers["Path"];
          if (path == "audio.metadata") {
            final parsedMetadata = _parseMetadata(data);
            yield parsedMetadata;
            state.lastDurationOffset =
                parsedMetadata.offset + parsedMetadata.duration;
          } else if (path == "turn.end") {
            state.offsetCompensation = state.lastDurationOffset;
            state.offsetCompensation += 8750000;
            break;
          } else if (path != "response" && path != "turn.start") {
            throw Exception("Unknown path received");
          }
        } else if (message is Uint8List) {
          if (message.length < 2) {
            throw Exception("Binary message is missing the header length.");
          }
          // int headerLength1 = message
          //     .sublist(0, 2)
          //     .reduce((value, element) => (value << 8) | element);
          // print("headerLength1:$headerLength1");
          Uint8List headerLengthBytes = message.sublist(0, 2);
          final headerLength =
              ByteData.view(headerLengthBytes.buffer).getInt16(0, Endian.big);
          // print("headerLength:$headerLength");
          if (headerLength > message.length) {
            throw Exception(
                "Header length is greater than the length of the data.");
          }
          //去掉前两位 防止报错
          final headersAndData =
              getHeadersAndData(message.sublist(2), headerLength);
          final headers = headersAndData["headers"];
          final data = headersAndData["data"];

          final path = headers["Path"];
          if (path != "audio") {
            throw Exception(
                "Received binary message, but the path is not audio.");
          }

          final contentType = headers["Content-Type"];
          if (contentType == null) {
            if (data.isNotEmpty) {
              throw Exception(
                  "Received binary message with no Content-Type, but with data.");
            }
            continue;
          } else if (contentType != "audio/mpeg") {
            throw Exception(
                "Received binary message with an unexpected Content-Type.");
          }

          if (data.isEmpty) {
            throw Exception(
                "Received binary message, but it is missing the audio data.");
          }

          yield TTSChunk(
              type: TTSChunkType.audio,
              data: data as Uint8List,
              duration: 0,
              offset: 0,
              text: '');
        } else {
          throw Exception(message.error.toString());
        }
      }
    } catch (e, stackTrace) {
      print("_stream error: $e");
      print("Stack Trace: $stackTrace");
      rethrow;
    } finally {
      await webSocket.sink.close();
    }
  }

  Stream<TTSChunk> stream() async* {
    // Check if stream was called before.
    if (state.streamWasCalled) {
      throw StateError("stream can only be called once.");
    }
    state.streamWasCalled = true;
    print(texts);
    // Stream the audio and metadata from the service.
    for (final partialText in texts) {
      state.partialText = partialText; // 更新 state 中的 partialText
      try {
        await for (final message in _stream()) {
          yield message;
        }
      } on http.ClientException catch (e) {
        // 检查是否有 response 属性（仅适用于 HTTP 请求）
        if (e is http.Response) {
          if ((e as http.Response).statusCode != 403) {
            rethrow;
          }

          // Handle 403 error and retry the stream.
          DRM.handleClientResponseError(e as http.Response);
          await for (final message in _stream()) {
            yield message;
          }
        } else {
          // 如果没有 response 属性，直接抛出异常
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> save(String audioFname, [String? metadataFname]) async {
    IOSink? metadataSink;
    if (metadataFname != null) {
      final metadataFile = File(metadataFname);
      metadataSink = metadataFile.openWrite(encoding: utf8);
    }

    final audioFile = File(audioFname);
    final audioSink = audioFile.openWrite();

    try {
      await for (final message in stream()) {
        if (message.type == TTSChunkType.audio) {
          if (message.data!.isNotEmpty) {
            audioSink.add(message.data as Uint8List);
          }
        } else if (metadataSink != null &&
            message.type == TTSChunkType.wordBoundary) {
          metadataSink.write(jsonEncode(message.data));
          metadataSink.write('\n');
        }
      }
    } catch (e, stackTrace) {
      print('捕获到异常：$e');
      print('堆栈跟踪：$stackTrace');
    } finally {
      await audioSink.close();
      if (metadataSink != null) {
        await metadataSink.close();
      }
    }
  }

  Stream<TTSChunk> streamSync() async* {
    final controller = StreamController<TTSChunk>();
    final completer = Completer<void>();

    void listenToStream() async {
      try {
        await for (final message in stream()) {
          controller.add(message);
        }
        controller.close();
        completer.complete();
      } catch (e) {
        controller.addError(e);
        controller.close();
        completer.completeError(e);
      }
    }

    // Run the async stream in a separate isolate or future.
    // For simplicity, we'll use a Future here.
    Future.microtask(listenToStream);

    yield* controller.stream;
  }

  void saveSync(String audioFname, [String? metadataFname]) {
    runZonedGuarded(() async {
      await save(audioFname, metadataFname);
    }, (error, stackTrace) {
      // Handle any errors that occur during the save operation.
      print('Error during save: $error\n$stackTrace');
    });
  }
}
