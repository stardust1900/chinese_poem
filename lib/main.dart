import 'dart:convert';
import 'dart:math' hide log;
import 'dart:ui';
import 'dart:developer';
import 'package:chinese_poems/draggable_floating_button.dart';
import 'package:chinese_poems/poem_i18n.dart';
import 'package:chinese_poems/poem_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'i18n_demo.dart';

void main() {
  runApp(const PoemApp());
  // runApp(const Demo());
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
        body: ShowCaseWidget(
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
          builder: Builder(
              builder: (context) =>
                  MyHomePage(changeLocale: (locale) => _changeLocale(locale))),
          autoPlayDelay: const Duration(seconds: 3),
        ),
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
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  final GlobalKey _six = GlobalKey();
  final GlobalKey _seven = GlobalKey();
  final GlobalKey _body = GlobalKey();

  final changeLocale;
  bool shownEn = false;
  bool showPinyin = false;
  List<bool> checkList = List.filled(13, false);
  bool simplifiedChinese = true; //简体中文
  bool pinyinStyle1 = true; //拼音风格
  bool showAbout = false;
  var poemJson;

// 选中的诗
  var choosePoem;

  var pickCharacters = [];

  var rowsCharacters = [];

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _MyHomePageState(this.changeLocale);

  @override
  void initState() {
    // log("initState begin");
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
          })
        });

    super.initState();

    _prefs.then((SharedPreferences prefs) {
      bool showcaseview = prefs.getBool('showcaseview') ?? true;
      // log("showcaseview: $showcaseview");
      if (showcaseview) {
        prefs.setBool('showcaseview', !showcaseview);
        //showcaseview操作指引
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => ShowCaseWidget.of(context)
              .startShowCase([_one, _two, _three, _four, _five, _six, _seven]),
        );
      }
    });
  }

  //检查是不是标点符号
  bool isPunctuate(String s) {
    return s == '，' ||
        s == '。' ||
        s == '？' ||
        s == '！' ||
        s == '；' ||
        s == "：" ||
        s == "、" ||
        s == "·";
  }

