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
      'title': 'Chinese Poems Puzzle',
      'homePage': 'Chinese Poems Home Page',
      'grade.0': '300 Tang poems',
      'grade.1': '1st Grade',
      'grade.2': '2nd Grade',
      'grade.3': '3th Grade',
      'grade.4': '4th Grade',
      'grade.5': '5th Grade',
      'grade.6': '6th Grade',
      'grade.7': '7th Grade',
      'grade.8': '8th Grade',
      'grade.9': '9th Grade',
      'grade.10': '10th Grade',
      'grade.11': '11th Grade',
      'grade.12': '12th Grade',
      'change': 'Change a Poem',
      'english': 'English',
      'pinyin': 'Pinyin',
      'answer': 'Answer',
      'language': '中文',
      'simplified': 'Simplified',
      'traditional': 'Traditional',
      'pinyin_style': 'Pinyin Style',
      'congratulations': 'Congratulations',
      'succeed': 'You made it!',
      'next': 'Next Charactor',
      'random': 'Randomly display some Charactors',
      'about': 'About',
      'pick': 'Drag characters to the correct position',
      'aboutLine1':
          'This is a jigsaw puzzle game for Chinese ancient poetry. You can check your mastery of Chinese characters and ancient poetry through the game, hoping to help beginners of Chinese characters and ancient poetry. If you are an expert in Chinese characters and ancient poetry, I also hope you can have fun from it.',
      'aboutLine2':
          'The data for 300 Tang poems comes from the website of the University of Virginia Library https://cti.lib.virginia.edu/frame.htm',
      'aboutLine3':
          'The data on ancient poetry in textbooks comes from https://github.com/chinese-poetry/huajianji ',
      'aboutLine4':
          'The pinyin of all Chinese characters is generated through pypinyin, and the English translation of ancient poems in textbooks is generated through Baidu Translate. There are many inaccuracies, for reference only.',
      'aboutLine5':
          'If you have any questions or suggestions about this application, please contact me. :)\n email:stardust1900@hotmail.com\n weibo:@君敕',
    },
    'zh': {
      'title': '拼拼古诗',
      'homePage': '中国古诗首页',
      'grade.0': '唐诗300首',
      'grade.1': '小学一年级',
      'grade.2': '小学二年级',
      'grade.3': '小学三年级',
      'grade.4': '小学四年级',
      'grade.5': '小学五年级',
      'grade.6': '小学六年级',
      'grade.7': '初一',
      'grade.8': '初二',
      'grade.9': '初三',
      'grade.10': '高一',
      'grade.11': '高二',
      'grade.12': '高三',
      'change': '换一首',
      'english': '英语',
      'pinyin': '拼音',
      'answer': '答案',
      'language': 'English',
      'simplified': '简体',
      'traditional': '繁体',
      'pinyin_style': '拼音风格',
      'congratulations': '恭喜你',
      'succeed': '拼接古诗成功！',
      'next': '下一个字',
      'random': '随机显示一些字',
      'about': '关于',
      'pick': '把汉字拖到正确位置',
      'aboutLine1':
          '这是一个中国古诗的拼图游戏，您可以通过游戏来检查自己对汉字和古诗的掌握程度，希望可以帮助初学汉字和初学古诗的人，如果你是汉字和古诗的专家也希望你可以从中获得乐趣。',
      'aboutLine2':
          '唐诗300首的数据来自维吉尼亚大学图书馆网站 https://cti.lib.virginia.edu/frame.htm',
      'aboutLine3': '教科书中古诗的数据来自 https://github.com/chinese-poetry/huajianji ',
      'aboutLine4':
          '所有汉字的拼音是通过pypinyin生成的，教科书中古诗的英文翻译是通过百度翻译生成的，有很多不准确的地方，仅供参考。',
      'aboutLine5':
          '如果你对这个应用有什么问题或者建议，请联系我 :)\n email:stardust1900@hotmail.com\n 微博:@君敕',
    },
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String get title {
    return _localizedValues[locale.languageCode]!['title']!;
  }

  String get homePage {
    return _localizedValues[locale.languageCode]!['homePage']!;
  }

  String getGrade(int num) {
    return _localizedValues[locale.languageCode]!['grade.$num']!;
  }

  String get change {
    return _localizedValues[locale.languageCode]!['change']!;
  }

  String get english {
    return _localizedValues[locale.languageCode]!['english']!;
  }

  String get pinyin {
    return _localizedValues[locale.languageCode]!['pinyin']!;
  }

  String get answer {
    return _localizedValues[locale.languageCode]!['answer']!;
  }

  String get language {
    return _localizedValues[locale.languageCode]!['language']!;
  }

  String get simplified {
    return _localizedValues[locale.languageCode]!['simplified']!;
  }

  String get traditional {
    return _localizedValues[locale.languageCode]!['traditional']!;
  }

  String get pinyinStyle {
    return _localizedValues[locale.languageCode]!['pinyin_style']!;
  }

  String get congratulations {
    return _localizedValues[locale.languageCode]!['congratulations']!;
  }

  String get succeed {
    return _localizedValues[locale.languageCode]!['succeed']!;
  }

  String get next {
    return _localizedValues[locale.languageCode]!['next']!;
  }

  String get random {
    return _localizedValues[locale.languageCode]!['random']!;
  }

  String get about {
    return _localizedValues[locale.languageCode]!['about']!;
  }

  String get pick {
    return _localizedValues[locale.languageCode]!['pick']!;
  }

  String get aboutLine1 {
    return _localizedValues[locale.languageCode]!['aboutLine1']!;
  }

  String get aboutLine2 {
    return _localizedValues[locale.languageCode]!['aboutLine2']!;
  }

  String get aboutLine3 {
    return _localizedValues[locale.languageCode]!['aboutLine3']!;
  }

  String get aboutLine4 {
    return _localizedValues[locale.languageCode]!['aboutLine4']!;
  }

  String get aboutLine5 {
    return _localizedValues[locale.languageCode]!['aboutLine5']!;
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
