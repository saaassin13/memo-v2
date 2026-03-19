import 'package:drift/drift.dart';

/// 备忘录表
class Memos extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 标题
  TextColumn get title => text()();

  /// 内容
  TextColumn get content => text()();

  /// 分类
  TextColumn get category => text().withDefault(const Constant('生活'))();

  /// 是否置顶
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