// 生成标题
  Widget genTitle(colorScheme) {
    final titleCns = choosePoem['title_cns'].split("");
    final titleCnt = choosePoem['title_cnt'].split("");
    final titlePy1 = choosePoem['title_py1'].split(" ");
    final titlePy2 = choosePoem['title_py2'].split(" ");
    final titleEn = choosePoem['title_en'];
    var krctList = [];
    for (int i = 0; i < titleCns.length; i++) {
      final c = Character(titleCns[i], titleCnt[i], titlePy1[i], titlePy2[i]);
      c.isPunctuate = isPunctuate(c.txtCns);
      krctList.add(c);
    }
    return Row(children: [
      Expanded(
          child: Column(children: [
        FittedBox(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: krctList.map((c) => genCharacter(c, colorScheme)).toList(),
        )),
        genEnRow(titleEn, colorScheme)
      ]))
    ]);
  }

  Widget genCharacter(c, colorScheme) {
    return c.isPunctuate
        ? Container(
            width: 20,
            height: 60,
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
                  height: 40,
                  alignment: Alignment.center,
                  color: colorScheme.secondary,
                  child: Text(simplifiedChinese ? c.txtCns : c.txtCnt,
                      style: const TextStyle(fontSize: 25)),
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
    var krctList = [];
    for (int i = 0; i < authorCns.length; i++) {
      krctList.add(
          Character(authorCns[i], authorCnt[i], authorPy1[i], authorPy2[i]));
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Expanded(
          child: Column(children: [
        FittedBox(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            // width: 120,
            height: 60,
            alignment: Alignment.bottomRight,
            child: Wrap(children: [
              SizedBox.fromSize(size: const Size(24, 24)),
              Showcase(
                  key: _one,
                  description: PoemLocalizations.of(context).english,
                  descriptionAlignment: TextAlign.center,
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
          ),
          ...krctList.map((c) => genCharacter(c, colorScheme)).toList(),
          Container(
              // width: 120,
              height: 60,
              alignment: Alignment.bottomRight,
              // color: colorScheme.secondary,
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
                                int r = Random().nextInt(5);
                                if (r == 0) {
                                  rc.visibable = true;
                                  pickCharacters.remove(
                                      pickCharacters.firstWhere((element) =>
                                          element.txtCns == rc.txtCns));
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
                      icon: Icon(Icons.lightbulb_circle,
                          color: colorScheme.outline),
                      onPressed: () {
                        setState(() {
                          for (int r = 0; r < rowsCharacters.length; r++) {
                            for (int idx = 0;
                                idx < rowsCharacters[r].length;
                                idx++) {
                              if (!rowsCharacters[r][idx].visibable) {
                                rowsCharacters[r][idx].visibable = true;
                              }
                            }
                          }
                          pickCharacters.clear();
                        });
                      },
                    ))),
              ])),
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
      if (kractsCns.length != pinyin1.length) {
        log("$rowCns");
        log("$rowPy1");
        changePoem();
      }
      for (int i = 0; i < kractsCns.length; i++) {
        final c = Character(kractsCns[i], kractsCnt[i], pinyin1[i], pinyin2[i]);
        c.isPunctuate = isPunctuate(c.txtCns);
        krctList.add(c);
      }
      rowsCharacters[rowIdx] = krctList;
    } else {
      krctList = rowsCharacters[rowIdx];
    }

    List<Widget> rowList = krctList
        .map((c) => (c.isPunctuate
            ? Container(
                width: 20,
                height: 60,
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
                                style: const TextStyle(fontSize: 25))),
                      );
                    },
                        // 当拖拽进入时，判断是否接受
                        onWillAccept: (s) {
                      return s == c.txtCns || s == c.txtCnt;
                    }, onAccept: (s) {
                      setState(() {
                        rowsCharacters = rowsCharacters;
                        c.visibable = true;
                        pickCharacters.remove(pickCharacters.firstWhere(
                            (element) =>
                                element.txtCns == s || element.txtCnt == s));
                        for (int r = 0; r < rowsCharacters.length; r++) {
                          for (int idx = 0;
                              idx < rowsCharacters[r].length;
                              idx++) {
                            if (!rowsCharacters[r][idx].isPunctuate &&
                                !rowsCharacters[r][idx].visibable) {
                              return;
                            }
                          }
                        }
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(PoemLocalizations.of(context)
                                    .congratulations),
                                content:
                                    Text(PoemLocalizations.of(context).succeed),
                              );
                            });
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
          color: const Color.fromARGB(255, 243, 239, 239).withOpacity(0.5),
          alignment: Alignment.center,
          child: Text(c, style: const TextStyle(fontSize: 35)),
        ), // 携带的数据
        child: GestureDetector(
            onDoubleTap: () {
              // log("tap:$c");
              setState(() {
                for (int r = 0; r < rowsCharacters.length; r++) {
                  for (int idx = 0; idx < rowsCharacters[r].length; idx++) {
                    final rc = rowsCharacters[r][idx];
                    if (rc.txtCns == c || rc.txtCnt == c) {
                      if (!rc.visibable) {
                        rc.visibable = true;
                        pickCharacters.removeAt(i);
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
        flex: 2,
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
                          // runSpacing: 10,
                          //动态创建一个List<Widget>
                          children: wrap1children,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Wrap(
                            spacing: 5,
                            // runSpacing: 10,
                            //动态创建一个List<Widget>
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

    var buttonRow = FittedBox(
        child: Row(
      children: [
        TextButton.icon(
          onPressed: () => press(0, context),
          icon: const Icon(Icons.translate),
          label: Text(PoemLocalizations.of(context).language),
        ),
        TextButton.icon(
          onPressed: () => press(1, context),
          icon: const Icon(Icons.format_shapes),
          label: simplifiedChinese
              ? Text(PoemLocalizations.of(context).traditional)
              : Text(PoemLocalizations.of(context).simplified),
        ),
        TextButton.icon(
          onPressed: () => press(2, context),
          icon: pinyinStyle1
              ? const Icon(Icons.looks_one)
              : const Icon(Icons.looks_two),
          label: Text(PoemLocalizations.of(context).pinyinStyle),
        )
      ],
    ));

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
              buttonRow,
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
    // log("screenSize $screenSize");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text(titleText),
        // leading: Builder(builder: (context) {
        //   return IconButton(
        //     icon: const Icon(Icons.dashboard, color: Colors.white), //自定义图标
        //     onPressed: () {
        //       // 打开抽屉菜单
        //       Scaffold.of(context).openDrawer();
        //     },
        //   );
        // }),
      ),
      // drawer: PoemDrawer(changeLocale: changeLocale),
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
                    flex: 3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          genTitle(colorScheme),
                          genAuthor(context, colorScheme),
                        ])),
                Expanded(
                    flex: 6,
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
                onPressed: () {
                  changePoem();
                },
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
                      onPressed: () {},
                      child: const Icon(Icons.refresh),
                    )
                        // Container(
                        //     decoration: BoxDecoration(
                        //         color: colorScheme.primaryContainer,
                        //         borderRadius: const BorderRadius.only(
                        //           topLeft: Radius.circular(5.0), // 设置左上角圆角为5
                        //           topRight: Radius.circular(5.0),
                        //           bottomRight: Radius.circular(5.0), // 设置右下角圆角为5
                        //           bottomLeft: Radius.circular(5.0),
                        //         )),
                        //     child: const Icon(
                        //       size: 34,
                        //       Icons.refresh,
                        //     )),
                        )))
          ])),
      // floatingActionButton: SizedBox(
      //   // width: 25,
      //   // height: 25,
      //   child: Showcase(
      //       key: _seven,
      //       description: PoemLocalizations.of(context).change,
      //       disableDefaultTargetGestures: true,
      //       // onBarrierClick: () => debugPrint('Barrier clicked'),
      //       child: GestureDetector(
      //           // onTap: () => debugPrint('menu button clicked'),
      //           child: FloatingActionButton(
      //         mini: true,
      //         onPressed: () => {
      //           setState(
      //             () {
      //               pickCharacters.clear();
      //               var checked = checkList.where((c) => c).toList();
      //               var candidates = poemJson;
      //               if (checked.isNotEmpty) {
      //                 candidates = poemJson.where((e) {
      //                   if (checkList[0]) {
      //                     if (e['is300'] == 1) {
      //                       return true;
      //                     }
      //                   }

      //                   if (checkList[e['grade']]) {
      //                     return true;
      //                   }

      //                   return false;
      //                 }).toList();
      //               }
      //               choosePoem =
      //                   candidates[Random().nextInt(candidates.length)];
      //               var paragraphsCns = choosePoem['paragraphs_cns'];
      //               var paragraphsCnt = choosePoem['paragraphs_cnt'];

      //               for (int i = 0; i < paragraphsCns.length; i++) {
      //                 var krctCns = paragraphsCns[i].split("");
      //                 var krctCnt = paragraphsCnt[i].split("");
      //                 for (int idx = 0; idx < krctCns.length; idx++) {
      //                   if (!isPunctuate(krctCns[idx])) {
      //                     pickCharacters.add(
      //                         Character(krctCns[idx], krctCnt[idx], '', ''));
      //                   }
      //                 }
      //               }
      //               pickCharacters.shuffle();
      //               rowsCharacters.clear();
      //               //初始化固定长度数组
      //               rowsCharacters = []..length = paragraphsCns.length;
      //             },
      //           )
      //         },
      //         tooltip: PoemLocalizations.of(context).change,
      //         child: const Icon(Icons.refresh),
      //       ))), // This trailing comma makes auto-formatting nicer for build methods.
      // )
    );
  }

  void changePoem() {
    setState(() {
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
      //初始化固定长度数组
      rowsCharacters = []..length = paragraphsCns.length;
    });
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
  Character(this.txtCns, this.txtCnt, this.pinyin1, this.pinyin2);
}
