import 'package:drift/drift.dart';

/// 目标进度记录表
class GoalProgressRecords extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 关联的目标 ID
  TextColumn get goalId => text()();

  /// 更新前的进度
  IntColumn get previousValue => integer()();

  /// 更新后的进度
  IntColumn get newValue => integer()();

  /// 变化量 (+/-)
  IntColumn get change => integer()();

  /// 备注
  TextColumn get note => text().nullable()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
