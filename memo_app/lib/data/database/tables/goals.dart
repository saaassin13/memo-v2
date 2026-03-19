import 'package:drift/drift.dart';

/// 目标表
class Goals extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 标题
  TextColumn get title => text()();

  /// 描述
  TextColumn get description => text().nullable()();

  /// 目标类型: daily/weekly/monthly/yearly/custom
  TextColumn get type => text()();

  /// 目标值
  IntColumn get targetValue => integer().withDefault(const Constant(1))();

  /// 当前进度
  IntColumn get currentValue => integer().withDefault(const Constant(0))();

  /// 单位
  TextColumn get unit => text().nullable()();

  /// 开始日期
  DateTimeColumn get startDate => dateTime()();

  /// 结束日期
  DateTimeColumn get endDate => dateTime().nullable()();

  /// 是否已完成
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
