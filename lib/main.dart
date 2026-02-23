import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:chinese_poems/draggable_floating_button.dart';
import 'package:chinese_poems/poem_i18n.dart';
import 'package:chinese_poems/poem_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 全局初始化 FlutterTts 以避免线程问题
late final FlutterTts flutterTts;

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 锁定屏幕方向为竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PoemApp());
}

class PoemApp extends StatefulWidget {
  const PoemApp({super.key});
  @override
  State<StatefulWidget> createState() => _PoemAppState();
}

class _PoemAppState extends State<PoemApp> {
  Locale? lcl;

  @override
  Widget build(BuildContext context) {
    //获取设备默认语言
    lcl ??= PlatformDispatcher.instance.locale;
    // lcl ??= const Locale('en', '');
    // String titleText = PoemLocalizations.of(context).title;
    return MaterialApp(
      // title: '中国古诗',
      locale: lcl,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => PoemLocalizations.of(context).title,
      localizationsDelegates: const [
        PoemLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, //增加中文支持时需要增加这一句
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        colorScheme: chineseStyle15,
        useMaterial3: true,
      ),
      // home: MyHomePage(changeLocale: (locale) => _changeLocale(locale)),
      home: Scaffold(
        body: MyHomePage(changeLocale: (locale) => _changeLocale(locale)),
      ),
    );
  }

  _changeLocale(locale) {
    setState(() {
      if (locale != null) {
        lcl = locale;
      }
    });
  }
}

class MyHomePage extends StatefulWidget {
  final changeLocale;
  const MyHomePage({super.key, this.changeLocale});

  @override
  State<MyHomePage> createState() => _MyHomePageState(changeLocale);
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _zero = GlobalKey();
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  final GlobalKey _six = GlobalKey();
  final GlobalKey _seven = GlobalKey();
  final GlobalKey _body = GlobalKey();
  bool gameMode = true;
  final changeLocale;
  bool shownEn = false;
  bool showPinyin = false;
  List<bool> checkList = List.filled(13, false);
  bool simplifiedChinese = true; //简体中文
  bool pinyinStyle1 = true; //拼音风格
  bool showAbout = false;
  int reading = 0;
  String voiceName = "";
  Map<dynamic, dynamic> voice = {};
  List<Map<dynamic, dynamic>> availableVoices = [];
  var poemJson;

// 选中的诗
  var choosePoem;

  var pickCharacters = [];
  var titleCharacters = [];
  var authorCharacters = [];
  var rowsCharacters = [];
  //高亮的汉字
  var highLightCharacters = [];
  var allCharacters = [];
  int currentSentenceIndex = 0; // 当前朗读的句子索引（0=标题, 1=作者, 2+=诗句）
  List<String> sentences = []; // 要朗读的句子列表
  bool shouldContinueReading = false; // 是否应该继续朗读下一句
  bool isManuallyPaused = false; // 是否是手动暂停

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // 在组件首次构建后延迟初始化 FlutterTts
  bool _ttsInitialized = false;

  _MyHomePageState(this.changeLocale);

  void _initializeTTS() {
    if (_ttsInitialized) return;
    _ttsInitialized = true;

    flutterTts = FlutterTts();
    log("TTS initialized");

    flutterTts.setStartHandler(() {
      log("TTS Start triggered");
      if (mounted) {
        setState(() {
          reading = 1;
        });
      }
    });
    flutterTts.setErrorHandler((msg) {
      log("TTS Error: $msg");
      if (!shouldContinueReading) return;
      shouldContinueReading = false;
      currentSentenceIndex = 0;
      if (mounted) {
        setState(() {
          reading = 0;
        });
      }
      flutterTts.stop();
    });
    flutterTts.setCancelHandler(() {
      log("TTS Cancel triggered");
      if (!shouldContinueReading && reading == 0) return;
      // 如果是手动暂停，不重置索引
      if (!isManuallyPaused) {
        currentSentenceIndex = 0;
      }
      shouldContinueReading = false;
      if (mounted) {
        setState(() {
          reading = 0;
        });
      }
    });
    flutterTts.setPauseHandler(() {
      log("TTS Pause callback triggered");
      // 暂停回调不需要额外处理，因为暂停是用户主动触发的
    });
    flutterTts.setContinueHandler(() {
      log("TTS Continue triggered");
      // FlutterTts 不支持 pause/resume，所以这个回调通常不会触发
      // 但我们保留它以防万一
      if (mounted) {
        setState(() {
          reading = 1; // 恢复为播放状态
        });
      }
    });
  }

