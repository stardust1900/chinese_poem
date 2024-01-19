import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PoemLocalizations {
  PoemLocalizations(this.locale);

  final Locale locale;

  static PoemLocalizations of(BuildContext context) {
    return Localizations.of<PoemLocalizations>(context, PoemLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'title': 'Chinese Poems',
      'homePage': 'Chinese Poems Home Page',
    },
    'zh': {
      'title': '中国古诗',
      'homePage': '中国古诗首页',
    },
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }

  String get homePage {
    return _localizedValues[locale.languageCode]!['homePage']!;
  }
}

class PoemLocalizationsDelegate
    extends LocalizationsDelegate<PoemLocalizations> {
  const PoemLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      PoemLocalizations.languages().contains(locale.languageCode);

  @override
  Future<PoemLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<PoemLocalizations>(PoemLocalizations(locale));
  }

  @override
  bool shouldReload(PoemLocalizationsDelegate old) => false;
}
