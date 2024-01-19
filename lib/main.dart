import 'dart:ui';

import 'package:chinese_poems/poem_i18n.dart';
import 'package:chinese_poems/poem_theme.dart';
import 'package:flutter/material.dart';
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
  int _counter = 0;
  final changeLocale;
  bool checked1 = false;
  bool checked2 = false;
  _MyHomePageState(this.changeLocale);

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    String titleText = PoemLocalizations.of(context).title;
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
    final drawerItems = ListView(
      children: [
        drawerHeader,
        button,
        ListTile(
          title: Text(
            PoemLocalizations.of(context).getGrade(1),
          ),
          leading: checked1
              ? const Icon(Icons.check_circle)
              : const Icon(Icons.check_circle_outline),
          onTap: () {
            setState(() {
              checked1 = !checked1;
            });
          },
        ),
        ListTile(
          title: Text(
            PoemLocalizations.of(context).getGrade(2),
          ),
          leading: checked2
              ? const Icon(Icons.check_circle)
              : const Icon(Icons.check_circle_outline),
          onTap: () {
            setState(() {
              checked2 = !checked2;
            });
          },
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        child: drawerItems,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              PoemLocalizations.of(context).homePage,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
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