  @override
  void initState() {
    log("initState begin");

    // Register showcase view global configuration first
    ShowcaseView.register(
      onStart: (index, key) {
        // log('onStart: $index, $key');
      },
      onComplete: (index, key) {
        // log('onComplete: $index, $key');
        if (index == 4) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.white,
            ),
          );
        }
      },
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
    );

    super.initState();

    // 在首次构建后初始化 TTS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTTS();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 确保 TTS 已初始化
      if (!_ttsInitialized) return;

      // Set default language
      // await flutterTts.setLanguage("zh-CN");
      try {
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setVolume(1.0);
        await flutterTts.setPitch(1.0);
      } catch (e) {
        log("Error setting TTS params: $e");
      }

      // Ensure speak(...) awaits actual completion on platforms that support it
      try {
        await flutterTts.awaitSpeakCompletion(true);
      } catch (e) {
        log("awaitSpeakCompletion not supported: $e");
      }

      // Get available voices
      try {
        var voices = await flutterTts.getVoices;
        // log("Available voices: $voices");
        if (mounted) {
          setState(() {
            availableVoices = voices.cast<Map<dynamic, dynamic>>();
            availableVoices = availableVoices.where((e) {
              if (e['features'] != null) {
                if (e['features'].toString().contains("notInstalled")) {
                  return false;
                }
              }
              if (e['locale'] != null) {
                if (e['locale'].toString().startsWith("zh")) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            }).toList();
            // Find a Chinese voice as default
            if (availableVoices.isNotEmpty) {
              try {
                voice = availableVoices.firstWhere(
                  (v) =>
                      v['locale'] != null &&
                      v['locale'].toString().startsWith("zh"),
                  orElse: () => <dynamic, dynamic>{},
                );
                log("Chinese voice: $voice");
                voiceName = voice['name']?.toString() ?? "";
              } catch (e) {
                log("No Chinese voice found, using default");
              }
            }
          });
        }
      } catch (e) {
        log("Error getting voices: $e");
      }
    });

    // int rInt;
    rootBundle.loadString('asset/datas/chinese_poems.json').then((res) => {
          poemJson = jsonDecode(res),
          // print(poemJson),
          setState(() {
            choosePoem = poemJson[Random().nextInt(poemJson.length)];
            var paragraphsCns = choosePoem['paragraphs_cns'];
            var paragraphsCnt = choosePoem['paragraphs_cnt'];

            for (int i = 0; i < paragraphsCns.length; i++) {
              var krctCns = paragraphsCns[i].split("");
              var krctCnt = paragraphsCnt[i].split("");
              for (int idx = 0; idx < krctCns.length; idx++) {
                if (!isPunctuate(krctCns[idx])) {
                  pickCharacters
                      .add(Character(krctCns[idx], krctCnt[idx], '', ''));
                }
              }
            }
            //初始化固定长度数组
            rowsCharacters = []..length = paragraphsCns.length;
            pickCharacters.shuffle();

            if (!gameMode) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // 这里的代码将在状态更新且UI重新绘制后执行
                setState(() {
                  showAnswer();
                });
              });
            }
          }),
        });

    _prefs.then((SharedPreferences prefs) {
      log("prefs showcaseview: ${prefs.getBool('showcaseview')}");
      bool showcaseview = prefs.getBool('showcaseview') ?? true;
      log("showcaseview: $showcaseview");
      if (showcaseview) {
        prefs.setBool('showcaseview', false);
        //showcaseview操作指引 - 添加延迟确保界面完全渲染后再显示
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ShowcaseView.get().startShowCase(
                  [_zero, _one, _two, _three, _four, _five, _six, _seven]);
            }
          }),
        );
      }
    });
  }

  //检查是不是标点符号
  static const _punctuationSet = {'，', '。', '？', '！', '；', "：", "、", "·"};
  bool isPunctuate(String s) {
    return _punctuationSet.contains(s);
  }

  // 准备句子列表
  void prepareSentences() {
    var title = choosePoem['title_cns'];
    var author = choosePoem['author_cns'];
    var paragraphs = choosePoem['paragraphs_cns'];
    sentences = [title, author, ...paragraphs];
  }

  // 高亮当前句子
  void highlightCurrentSentence() {
    // 清除所有高亮
    for (Character c in titleCharacters) {
      c.highLight = false;
    }
    for (Character c in authorCharacters) {
      c.highLight = false;
    }
    for (var row in rowsCharacters) {
      if (row != null) {
        for (Character c in row) {
          c.highLight = false;
        }
      }
    }

    // 根据当前句子索引高亮对应部分
    if (currentSentenceIndex == 0) {
      // 高亮标题
      for (Character c in titleCharacters) {
        if (!c.isPunctuate) {
          c.highLight = true;
        }
      }
    } else if (currentSentenceIndex == 1) {
      // 高亮作者
      for (Character c in authorCharacters) {
        if (!c.isPunctuate) {
          c.highLight = true;
        }
      }
    } else {
      // 高亮对应诗句行
      int rowIndex = currentSentenceIndex - 2;
      if (rowIndex >= 0 && rowIndex < rowsCharacters.length) {
        var row = rowsCharacters[rowIndex];
        if (row != null) {
          for (Character c in row) {
            if (!c.isPunctuate) {
              c.highLight = true;
            }
          }
        }
      }
    }
  }

  // 朗读当前句子
  Future<void> speakCurrentSentence() async {
    if (!mounted) {
      log("Widget not mounted, stopping");
      return;
    }

    log("speakCurrentSentence called: currentSentenceIndex=$currentSentenceIndex, shouldContinueReading=$shouldContinueReading, reading=$reading, sentences.length=${sentences.length}");

    if (!shouldContinueReading && reading != 2) {
      log("shouldContinueReading is false and not paused, returning");
      return;
    }

    if (currentSentenceIndex >= sentences.length) {
      // 所有句子读完
      log("All sentences read, setting shouldContinueReading to false");
      shouldContinueReading = false;
      if (mounted) {
        setState(() {
          reading = 0;
          // 清除所有高亮
          for (Character c in titleCharacters) {
            c.highLight = false;
          }
          for (Character c in authorCharacters) {
            c.highLight = false;
          }
          for (var row in rowsCharacters) {
            if (row != null) {
              for (Character c in row) {
                c.highLight = false;
              }
            }
          }
        });
      }
      return;
    }

    var sentence = sentences[currentSentenceIndex];
    log("Speaking sentence $currentSentenceIndex: $sentence");

    // 高亮当前句子
    setState(() {
      highlightCurrentSentence();
      reading = 1;
    });

    try {
      // 朗读
      await flutterTts.speak(sentence);
      log("Finished speaking sentence $currentSentenceIndex");

      // 朗读完成后，自动读下一句（仅在未暂停时）
      if (mounted && shouldContinueReading && reading == 1 && !isManuallyPaused) {
        log("Auto-reading next sentence");
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && shouldContinueReading && reading == 1 && !isManuallyPaused) {
          currentSentenceIndex++;
          await speakCurrentSentence();
        }
      } else {
        // 如果暂停或停止，不执行下一句
        log("Not auto-reading next sentence: shouldContinueReading=$shouldContinueReading, reading=$reading, isManuallyPaused=$isManuallyPaused");
      }
    } catch (e) {
      log("Error speaking sentence: $e");
      shouldContinueReading = false;
      currentSentenceIndex = 0;
      _resetTTSCallbacks();
      if (mounted) {
        setState(() {
          reading = 0;
          // 清除所有高亮
          for (Character c in titleCharacters) {
            c.highLight = false;
          }
          for (Character c in authorCharacters) {
            c.highLight = false;
          }
          for (var row in rowsCharacters) {
            if (row != null) {
              for (Character c in row) {
                c.highLight = false;
              }
            }
          }
        });
      }
      try {
        await flutterTts.stop();
      } catch (e) {
        log("Error stopping TTS: $e");
      }
    }
  }

  // 开始朗读
  void startReading() async {
    if (reading != 0) {
      log("Already reading or paused, ignoring start request");
      return;
    }

    prepareSentences();
    currentSentenceIndex = 0;
    shouldContinueReading = true;
    isManuallyPaused = false; // 重置手动暂停标志
    await speakCurrentSentence();
  }

  // 停止朗读
  void stopReading() {
    // 避免重复调用
    if (!shouldContinueReading && reading == 0) {
      log("stopReading already called, ignoring");
      return;
    }

    log("stopReading called, current shouldContinueReading: $shouldContinueReading, reading: $reading");
    shouldContinueReading = false;
    currentSentenceIndex = 0;
    if (mounted) {
      setState(() {
        reading = 0;
        // 清除所有高亮
        for (Character c in titleCharacters) {
          c.highLight = false;
        }
        for (Character c in authorCharacters) {
          c.highLight = false;
        }
        for (var row in rowsCharacters) {
          if (row != null) {
            for (Character c in row) {
              c.highLight = false;
            }
          }
        }
      });
    }
    try {
      flutterTts.stop();
    } catch (e) {
      log("Error stopping TTS: $e");
    }
  }

  // 重置 TTS 回调以防止重复触发
  void _resetTTSCallbacks() {
    flutterTts.setStartHandler(() {});
    flutterTts.setErrorHandler((msg) {
      log("TTS Error: $msg");
    });
    flutterTts.setCancelHandler(() {});
    flutterTts.setPauseHandler(() {});
    flutterTts.setContinueHandler(() {});
  }

  List<Widget> genTitleAndAuthor(context, colorScheme) {
    List<Widget> rows = [];
    rows.add(genTitle(colorScheme));
    rows.add(genAuthor(context, colorScheme));
    return rows;
  }

