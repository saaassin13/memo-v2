import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/colors.dart';

/// Todo categories
class TodoCategories {
  static const all = '全部';
  static const work = '工作';
  static const life = '生活';
  static const study = '学习';
  static const misc = '杂项';

  static const list = [all, work, life, study, misc];
  static const listWithoutAll = [work, life, study, misc];
}

/// Memo categories
class MemoCategories {
  static const all = '全部';
  static const work = '工作';
  static const life = '生活';
  static const study = '学习';

  static const list = [all, work, life, study];
  static const listWithoutAll = [work, life, study];
}

/// Category colors mapping
Map<String, Color> getCategoryColor(BuildContext context) {
  return {
    '工作': AppColors.chart1,
    '生活': AppColors.accent,
    '学习': AppColors.chart3,
    '杂项': AppColors.mutedForeground,
  };
}

/// Weather options
enum Weather {
  sunny('sunny', '晴天', LucideIcons.sun),
  cloudy('cloudy', '多云', LucideIcons.cloud),
  rainy('rainy', '雨天', LucideIcons.cloudRain),
  snowy('snowy', '雪天', LucideIcons.cloudSnow),
  thunder('thunder', '雷雨', LucideIcons.cloudLightning),
  windy('windy', '大风', LucideIcons.wind);

  final String value;
  final String label;
  final IconData icon;

  const Weather(this.value, this.label, this.icon);

  static Weather fromValue(String value) {
    return Weather.values.firstWhere(
      (w) => w.value == value,
      orElse: () => Weather.sunny,
    );
  }
}

/// Mood options
enum Mood {
  happy('happy', '开心', '😊'),
  joy('joy', '喜悦', '😄'),
  love('love', '爱', '❤️'),
  calm('calm', '平静', '😌'),
  sad('sad', '难过', '😢'),
  angry('angry', '愤怒', '😠');

  final String value;
  final String label;
  final String emoji;

  const Mood(this.value, this.label, this.emoji);

  static Mood fromValue(String value) {
    return Mood.values.firstWhere(
      (m) => m.value == value,
      orElse: () => Mood.happy,
    );
  }
}

/// Countdown categories
class CountdownCategories {
  static const birthday = 'birthday';
  static const holiday = 'holiday';
  static const important = 'important';

  static const list = [birthday, holiday, important];

  static String getLabel(String value) {
    switch (value) {
      case birthday:
        return '生日';
      case holiday:
        return '节日';
      case important:
        return '重要日';
      default:
        return '其他';
    }
  }
}

/// Transaction types
class TransactionTypes {
  static const income = 'income';
  static const expense = 'expense';
}

/// Expense categories
class ExpenseCategories {
  static const food = '餐饮';
  static const transport = '交通';
  static const shopping = '购物';
  static const entertainment = '娱乐';
  static const housing = '住房';
  static const medical = '医疗';
  static const education = '教育';
  static const other = '其他';

  static const list = [
    food,
    transport,
    shopping,
    entertainment,
    housing,
    medical,
    education,
    other,
  ];
}

/// Income categories
class IncomeCategories {
  static const salary = '工资';
  static const bonus = '奖金';
  static const investment = '投资';
  static const gift = '礼金';
  static const other = '其他';

  static const list = [salary, bonus, investment, gift, other];
}

/// Spacing constants
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

/// Radius constants
class AppRadius {
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const full = 9999.0;
}
