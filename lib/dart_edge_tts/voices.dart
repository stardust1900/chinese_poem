import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'drm.dart';
import 'typing.dart';

Future<List<Voice>?> listVoices() async {
  // final sslContext = SecurityContext.defaultContext;
  // sslContext.setTrustedCertificates(
  //     "${Directory.current.path}/lib/cacert.pem"); // 替换为实际的证书路径

  final client = http.Client();

  try {
    final url = Uri.parse(
        "$voiceListUrl&Sec-MS-GEC=${DRM.generateSecMsGec()}&Sec-MS-GEC-Version=$secMsGecVersion");

    var response = await client.get(
      url,
      headers: voiceHeaders,
      // 如果有代理，可以在这里设置
    );

    if (response.statusCode == 403) {
      DRM.handleClientResponseError(response);
      // 重新尝试请求
      final retryResponse = await client.get(url, headers: voiceHeaders);
      response = retryResponse;
    }

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch voices: ${response.statusCode}");
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => Voice.fromMap(e)).toList();
  } finally {
    client.close();
  }
}

class VoicesManager {
  List<Voice> _voices = [];
  bool _calledCreate = false;

  // 私有构造函数
  VoicesManager._();

  // 静态异步方法来创建并初始化 VoicesManager
  static Future<VoicesManager> create({List<Voice>? customVoices}) async {
    final manager = VoicesManager._();
    manager._voices = (customVoices ?? await listVoices())!;
    manager._calledCreate = true;
    return manager;
  }

  // 查找匹配的语音
  List<Voice> find({
    String? language,
    String? name,
    List<String>? contentCategories,
    List<String>? voicePersonalities,
  }) {
    if (!_calledCreate) {
      throw StateError(
          "VoicesManager.find() called before VoicesManager.create()");
    }

    return _voices.where((voice) {
      bool matchesLanguage =
          language == null || voice.locale.startsWith(language);
      bool matchesName = name == null || voice.name == name;
      bool matchesCategories = contentCategories == null ||
          contentCategories.every((category) =>
              voice.voiceTag.contentCategories.contains(category));
      bool matchesPersonalities = voicePersonalities == null ||
          voicePersonalities.every((personality) =>
              voice.voiceTag.voicePersonalities.contains(personality));

      return matchesLanguage &&
          matchesName &&
          matchesCategories &&
          matchesPersonalities;
    }).toList();
  }

  List<Voice> get voices => _voices;
}