// 生成标题
  Widget genTitle(colorScheme) {
    final titleCns = choosePoem['title_cns'].split("");
    final titleCnt = choosePoem['title_cnt'].split("");
    final titlePy1 = choosePoem['title_py1'].split(" ");
    final titlePy2 = choosePoem['title_py2'].split(" ");
    final titleEn = choosePoem['title_en'];
    if (titleCharacters.isEmpty) {
      for (int i = 0; i < titleCns.length; i++) {
        final c = Character(titleCns[i], titleCnt[i], titlePy1[i], titlePy2[i]);
        c.isPunctuate = isPunctuate(c.txtCns);
        titleCharacters.add(c);
        if (!c.isPunctuate) {
          allCharacters.add(c);
        }
      }
    }
    return Row(children: [
      Expanded(
          child: Column(children: [
        FittedBox(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: genCharacters(titleCharacters, colorScheme),
        )),
        genEnRow(titleEn, colorScheme)
      ]))
    ]);
  }

  List<Widget> genCharacters(characters, colorScheme) {
    List<Widget> list = [];
    for (Character c in characters) {
      list.add(genCharacter(c, colorScheme));
    }
    return list;
  }

  Widget genCharacter(c, colorScheme) {
    return c.isPunctuate
        ? Container(
            width: 20,
            // height: 50,
            alignment: Alignment.bottomCenter,
            // color: colorScheme.secondary,
            child: Text(c.txtCns))
        : Padding(
            padding: const EdgeInsets.all(5),
            child: Flex(
              direction: Axis.vertical,
              children: [
                Container(
                  width: 40,
                  height: 20,
                  alignment: Alignment.center,
                  child: Visibility(
                      visible: showPinyin,
                      child: Text(
                        pinyinStyle1 ? c.pinyin1 : c.pinyin2,
                        style: TextStyle(color: colorScheme.error),
                      )),
                ),
                Container(
                  width: 40,
                  // height: 40,
                  alignment: Alignment.center,
                  color: colorScheme.secondary,
                  child: Text(simplifiedChinese ? c.txtCns : c.txtCnt,
                      style: TextStyle(
                          fontSize: 25,
                          backgroundColor: c.highLight ? Colors.amber : null)),
                )
              ],
            ),
          );
  }

