import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// #docregion Demo
class DemoLocalizations {
  DemoLocalizations(this.locale);

  final Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'title': 'Hello World',
    },
    'es': {
      'title': 'Hola Mundo',
    },
    'zh': {
      'title': '你好 世界',
    },
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }
}
// #enddocregion Demo

// #docregion Delegate
class DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      DemoLocalizations.languages().contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<DemoLocalizations>(DemoLocalizations(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
// #enddocregion Delegate

class DemoApp extends StatelessWidget {
  final changeLocale;
  final currentLocale;
  const DemoApp({super.key, this.currentLocale, this.changeLocale});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).title),
      ),
      body: Center(
          child: Flex(
        direction: Axis.vertical,
        children: [
          Text(DemoLocalizations.of(context).title),
          TextButton.icon(
              onPressed: press,
              icon: const Icon(Icons.refresh),
              label: Text(DemoLocalizations.of(context).title)),
        ],
      )),
    );
  }

  void press() {
    print(currentLocale.languageCode);
    if ("zh" == currentLocale.languageCode) {
      changeLocale(const Locale('en', ''));
    } else {
      changeLocale(const Locale('zh', ''));
    }
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DemoState();
  }
}

class _DemoState extends State<Demo> {
  Locale? lcl;
  @override
  Widget build(BuildContext context) {
    lcl ??= PlatformDispatcher.instance.locale;
    return MaterialApp(
      locale: lcl,
      onGenerateTitle: (context) => DemoLocalizations.of(context).title,
      localizationsDelegates: const [
        DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, //增加中文支持时需要增加这一句
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      // Watch out: MaterialApp creates a Localizations widget
      // with the specified delegates. DemoLocalizations.of()
      // will only find the app's Localizations widget if its
      // context is a child of the app.
      home: DemoApp(
          currentLocale: lcl, changeLocale: (locale) => _changeLocale(locale)),
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
