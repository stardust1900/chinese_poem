// 朱红、珊瑚、琉璃、毛月、藏青、赭石
import 'package:flutter/material.dart';

final ColorScheme chineseStyle1 = ColorScheme.fromSeed(
  seedColor: const Color(0xFFE60012), // 朱红
  primary: const Color(0xFFE60012), // 朱红
  secondary: const Color(0xFFE60012), // 朱红
  brightness: Brightness.light,
  surfaceVariant: const Color(0xFFE60012), // 朱红
  background: const Color(0xFFF5F5F5), // 白色
  error: const Color(0xFFB22222), // 火砖
  onPrimary: const Color(0xFFFFFFFF), // 白色
  onSecondary: const Color(0xFFFFFFFF), // 白色
  onSurface: const Color(0xFFFFFFFF), // 白色
  onBackground: const Color(0xFF000000), // 黑色
  onError: const Color(0xFFFFFFFF), // 白色
);

// 莫兰迪色系
final ColorScheme chineseStyle2 = ColorScheme.fromSeed(
  seedColor: Color(0xFF7C8483), // 灰绿
  primary: Color(0xFF7C8483), // 灰绿
  secondary: Color(0xFF7C8483), // 灰绿
  brightness: Brightness.light,
  surfaceVariant: Color(0xFF7C8483), // 灰绿
  background: Color(0xFFF5F5F5), // 白色
  error: Color(0xFFB22222), // 火砖
  onPrimary: Color(0xFFFFFFFF), // 白色
  onSecondary: Color(0xFFFFFFFF), // 白色
  onSurface: Color(0xFFFFFFFF), // 白色
  onBackground: Color(0xFF000000), // 黑色
  onError: Color(0xFFFFFFFF), // 白色
);

// 马卡龙色系
final ColorScheme chineseStyle3 = ColorScheme.fromSeed(
  seedColor: Color(0xFFE0BBE4), // 淡紫
  primary: Color(0xFFE0BBE4), // 淡紫
  secondary: Color(0xFFE0BBE4), // 淡紫
  brightness: Brightness.light,
  surfaceVariant: Color(0xFFE0BBE4), // 淡紫
  background: Color(0xFFF5F5F5), // 白色
  error: Color(0xFFB22222), // 火砖
  onPrimary: Color(0xFFFFFFFF), // 白色
  onSecondary: Color(0xFFFFFFFF), // 白色
  onSurface: Color(0xFFFFFFFF), // 白色
  onBackground: Color(0xFF000000), // 黑色
  onError: Color(0xFFFFFFFF), // 白色
);

// 穆夏配色
final ColorScheme chineseStyle4 = ColorScheme.fromSeed(
  seedColor: Color(0xFFEFA8B8), // 粉红
  primary: Color(0xFFEFA8B8), // 粉红
  secondary: Color(0xFFEFA8B8), // 粉红
  brightness: Brightness.light,
  surfaceVariant: Color(0xFFEFA8B8), // 粉红
  background: Color(0xFFF5F5F5), // 白色
  error: Color(0xFFB22222), // 火砖
  onPrimary: Color(0xFFFFFFFF), // 白色
  onSecondary: Color(0xFFFFFFFF), // 白色
  onSurface: Color(0xFFFFFFFF), // 白色
  onBackground: Color(0xFF000000), // 黑色
  onError: Color(0xFFFFFFFF), // 白色
);

// 宫崎骏配色
final ColorScheme chineseStyle5 = ColorScheme.fromSeed(
  seedColor: Color(0xFF0095C8), // 天蓝
  primary: Color(0xFF0095C8), // 天蓝
  secondary: Color(0xFF0095C8), // 天蓝
  brightness: Brightness.light,
  surfaceVariant: Color(0xFF0095C8), // 天蓝
  background: Color(0xFFF5F5F5), // 白色
  error: Color(0xFFB22222), // 火砖
  onPrimary: Color(0xFFFFFFFF), // 白色
  onSecondary: Color(0xFFFFFFFF), // 白色
  onSurface: Color(0xFFFFFFFF), // 白色
  onBackground: Color(0xFF000000), // 黑色
  onError: Color(0xFFFFFFFF), // 白色
);

// 浮世绘风格
final ColorScheme chineseStyle6 = ColorScheme.fromSeed(
  seedColor: Color(0xFFE60012), // 朱红
  primary: Color(0xFFE60012), // 朱红
  secondary: Color(0xFFE60012), // 朱红
  brightness: Brightness.light,
  surfaceVariant: Color(0xFFE60012), // 朱红
  background: Color(0xFFF5F5F5), // 白色
  error: Color(0xFFB22222), // 火砖
  onPrimary: Color(0xFFFFFFFF), // 白色
  onSecondary: Color(0xFFFFFFFF), // 白色
  onSurface: Color(0xFFFFFFFF), // 白色
  onBackground: Color(0xFF000000), // 黑色
  onError: Color(0xFFFFFFFF), // 白色
);

// https://pixso.cn/designskills/traditional-chinese-color-matching/
// 以赭石为主色，搭配朱红、珊瑚、琉璃等暖色调，营造出富贵、喜庆的氛围
final ColorScheme chineseStyle7 = ColorScheme.fromSeed(
  seedColor: Color(0xFFB35C44), // 朱红
  primary: Color(0xFFB35C44), // 赭石
  primaryContainer: Color(0xFF9F4F3A),
  secondary: Color(0xFFE43F3F), // 朱红
  secondaryContainer: Color(0xFFD32F2F),
  surface: Color(0xFFF5F5F5),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFFFFFFFF),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);