// 生成作者
  Widget genAuthor(context, colorScheme) {
    final authorCns = choosePoem['author_cns'].split("");
    final authorCnt = choosePoem['author_cnt'].split("");
    final authorPy1 = choosePoem['author_py1'].split(" ");
    final authorPy2 = choosePoem['author_py2'].split(" ");
    final authorEn = choosePoem['author_en'];
    if (authorCharacters.isEmpty) {
      for (int i = 0; i < authorCns.length; i++) {
        final c =
            Character(authorCns[i], authorCnt[i], authorPy1[i], authorPy2[i]);
        c.isPunctuate = isPunctuate(c.txtCns);
        authorCharacters.add(c);

        if (!c.isPunctuate) {
          allCharacters.add(c);
        }
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Expanded(
          child: Column(children: [
        FittedBox(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Wrap(children: [
            Showcase(
                key: _zero,
                description: PoemLocalizations.of(context).read,
                descriptionTextAlign: TextAlign.center,
                // tooltipPadding: EdgeInsets.all(100),
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: IconButton(
                  tooltip: PoemLocalizations.of(context).read,
                  // iconSize: 18,
                  icon: () {
                    if (reading == 1) {
                      return Icon(Icons.pause, color: colorScheme.tertiary);
                    } else if (reading == 2) {
                      return Icon(Icons.play_arrow, color: colorScheme.tertiary);
                    } else {
                      return Icon(Icons.record_voice_over_outlined,
                          color: colorScheme.tertiary);
                    }
                  }(),
                  onPressed: () async {
                    if (reading == 0) {
                      try {
                        log("Selected voice: $voice");
                        var name = voice['name']?.toString();
                        var locale = voice['locale']?.toString();
                        if (name != null && locale != null) {
                          await flutterTts
                              .setVoice({"name": name, "locale": locale});
                        }
                        startReading();
                      } catch (e) {
                        log('Error playing audio: $e');
                        setState(() {
                          reading = 0;
                        });
                      }
                    } else if (reading == 1) {
                      // 正在播放，暂停
                      try {
                        // 先设置停止标志，阻止自动播放
                        shouldContinueReading = false;
                        // 标记为手动暂停
                        isManuallyPaused = true;
                        // 停止 TTS
                        await flutterTts.stop();
                        log("TTS paused manually at index $currentSentenceIndex");
                        if (mounted) {
                          setState(() {
                            reading = 2;
                          });
                        }
                      } catch (e) {
                        log("Error pausing TTS: $e");
                      }
                    } else if (reading == 2) {
                      // 已暂停，继续播放
                      try {
                        log("Resuming playback from sentence $currentSentenceIndex, sentences length: ${sentences.length}");
                        // 检查句子列表是否已准备
                        if (sentences.isEmpty) {
                          prepareSentences();
                          log("Sentences prepared: ${sentences.length} sentences");
                        }
                        // 清除手动暂停标志
                        isManuallyPaused = false;
                        // 确保从当前句子开始，不重置索引
                        shouldContinueReading = true;
                        await speakCurrentSentence();
                      } catch (e) {
                        log("Error resuming TTS: $e");
                      }
                    } else {
                      log("Unexpected reading state: $reading");
                    }
                  },
                ))),
            Showcase(
                key: _one,
                description: PoemLocalizations.of(context).english,
                descriptionTextAlign: TextAlign.center,
                // tooltipPadding: EdgeInsets.all(100),
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: IconButton(
                  tooltip: PoemLocalizations.of(context).english,
                  // iconSize: 18,
                  icon: shownEn
                      ? Icon(Icons.explicit, color: colorScheme.tertiary)
                      : Icon(Icons.explicit_outlined,
                          color: colorScheme.tertiary),
                  onPressed: () {
                    setState(() {
                      shownEn = !shownEn;
                    });
                  },
                ))),
            Showcase(
                key: _two,
                description: PoemLocalizations.of(context).pinyin,
                disableDefaultTargetGestures: true,
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: IconButton(
                  tooltip: PoemLocalizations.of(context).pinyin,
                  // iconSize: 18,
                  icon: showPinyin
                      ? Icon(
                          Icons.fiber_pin,
                          color: colorScheme.error,
                        )
                      : Icon(Icons.fiber_pin_outlined,
                          color: colorScheme.error),
                  onPressed: () {
                    setState(() {
                      showPinyin = !showPinyin;
                    });
                  },
                ))),
          ]),
          ...authorCharacters.map((c) => genCharacter(c, colorScheme)),
          Wrap(children: [
            Showcase(
                key: _three,
                description: PoemLocalizations.of(context).next,
                disableDefaultTargetGestures: true,
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: IconButton(
                  tooltip: PoemLocalizations.of(context).next,
                  // iconSize: 16,
                  icon: const Icon(Icons.navigate_next),
                  //显示下一个字
                  onPressed: () {
                    setState(() {
                      for (int r = 0; r < rowsCharacters.length; r++) {
                        for (int idx = 0;
                            idx < rowsCharacters[r].length;
                            idx++) {
                          final rc = rowsCharacters[r][idx];
                          if (!rc.visibable && !isPunctuate(rc.txtCns)) {
                            rc.visibable = true;
                            pickCharacters.remove(pickCharacters.firstWhere(
                                (element) => element.txtCns == rc.txtCns));
                            return;
                          }
                        }
                      }
                    });
                  },
                ))),
            Showcase(
                key: _four,
                description: PoemLocalizations.of(context).random,
                disableDefaultTargetGestures: true,
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: IconButton(
                  tooltip: PoemLocalizations.of(context).random,
                  // iconSize: 16,
                  icon: const Icon(Icons.tune),
                  //随机显示一些字
                  onPressed: () {
                    setState(() {
                      for (int r = 0; r < rowsCharacters.length; r++) {
                        for (int idx = 0;
                            idx < rowsCharacters[r].length;
                            idx++) {
                          final rc = rowsCharacters[r][idx];
                          if (!rc.visibable && !isPunctuate(rc.txtCns)) {
                            //没显示的字有1/5的概率显示
                            int rand = Random().nextInt(5);
                            if (rand == 0) {
                              rc.visibable = true;
                              pickCharacters.remove(pickCharacters.firstWhere(
                                  (element) => element.txtCns == rc.txtCns));
                            }
                          }
                        }
                      }
                    });
                  },
                ))),
            Showcase(
                key: _five,
                description: PoemLocalizations.of(context).answer,
                disableDefaultTargetGestures: true,
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: IconButton(
                  tooltip: PoemLocalizations.of(context).answer,
                  // iconSize: 16,
                  icon:
                      Icon(Icons.lightbulb_circle, color: colorScheme.outline),
                  onPressed: () => {
                    setState(() {
                      showAnswer();
                    })
                  },
                ))),
          ]),
        ])),
        genEnRow(authorEn, colorScheme)
      ]))
    ]);
  }

  Widget genButtons(context, colorScheme) {
    return FittedBox(
        child: Wrap(children: [
      Showcase(
          key: _three,
          description: PoemLocalizations.of(context).next,
          disableDefaultTargetGestures: true,
          // onBarrierClick: () => debugPrint('Barrier clicked'),
          child: GestureDetector(
              // onTap: () => debugPrint('menu button clicked'),
              child: IconButton(
            tooltip: PoemLocalizations.of(context).next,
            // iconSize: 16,
            icon: const Icon(Icons.navigate_next),
            //显示下一个字
            onPressed: () {
              setState(() {
                for (int r = 0; r < rowsCharacters.length; r++) {
                  for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
                    final rc = rowsCharacters[r][idx];
                    if (!rc.visibable && !isPunctuate(rc.txtCns)) {
                      rc.visibable = true;
                      pickCharacters.remove(pickCharacters.firstWhere(
                          (element) => element.txtCns == rc.txtCns));
                      return;
                    }
                  }
                }
              });
            },
          ))),
      Showcase(
          key: _four,
          description: PoemLocalizations.of(context).random,
          disableDefaultTargetGestures: true,
          // onBarrierClick: () => debugPrint('Barrier clicked'),
          child: GestureDetector(
              // onTap: () => debugPrint('menu button clicked'),
              child: IconButton(
            tooltip: PoemLocalizations.of(context).random,
            // iconSize: 16,
            icon: const Icon(Icons.tune),
            //随机显示一些字
            onPressed: () {
              setState(() {
                for (int r = 0; r < rowsCharacters.length; r++) {
                  for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
                    final rc = rowsCharacters[r][idx];
                    if (!rc.visibable && !isPunctuate(rc.txtCns)) {
                      //没显示的字有1/5的概率显示
                      int r = Random().nextInt(5);
                      if (r == 0) {
                        rc.visibable = true;
                        pickCharacters.remove(pickCharacters.firstWhere(
                            (element) => element.txtCns == rc.txtCns));
                      }
                    }
                  }
                }
              });
            },
          ))),
      Showcase(
          key: _five,
          description: PoemLocalizations.of(context).answer,
          disableDefaultTargetGestures: true,
          // onBarrierClick: () => debugPrint('Barrier clicked'),
          child: GestureDetector(
              // onTap: () => debugPrint('menu button clicked'),
              child: IconButton(
            tooltip: PoemLocalizations.of(context).answer,
            // iconSize: 16,
            icon: Icon(Icons.lightbulb_circle, color: colorScheme.outline),
            onPressed: () {
              setState(() {
                for (int r = 0; r < rowsCharacters.length; r++) {
                  for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
                    if (!rowsCharacters[r][idx].visibable) {
                      rowsCharacters[r][idx].visibable = true;
                    }
                  }
                }
                pickCharacters.clear();
              });
            },
          ))),
    ]));
  }

