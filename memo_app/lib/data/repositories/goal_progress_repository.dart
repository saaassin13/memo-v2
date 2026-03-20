import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 目标进度记录仓库
class GoalProgressRepository {
  final AppDatabase _db;

  GoalProgressRepository(this._db);

  /// 获取指定目标的所有进度记录
  Future<List<GoalProgressRecord>> getByGoalId(String goalId) async {
    return (_db.select(_db.goalProgressRecords)
          ..where((r) => r.goalId.equals(goalId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();
  }

  /// 获取指定目标的最新 N 条进度记录
  Future<List<GoalProgressRecord>> getRecentByGoalId(
    String goalId, {
    int limit = 10,
  }) async {
    return (_db.select(_db.goalProgressRecords)
          ..where((r) => r.goalId.equals(goalId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
          ..limit(limit))
        .get();
  }

  /// 插入进度记录
  Future<void> insert(GoalProgressRecordsCompanion record) async {
    await _db.into(_db.goalProgressRecords).insert(record);
  }

  /// 删除指定目标的所有进度记录
  Future<void> deleteByGoalId(String goalId) async {
    await (_db.delete(_db.goalProgressRecords)
          ..where((r) => r.goalId.equals(goalId)))
        .go();
  }

  /// 删除单条进度记录
  Future<void> delete(String id) async {
    await (_db.delete(_db.goalProgressRecords)..where((r) => r.id.equals(id)))
        .go();
  }

  /// 监听指定目标的进度记录变化
  Stream<List<GoalProgressRecord>> watchByGoalId(String goalId) {
    return (_db.select(_db.goalProgressRecords)
          ..where((r) => r.goalId.equals(goalId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .watch();
  }
}
