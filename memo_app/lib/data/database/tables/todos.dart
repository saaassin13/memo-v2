import 'package:drift/drift.dart';

/// 待办事项表
class Todos extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 标题
  TextColumn get title => text()();

  /// 分类
  TextColumn get category => text().withDefault(const Constant('杂项'))();

  /// 截止日期
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// 备注
  TextColumn get note => text().nullable()();

  /// 是否已完成
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// 是否开启提醒
  BoolColumn get remind => boolean().withDefault(const Constant(false))();

  /// 提前提醒时间（分钟），0=当天，1440=提前1天，4320=提前3天
  IntColumn get remindAdvance => integer().withDefault(const Constant(1440))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