// 生成诗句
  List<Widget> genParagraphs(context, colorScheme) {
    final paragraphsCns = choosePoem['paragraphs_cns'];
    final paragraphsCnt = choosePoem['paragraphs_cnt'];
    final paragraphsPy1 = choosePoem['paragraphs_py1'];
    final paragraphsPy2 = choosePoem['paragraphs_py2'];
    final paragraphsEn = choosePoem['paragraphs_en'];
    List<Widget> rows = [];
    for (int rowIdx = 0; rowIdx < paragraphsCns.length; rowIdx++) {
      rows.add(genParagraphRow(
          rowIdx,
          paragraphsCns[rowIdx],
          paragraphsCnt[rowIdx],
          paragraphsPy1[rowIdx],
          paragraphsPy2[rowIdx],
          paragraphsEn[rowIdx],
          context,
          colorScheme));
    }
    return rows;
  }

//生成一行诗句
  Widget genParagraphRow(
      rowIdx, rowCns, rowCnt, rowPy1, rowPy2, rowEn, context, colorScheme) {
    final kractsCns = rowCns.split("");
    final kractsCnt = rowCnt.split("");
    final pinyin1 = rowPy1.split(" ");
    final pinyin2 = rowPy2.split(" ");
    List<Character> krctList;
    if (rowsCharacters[rowIdx] == null) {
      krctList = [];
      if (kractsCns.length != pinyin1.length ||
          kractsCns.length != kractsCnt.length ||
          kractsCns.length != pinyin2.length) {
        // log("$rowCns");
      }
      for (int i = 0; i < kractsCns.length; i++) {
        final c = Character(kractsCns[i], kractsCnt[i], pinyin1[i], pinyin2[i]);
        c.isPunctuate = isPunctuate(c.txtCns);
        krctList.add(c);
        if (!c.isPunctuate) {
          allCharacters.add(c);
        }
      }
      rowsCharacters[rowIdx] = krctList;
    } else {
      krctList = rowsCharacters[rowIdx];
    }

    List<Widget> rowList = krctList
        .map((c) => (c.isPunctuate
            ? Container(
                width: 20,
                height: 50,
                alignment: Alignment.bottomCenter,
                // color: colorScheme.secondary,
                child: Text(c.txtCns))
            : Padding(
                padding: const EdgeInsets.all(5),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Container(
                      width: 40,
                      height: 20,
                      alignment: Alignment.center,
                      child: Visibility(
                          visible: showPinyin,
                          child: FittedBox(
                              child: Text(
                            pinyinStyle1 ? c.pinyin1 : c.pinyin2,
                            style: TextStyle(color: colorScheme.error),
                          ))),
                    ),
                    DragTarget<String>(
                        builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        color: colorScheme.secondary,
                        child: Visibility(
                            visible: c.visibable,
                            child: Text(simplifiedChinese ? c.txtCns : c.txtCnt,
                                style: TextStyle(
                                    fontSize: 25,
                                    backgroundColor:
                                        c.highLight ? Colors.amber : null))),
                      );
                    },
                        // 当拖拽进入时，判断是否接受
                        onWillAcceptWithDetails: (s) {
                      return s.data == c.txtCns || s.data == c.txtCnt;
                    }, onAcceptWithDetails: (s) {
                      setState(() {
                        rowsCharacters = rowsCharacters;
                        c.visibable = true;
                        pickCharacters.remove(pickCharacters.firstWhere(
                            (element) =>
                                element.txtCns == s.data ||
                                element.txtCnt == s.data));
                        // for (int r = 0; r < rowsCharacters.length; r++) {
                        //   for (int idx = 0;
                        //       idx < rowsCharacters[r].length;
                        //       idx++) {
                        //     if (!rowsCharacters[r][idx].isPunctuate &&
                        //         !rowsCharacters[r][idx].visibable) {
                        //       return;
                        //     }
                        //   }
                        // }
                        if (pickCharacters.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(PoemLocalizations.of(context)
                                      .congratulations),
                                  content: Text(
                                      PoemLocalizations.of(context).succeed),
                                );
                              });
                        }
                      });
                    })
                  ],
                ),
              )))
        .toList();

    return Row(children: [
      Expanded(
          child: Column(children: [
        FittedBox(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowList,
        )),
        genEnRow(rowEn, colorScheme)
      ]))
    ]);
  }

