import 'package:drift/drift.dart';

/// 倒数纪念日表
class Countdowns extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 标题
  TextColumn get title => text()();

  /// 目标日期
  DateTimeColumn get targetDate => dateTime()();

  /// 类型: countdown (倒数) / anniversary (纪念日)
  TextColumn get type => text()();

  /// 是否每年重复 (用于纪念日)
  BoolColumn get repeatYearly => boolean().withDefault(const Constant(false))();

  /// 是否开启提醒
  BoolColumn get remind => boolean().withDefault(const Constant(false))();

  /// 提前提醒时间（分钟），0=当天，1440=提前1天，4320=提前3天
  IntColumn get remindAdvance => integer().withDefault(const Constant(1440))();

  /// 图标
  TextColumn get icon => text().nullable()();

  /// 颜色 (十六进制)
  TextColumn get color => text().nullable()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
