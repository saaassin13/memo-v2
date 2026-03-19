import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 体重统计数据
class WeightStats {
  final double? currentWeight;
  final double? minWeight;
  final double? maxWeight;
  final double? averageWeight;
  final double? changeFromFirst;
  final int totalRecords;

  WeightStats({
    this.currentWeight,
    this.minWeight,
    this.maxWeight,
    this.averageWeight,
    this.changeFromFirst,
    required this.totalRecords,
  });
}

/// 体重记录仓库
class WeightRepository {
  final AppDatabase _db;

  WeightRepository(this._db);

  /// 获取所有体重记录
  Future<List<WeightRecord>> getAll() async {
    return (_db.select(_db.weightRecords)
          ..orderBy([(w) => OrderingTerm.desc(w.date)]))
        .get();
  }

  /// 获取最近的记录
  Future<List<WeightRecord>> getRecent({int limit = 30}) async {
    return (_db.select(_db.weightRecords)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(limit))
        .get();
  }

  /// 按日期范围获取
  Future<List<WeightRecord>> getByDateRange(
      DateTime start, DateTime end) async {
    return (_db.select(_db.weightRecords)
          ..where((w) => w.date.isBetweenValues(start, end))
          ..orderBy([(w) => OrderingTerm.asc(w.date)]))
        .get();
  }

  /// 按 ID 获取单个记录
  Future<WeightRecord?> getById(String id) async {
    return (_db.select(_db.weightRecords)..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取最新的记录
  Future<WeightRecord?> getLatest() async {
    return (_db.select(_db.weightRecords)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 插入新记录
  Future<void> insert(WeightRecordsCompanion record) async {
    await _db.into(_db.weightRecords).insert(record);
  }

  /// 更新记录
  Future<void> update(WeightRecord record) async {
    await (_db.update(_db.weightRecords)..where((w) => w.id.equals(record.id)))
        .write(
      WeightRecordsCompanion(
        weight: Value(record.weight),
        date: Value(record.date),
        note: Value(record.note),
      ),
    );
  }

  /// 删除记录
  Future<void> delete(String id) async {
    await (_db.delete(_db.weightRecords)..where((w) => w.id.equals(id))).go();
  }

  /// 获取统计数据
  Future<WeightStats> getStats() async {
    final records = await getAll();

    if (records.isEmpty) {
      return WeightStats(totalRecords: 0);
    }

    final weights = records.map((r) => r.weight).toList();
    final currentWeight = records.first.weight;
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final averageWeight = weights.reduce((a, b) => a + b) / weights.length;
    final firstWeight = records.last.weight;
    final changeFromFirst = currentWeight - firstWeight;

    return WeightStats(
      currentWeight: currentWeight,
      minWeight: minWeight,
      maxWeight: maxWeight,
      averageWeight: averageWeight,
      changeFromFirst: changeFromFirst,
      totalRecords: records.length,
    );
  }

  /// 监听所有记录变化
  Stream<List<WeightRecord>> watchAll() {
    return (_db.select(_db.weightRecords)
          ..orderBy([(w) => OrderingTerm.desc(w.date)]))
        .watch();
  }

  /// 监听最近的记录
  Stream<List<WeightRecord>> watchRecent({int limit = 30}) {
    return (_db.select(_db.weightRecords)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(limit))
        .watch();
  }
}
