import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 交易分类配置
class CategoryConfig {
  /// 分类名称
  final String name;

  /// 分类图标
  final IconData icon;

  /// 分类颜色
  final Color color;

  const CategoryConfig({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// 支出分类配置
class ExpenseCategories {
  ExpenseCategories._();

  /// 餐饮
  static const food = CategoryConfig(
    name: '餐饮',
    icon: LucideIcons.utensils,
    color: Color(0xFFFF6B6B),
  );

  /// 交通
  static const transport = CategoryConfig(
    name: '交通',
    icon: LucideIcons.car,
    color: Color(0xFF4ECDC4),
  );

  /// 购物
  static const shopping = CategoryConfig(
    name: '购物',
    icon: LucideIcons.shoppingBag,
    color: Color(0xFFFFBE0B),
  );

  /// 娱乐
  static const entertainment = CategoryConfig(
    name: '娱乐',
    icon: LucideIcons.gamepad2,
    color: Color(0xFFA855F7),
  );

  /// 住房
  static const housing = CategoryConfig(
    name: '住房',
    icon: LucideIcons.home,
    color: Color(0xFF3B82F6),
  );

  /// 医疗
  static const medical = CategoryConfig(
    name: '医疗',
    icon: LucideIcons.heartPulse,
    color: Color(0xFFEC4899),
  );

  /// 教育
  static const education = CategoryConfig(
    name: '教育',
    icon: LucideIcons.graduationCap,
    color: Color(0xFF14B8A6),
  );

  /// 其他
  static const other = CategoryConfig(
    name: '其他',
    icon: LucideIcons.moreHorizontal,
    color: Color(0xFF6B7280),
  );

  /// 所有支出分类列表
  static const List<CategoryConfig> all = [
    food,
    transport,
    shopping,
    entertainment,
    housing,
    medical,
    education,
    other,
  ];

  /// 根据名称获取分类配置
  static CategoryConfig getByName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => other,
    );
  }
}

/// 收入分类配置
class IncomeCategories {
  IncomeCategories._();

  /// 工资
  static const salary = CategoryConfig(
    name: '工资',
    icon: LucideIcons.briefcase,
    color: Color(0xFF22C55E),
  );

  /// 奖金
  static const bonus = CategoryConfig(
    name: '奖金',
    icon: LucideIcons.gift,
    color: Color(0xFFF59E0B),
  );

  /// 投资
  static const investment = CategoryConfig(
    name: '投资',
    icon: LucideIcons.trendingUp,
    color: Color(0xFF3B82F6),
  );

  /// 礼金
  static const gift = CategoryConfig(
    name: '礼金',
    icon: LucideIcons.heart,
    color: Color(0xFFEC4899),
  );

  /// 其他
  static const other = CategoryConfig(
    name: '其他',
    icon: LucideIcons.moreHorizontal,
    color: Color(0xFF6B7280),
  );

  /// 所有收入分类列表
  static const List<CategoryConfig> all = [
    salary,
    bonus,
    investment,
    gift,
    other,
  ];

  /// 根据名称获取分类配置
  static CategoryConfig getByName(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => other,
    );
  }
}

/// 获取分类配置（根据类型和名称）
CategoryConfig getCategoryConfig(String type, String category) {
  if (type == 'income') {
    return IncomeCategories.getByName(category);
  }
  return ExpenseCategories.getByName(category);
}

/// 图表颜色列表
const List<Color> chartColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFFFFBE0B),
  Color(0xFFA855F7),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFF14B8A6),
  Color(0xFF6B7280),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
];