// 以赭石为主色，搭配藏青、毛月、翠绿等冷色调，营造出清新、自然的氛围
final ColorScheme chineseStyle8 = ColorScheme.fromSeed(
  seedColor: Color(0xFFB35C44), // 赭石
  primary: Color(0xFF9F4F3A),
  secondary: Color(0xFF183152), // 藏青
  secondaryContainer: Color(0xFF10203A),
  surface: Color(0xFFF5F5F5),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFFFFFFFF),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);

// 以赭石为主色，搭配藤黄、檀香、苍绿等中性色调，营造出古朴、稳重的氛围
final ColorScheme chineseStyle9 = ColorScheme.fromSeed(
  seedColor: Color(0xFFB35C44), // 赭石
  primary: Color(0xFF9F4F3A),
  secondary: Color(0xFFE9BB1D), // 藤黄
  secondaryContainer: Color(0xFFD8A60C),
  surface: Color(0xFFF5F5F5),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFF000000),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);

// 以赭石为主色，搭配紫罗兰、莹白、玫瑰等柔和色调，营造出优雅、浪漫的氛围
final ColorScheme chineseStyle10 = ColorScheme.fromSeed(
  seedColor: Color(0xFFC06C84), // 赭石
  primary: Color(0xFF6C5B7B),
  secondary: Color(0xFFF8B195), // 紫罗兰
  secondaryContainer: Color(0xFF355C7D),
  surface: Color(0xFFF67280),
  background: Color(0xFFC06C84),
  error: Color(0xFFC06C84),
  onPrimary: Color(0xFFFFFFFF), // 莹白
  onSecondary: Color(0xFFFFFFFF),
  onSurface: Color(0xFFFFFFFF),
  onBackground: Color(0xFFFFFFFF),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);
// 以赭石为主色，搭配金黄、橙红、深褐等鲜艳色调，营造出热情、活力的氛围 。
final ColorScheme chineseStyle11 = ColorScheme.fromSeed(
  seedColor: Color(0xFFE07A5F), // 赭石
  primary: Color(0xFF3D405B),
  secondary: Color(0xFFF4F1DE), // 金黄
  secondaryContainer: Color(0xFF81B29A),
  surface: Color(0xFFF2CC8F),
  background: Color(0xFFE07A5F),
  error: Color(0xFFE07A5F),
  onPrimary: Color(0xFFF2CC8F), // 橙红
  onSecondary: Color(0xFFE07A5F),
  onSurface: Color(0xFFE07A5F),
  onBackground: Color(0xFFE07A5F),
  onError: Color(0xFFE07A5F),
  brightness: Brightness.light,
);
//  一种是以赭石为主色，搭配灰白、墨黑、银灰等简约色调，营造出现代、简洁的氛围 。
final ColorScheme chineseStyle12 = ColorScheme.fromSeed(
  seedColor: Color(0xFFBDBDBD), // 赭石
  primary: Color(0xFF757575),
  secondary: Color(0xFFFFFFFF), // 灰白
  secondaryContainer: Color(0xFFEEEEEE),
  surface: Color(0xFFE0E0E0),
  background: Color(0xFFBDBDBD),
  error: Color(0xFFBDBDBD),
  onPrimary: Color(0xFF212121), // 墨黑
  onSecondary: Color(0xFF212121),
  onSurface: Color(0xFF212121),
  onBackground: Color(0xFF212121),
  onError: Color(0xFF212121),
  brightness: Brightness.light,
);
// 以赭石为主色，搭配紫罗兰、莹白、玫瑰等柔和色调，营造出优雅、浪漫的氛围
final ColorScheme chineseStyle13 = ColorScheme.fromSeed(
  seedColor: Color(0xFFC07A6A), // 赭石
  primary: Color(0xFF9E655F),
  secondary: Color(0xFF9F87AF), // 紫罗兰
  secondaryContainer: Color(0xFF8A759D),
  surface: Color(0xFFF2F2F2),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFFFFFFF), // 莹白
  onSecondary: Color(0xFF000000),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);
// 以赭石为主色，搭配金黄、橙红、深褐等鲜艳色调，营造出热情、活力的氛围
final ColorScheme chineseStyle14 = ColorScheme.fromSeed(
  seedColor: Color(0xFFC07A6A), // 赭石
  primary: Color(0xFF9E655F),
  secondary: Color(0xFFF9C74F), // 金黄
  secondaryContainer: Color(0xFFE9B44C),
  surface: Color(0xFFF2F2F2),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFF94144), // 橙红
  onSecondary: Color(0xFF000000),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);
// 以赭石为主色，搭配灰白、墨黑、银灰等简约色调，营造出现代、简洁的氛围
final ColorScheme chineseStyle15 = ColorScheme.fromSeed(
  seedColor: Color(0xFFC07A6A), // 赭石
  primary: Color(0xFF9E655F),
  secondary: Color(0xFFE5E5E5), // 灰白
  tertiary: Color(0xFF81B29A),
  secondaryContainer: Color(0xFFD4D4D4),
  surface: Color(0xFFF2F2F2),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFF000000), // 墨黑
  onSecondary: Color(0xFF000000),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
  outline: Color(0xFFF9C74F),
);