//生成英文行
  Widget genEnRow(enTxt, colorScheme) {
    return Row(children: [
      Expanded(
          child: Container(
              alignment: Alignment.center,
              // color: colorScheme.tertiary,
              child: Visibility(
                  visible: shownEn,
                  child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                          alignment: Alignment.center,
                          width: 350,
                          color: colorScheme.tertiary,
                          child: Text(
                            enTxt,
                            style: TextStyle(
                                fontSize: 13, color: colorScheme.secondary),
                          ))))))
    ]);
  }

//生成选字区域
  Widget _pickArea(colorScheme) {
    List<Widget> dragList = [];
    for (int i = 0; i < pickCharacters.length; i++) {
      var c = simplifiedChinese
          ? pickCharacters[i].txtCns
          : pickCharacters[i].txtCnt;
      var drag = Draggable<String>(
        data: c,
        feedback: Container(
          // 拖拽时的显示
          width: 45,
          height: 45,
          color: const Color.fromARGB(255, 243, 239, 239),
          alignment: Alignment.center,
          child: Text(c, style: const TextStyle(fontSize: 35)),
        ), // 携带的数据
        child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                // for (int r = 0; r < rowsCharacters.length; r++) {
                //   for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
                //     final rc = rowsCharacters[r][idx];
                //     if (rc.txtCns == c || rc.txtCnt == c) {
                //       if (!rc.visibable) {
                //         rc.visibable = true;
                //         pickCharacters.removeAt(i);
                //         return;
                //       }
                //     }
                //   }
                // }
                for (int r = 0; r < rowsCharacters.length; r++) {
                  for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
                    final rc = rowsCharacters[r][idx];
                    if (!rc.visibable && !isPunctuate(rc.txtCns)) {
                      if (rc.txtCns == c || rc.txtCnt == c) {
                        rc.visibable = true;
                        pickCharacters.remove(pickCharacters.firstWhere(
                            (element) => element.txtCns == rc.txtCns));

                        if (pickCharacters.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(PoemLocalizations.of(context)
                                      .congratulations),
                                  content: Text(
                                      PoemLocalizations.of(context).succeed),
                                );
                              });
                        }
                        return;
                      } else {
                        return;
                      }
                    }
                  }
                }
              });
            },
            child: Container(
              // 正常状态下的显示
              width: 40,
              height: 40,
              color: const Color.fromARGB(255, 243, 239, 239),
              alignment: Alignment.topCenter,
              child: Text(
                c,
                style: const TextStyle(fontSize: 30),
              ),
            )),
      );
      dragList.add(drag);
    }
    //"~/"运算符执行的是整数除法,也称为截断除法
    ////当两个操作数都是整数时,"~/"运算符将返回除法结果的整数部分,而忽略任何小数部分
    List<Widget> wrap1children = dragList.sublist(0, dragList.length ~/ 2);
    List<Widget> wrap2children = dragList.sublist(dragList.length ~/ 2);
    final ctrler = ScrollController(initialScrollOffset: 0);
    return Expanded(
        flex: 3,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.bottom,
          thumbVisibility: true,
          controller: ctrler,
          // 显示进度条
          child: SingleChildScrollView(
            controller: ctrler,
            scrollDirection: Axis.horizontal,
            // padding: const EdgeInsets.all(5.0),
            child: Showcase(
                key: _six,
                description: PoemLocalizations.of(context).pick,
                disableDefaultTargetGestures: true,
                // onBarrierClick: () => debugPrint('Barrier clicked'),
                child: GestureDetector(
                    // onTap: () => debugPrint('menu button clicked'),
                    child: Container(
                  alignment: Alignment.topCenter,
                  // color: colorScheme.primary,
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Wrap(
                          spacing: 5,
                          children: wrap1children,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Wrap(
                            spacing: 5,
                            children: wrap2children,
                          ))
                    ],
                  ),
                ))),
          ),
        ));
  }

