import 'package:drift/drift.dart';

/// 交易记录表 (记账)
class Transactions extends Table {
  /// 唯一标识
  TextColumn get id => text()();

  /// 金额 (正数为收入，负数为支出)
  RealColumn get amount => real()();

  /// 类型: income/expense
  TextColumn get type => text()();

  /// 分类
  TextColumn get category => text()();

  /// 备注
  TextColumn get note => text().nullable()();

  /// 交易日期
  DateTimeColumn get date => dateTime()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
