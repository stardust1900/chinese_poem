import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:chinese_poems/poem_i18n.dart';
import 'package:chinese_poems/poem_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      home: MyHomePage(changeLocale: (locale) => _changeLocale(locale)),
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
  final changeLocale;
  bool shownEn = false;
  bool showPinyin = false;
  List<bool> checkList = [];

  var poemJson;

// 选中的诗
  var choosePoem;

  var pickCharacters = [];

  var rowsCharacters = [];

  _MyHomePageState(this.changeLocale);

  @override
  void initState() {
    // int rInt;
    rootBundle.loadString('asset/datas/chinese_poems.json').then((res) => {
          poemJson = jsonDecode(res),
          // print(poemJson),
          setState(() {
            choosePoem = poemJson[Random().nextInt(poemJson.length)];
            for (var p in choosePoem['paragraphs_cns']) {
              for (var c in p.split("")) {
                if (!isPunctuate(c)) {
                  pickCharacters.add(c);
                }
              }
            }
            //初始化固定长度数组
            rowsCharacters = []..length = choosePoem['paragraphs_cns'].length;
            pickCharacters.shuffle();
          })
        });

    super.initState();
  }

  //检查是不是标点符号
  bool isPunctuate(String s) {
    return s == '，' || s == '。' || s == '？' || s == '！' || s == '；';
  }

  Widget genButtons(context, colorScheme) {
    return Wrap(children: [
      IconButton(
        tooltip: PoemLocalizations.of(context).english,
        iconSize: 16,
        icon: shownEn
            ? Icon(Icons.sort_by_alpha_rounded, color: colorScheme.tertiary)
            : Icon(Icons.sort_by_alpha, color: colorScheme.tertiary),
        onPressed: () {
          setState(() {
            shownEn = !shownEn;
          });
        },
      ),
      IconButton(
        tooltip: PoemLocalizations.of(context).pinyin,
        iconSize: 16,
        icon: showPinyin
            ? Icon(
                Icons.link_off,
                color: colorScheme.error,
              )
            : Icon(Icons.link, color: colorScheme.error),
        onPressed: () {
          setState(() {
            showPinyin = !showPinyin;
          });
        },
      ),
      IconButton(
        tooltip: PoemLocalizations.of(context).answer,
        iconSize: 16,
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
      ),
    ]);
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
      krctList
          .add(Character(titleCns[i], titleCnt[i], titlePy1[i], titlePy2[i]));
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
    return Padding(
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
                  c.pinyin1,
                  style: TextStyle(color: colorScheme.error),
                )),
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            color: colorScheme.secondary,
            child: Text(c.txtCns, style: const TextStyle(fontSize: 25)),
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
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const SizedBox(
            width: 120,
            height: 60,
          ), //使用sizedbox定位位置
          ...krctList.map((c) => genCharacter(c, colorScheme)).toList(),
          Container(
              width: 120,
              height: 60,
              alignment: Alignment.bottomRight,
              // color: colorScheme.secondary,
              child: genButtons(context, colorScheme)),
        ])),
        genEnRow(authorEn, colorScheme)
      ]))
    ]);
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
          colorScheme));
    }
    return rows;
  }

//生成一行诗句
  Widget genParagraphRow(
      rowIdx, rowCns, rowCnt, rowPy1, rowPy2, rowEn, colorScheme) {
    final kractsCns = rowCns.split("");
    final kractsCnt = rowCnt.split("");
    final pinyin1 = rowPy1.split(" ");
    final pinyin2 = rowPy2.split(" ");
    List<Character> krctList;
    if (rowsCharacters[rowIdx] == null) {
      krctList = [];
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
                          child: Text(
                            c.pinyin1,
                            style: TextStyle(color: colorScheme.error),
                          )),
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
                            child: Text(c.txtCns,
                                style: const TextStyle(fontSize: 25))),
                      );
                    },
                        // 当拖拽进入时，判断是否接受
                        onWillAccept: (s) {
                      return s == c.txtCns;
                    }, onAccept: (s) {
                      setState(() {
                        rowsCharacters = rowsCharacters;
                        c.visibable = true;
                        pickCharacters.remove(s);
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
                              return const AlertDialog(
                                title: Text("恭喜你"),
                                content: Text("拼接古诗成功！"),
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
                                fontSize: 10, color: colorScheme.secondary),
                          ))))))
    ]);
  }

  Widget _pickArea(colorScheme) {
    List<Widget> dragList = [];
    for (int i = 0; i < pickCharacters.length; i++) {
      var c = pickCharacters[i];
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
        ),
      );
      dragList.add(drag);
    }
    //"~/"运算符执行的是整数除法,也称为截断除法
    ////当两个操作数都是整数时,"~/"运算符将返回除法结果的整数部分,而忽略任何小数部分
    List<Widget> wrap1children = dragList.sublist(0, dragList.length ~/ 2);
    List<Widget> wrap2children = dragList.sublist(dragList.length ~/ 2);
    final ctrler = ScrollController(initialScrollOffset: 0);
    return Expanded(
        flex: 1,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.bottom,
          controller: ctrler,
          // 显示进度条
          child: SingleChildScrollView(
            controller: ctrler,
            scrollDirection: Axis.horizontal,
            // padding: const EdgeInsets.all(20.0),
            child: Container(
              alignment: Alignment.bottomCenter,
              color: colorScheme.background,
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Wrap(
                      spacing: 3,
                      // runSpacing: 10,
                      //动态创建一个List<Widget>
                      children: wrap1children,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Wrap(
                        spacing: 3,
                        // runSpacing: 10,
                        //动态创建一个List<Widget>
                        children: wrap2children,
                      ))
                ],
              ),
            ),
          ),
        ));
  }

// 生成抽屉菜单
  Widget genDrawItems() {
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
    );

    var button = TextButton.icon(
      onPressed: () => press(context),
      icon: const Icon(Icons.translate),
      label: const Text(""),
    );
    List<Widget> tileList = [];
    for (int i = 0; i < 13; i++) {
      checkList.add(false);
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
    final drawerItems = ListView(
      children: [
        drawerHeader,
        button,
        ...tileList,
      ],
    );
    return drawerItems;
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
        child: genDrawItems(),
      ),
      body: Container(
          padding: EdgeInsets.all(2),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                  flex: 4,
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
                                // genButtons(colorScheme),
                                genTitle(colorScheme),
                                genAuthor(context, colorScheme),
                                ...genParagraphs(context, colorScheme)
                              ],
                            ),
                          ])))),
              _pickArea(colorScheme),
            ],
          )),

      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => {
          setState(
            () {
              pickCharacters.clear();
              choosePoem = poemJson[Random().nextInt(poemJson.length)];
              for (var p in choosePoem['paragraphs_cns']) {
                for (var c in p.split("")) {
                  if (!isPunctuate(c)) {
                    pickCharacters.add(c);
                  }
                }
              }
              pickCharacters.shuffle();
              rowsCharacters.clear();
              //初始化固定长度数组
              rowsCharacters = []..length = choosePoem['paragraphs_cns'].length;
            },
          )
        },
        tooltip: PoemLocalizations.of(context).change,
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
