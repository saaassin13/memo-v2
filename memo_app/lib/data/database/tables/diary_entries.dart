import 'package:drift/drift.dart';

/// 日记表
class DiaryEntries extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 日期
  DateTimeColumn get date => dateTime()();

  /// 标题
  TextColumn get title => text()();

  /// 内容
  TextColumn get content => text()();

  /// 心情 (happy, neutral, sad, etc.)
  TextColumn get mood => text().nullable()();

  /// 天气
  TextColumn get weather => text().nullable()();

  /// 图片路径列表 (JSON 存储)
  TextColumn get images => text().nullable()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