// 生成抽屉菜单
  Widget genDrawItems(colorScheme) {
    var drawerHeader = UserAccountsDrawerHeader(
      accountName: const Text(
        "",
      ),
      accountEmail: const Text(
        "",
      ),
      currentAccountPicture: CircleAvatar(
        child: Image.asset("asset/images/poem.png"),
      ),
      onDetailsPressed: () {
        setState(() {
          showAbout = !showAbout;
        });
      },
    );

    var about = Column(children: [
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          alignment: Alignment.topCenter,
          // color: colorScheme.primary,
          child: Text(PoemLocalizations.of(context).about),
        ))
      ]),
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          // color: colorScheme.primary,
          child: Text(PoemLocalizations.of(context).aboutLine1),
        ))
      ]),
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          // color: colorScheme.primary,
          child: Text(PoemLocalizations.of(context).aboutLine2),
        ))
      ]),
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          // color: colorScheme.primary,
          child: Text(PoemLocalizations.of(context).aboutLine3),
        ))
      ]),
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          // color: colorScheme.primary,
          child: Text(PoemLocalizations.of(context).aboutLine4),
        ))
      ]),
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          // color: colorScheme.primary,
          child: Text(PoemLocalizations.of(context).aboutLine5),
        ))
      ])
    ]);

    var buttonRow1 = Row(
      children: [
        TextButton.icon(
          onPressed: () => press(2, context),
          icon: pinyinStyle1
              ? const Icon(Icons.looks_one)
              : const Icon(Icons.looks_two),
          label: Text(PoemLocalizations.of(context).pinyinStyle),
        ),
        TextButton.icon(
          onPressed: () => press(0, context),
          icon: const Icon(Icons.translate),
          label: Text(PoemLocalizations.of(context).language),
        ),
      ],
    );

    var buttonRow2 = Row(
      children: [
        TextButton.icon(
          onPressed: () => press(3, context),
          icon: gameMode
              ? const Icon(Icons.videogame_asset_outlined)
              : const Icon(Icons.videogame_asset_off_outlined),
          label: Text(PoemLocalizations.of(context).gameMode),
        ),
        TextButton.icon(
          onPressed: () => press(1, context),
          icon: const Icon(Icons.format_shapes),
          label: simplifiedChinese
              ? Text(PoemLocalizations.of(context).traditional)
              : Text(PoemLocalizations.of(context).simplified),
        ),
      ],
    );

    var voiceDropdown = Row(children: [
      Expanded(
          flex: 1,
          child: Icon(
            Icons.record_voice_over_sharp,
            color: colorScheme.primary,
          )),
      Expanded(
        flex: 7,
        child: DropdownButton(
            iconEnabledColor: colorScheme.primary,
            style: TextStyle(color: colorScheme.onSecondary, fontSize: 12),
            isExpanded: true,
            value: voiceName,
            items: availableVoices.isEmpty
                ? [
                    DropdownMenuItem<String>(
                        value: "", child: Text("加载中...", softWrap: true))
                  ]
                : availableVoices.map<DropdownMenuItem<String>>((v) {
                    var name = v['name']?.toString() ?? '';
                    // var locale = v['locale']?.toString() ?? '';
                    return DropdownMenuItem<String>(
                        value: name, child: Text(name, softWrap: true));
                  }).toList(),
            onChanged: (value) async {
              if (value != null) {
                setState(() {
                  voiceName = value;
                  voice = availableVoices.firstWhere(
                    (v) => value.contains(v['name']!.toString()),
                    orElse: () => <dynamic, dynamic>{},
                  );
                });
                var name = voice['name']?.toString();
                var locale = voice['locale']?.toString();
                if (name != null && locale != null) {
                  await flutterTts.setVoice({"name": name, "locale": locale});
                }
              }
            }),
      )
    ]);
    List<Widget> tileList = [];
    for (int i = 0; i < 13; i++) {
      final tile = ListTile(
        title: Text(
          PoemLocalizations.of(context).getGrade(i),
        ),
        leading: checkList[i]
            ? const Icon(Icons.check_circle)
            : const Icon(Icons.check_circle_outline),
        onTap: () {
          setState(() {
            checkList[i] = !checkList[i];
          });
        },
      );
      tileList.add(tile);
    }
    final drawerItems = showAbout
        ? ListView(
            children: [drawerHeader, about],
          )
        : ListView(
            children: [
              drawerHeader,
              buttonRow1,
              buttonRow2,
              voiceDropdown,
              ...tileList,
            ],
          );
    return drawerItems;
  }

  void press(type, context) {
    if (0 == type) {
      String currentLanguageCode =
          PoemLocalizations.of(context).locale.languageCode;
      if ("zh" == currentLanguageCode) {
        changeLocale(const Locale('en', ''));
      } else {
        changeLocale(const Locale('zh', ''));
      }
    } else if (1 == type) {
      setState(() {
        simplifiedChinese = !simplifiedChinese;
      });
    } else if (2 == type) {
      setState(() {
        pinyinStyle1 = !pinyinStyle1;
      });
    } else if (3 == type) {
      setState(() {
        gameMode = !gameMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (choosePoem == null) {
      return const Center(
        child: Icon(Icons.hourglass_empty),
      );
    }
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    String titleText = PoemLocalizations.of(context).title;
    final ctrler = ScrollController(initialScrollOffset: 0);

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(titleText),
      ),
      drawer: Drawer(
        child: genDrawItems(colorScheme),
      ),
      body: Container(
          padding: EdgeInsets.all(1),
          child: Stack(key: _body, children: [
            Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                    flex: 4,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...genTitleAndAuthor(context, colorScheme)
                        ])),
                Expanded(
                    flex: 7,
                    child: Scrollbar(
                        controller: ctrler,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        child: SingleChildScrollView(
                            controller: ctrler,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(spacing: 5, children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...genParagraphs(context, colorScheme)
                                ],
                              ),
                            ])))),
                _pickArea(colorScheme),
              ],
            ),
            DraggableFloatingActionButton(
                initialOffset:
                    Offset(screenSize.width - 40, screenSize.height - 240),
                onPressed: () {},
                parentKey: _body,
                child: Showcase(
                    key: _seven,
                    description: PoemLocalizations.of(context).change,
                    disableDefaultTargetGestures: true,
                    // onBarrierClick: () => debugPrint('Barrier clicked'),
                    child: GestureDetector(
                        // onTap: () => debugPrint('menu button clicked'),
                        child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        changePoem();
                      },
                      child: const Icon(Icons.refresh),
                    ))))
          ])),
    );
  }

  void showAnswer() {
    for (int r = 0; r < rowsCharacters.length; r++) {
      if (rowsCharacters[r] != null) {
        for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
          if (!rowsCharacters[r][idx].visibable) {
            rowsCharacters[r][idx].visibable = true;
          }
        }
      }
    }
    pickCharacters.clear();
  }

  void changePoem() {
    log("changePoem start");
    flutterTts.stop();
    setState(() {
      reading = 0;
      currentSentenceIndex = 0;
      pickCharacters.clear();
      var checked = checkList.where((c) => c).toList();
      var candidates = poemJson;
      if (checked.isNotEmpty) {
        candidates = poemJson.where((e) {
          if (checkList[0]) {
            if (e['is300'] == 1) {
              return true;
            }
          }

          if (checkList[e['grade']]) {
            return true;
          }

          return false;
        }).toList();
      }
      var tempPoem = candidates[Random().nextInt(candidates.length)];
      //去掉重复判断 防止死循环
      // while (tempPoem['title_cns'] == choosePoem['title_cns']) {
      //   // log("${tempPoem['title_cns']},${choosePoem['title_cns']}");
      //   tempPoem = candidates[Random().nextInt(candidates.length)];
      // }
      choosePoem = tempPoem;
      var paragraphsCns = choosePoem['paragraphs_cns'];
      var paragraphsCnt = choosePoem['paragraphs_cnt'];

      for (int i = 0; i < paragraphsCns.length; i++) {
        var krctCns = paragraphsCns[i].split("");
        var krctCnt = paragraphsCnt[i].split("");
        for (int idx = 0; idx < krctCns.length; idx++) {
          if (!isPunctuate(krctCns[idx])) {
            pickCharacters.add(Character(krctCns[idx], krctCnt[idx], '', ''));
          }
        }
      }
      pickCharacters.shuffle();
      rowsCharacters.clear();
      titleCharacters.clear();
      authorCharacters.clear();
      allCharacters.clear();
      //初始化固定长度数组
      rowsCharacters = []..length = paragraphsCns.length;
      log("changePoem end");
    });
    if (!gameMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 这里的代码将在状态更新且UI重新绘制后执行
        setState(() {
          showAnswer();
        });
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    ShowcaseView.get().unregister();
    super.dispose();
  }
}

class PoemDrawer extends StatelessWidget {
  final changeLocale;
  const PoemDrawer({super.key, this.changeLocale});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 60.0, left: 10.0),
        color: Theme.of(context).colorScheme.background,
        child: Flex(
          direction: Axis.vertical,
          children: [
            TextButton.icon(
                onPressed: () => press(context),
                icon: const Icon(Icons.refresh),
                label: Text(PoemLocalizations.of(context).title)),
          ],
        ));
  }

  void press(context) {
    String currentLanguageCode =
        PoemLocalizations.of(context).locale.languageCode;
    if ("zh" == currentLanguageCode) {
      changeLocale(const Locale('en', ''));
    } else {
      changeLocale(const Locale('zh', ''));
    }
  }
}

class Character {
  String txtCns;
  String txtCnt;
  String pinyin1;
  String pinyin2;
  bool visibable = false;
  bool isPunctuate = false;
  bool highLight = false;
  Character(this.txtCns, this.txtCnt, this.pinyin1, this.pinyin2);
}
