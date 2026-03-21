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

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
