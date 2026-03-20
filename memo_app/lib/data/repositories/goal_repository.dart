import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 目标仓库
class GoalRepository {
  final AppDatabase _db;

  GoalRepository(this._db);

  /// 获取所有目标
  Future<List<Goal>> getAll() async {
    return (_db.select(_db.goals)
          ..orderBy([
            (g) => OrderingTerm.asc(g.completed),
            (g) => OrderingTerm.asc(g.endDate),
            (g) => OrderingTerm.desc(g.createdAt),
          ]))
        .get();
  }

  /// 获取进行中的目标
  Future<List<Goal>> getActive() async {
    return (_db.select(_db.goals)
          ..where((g) => g.completed.equals(false))
          ..orderBy([
            (g) => OrderingTerm.asc(g.endDate),
            (g) => OrderingTerm.desc(g.createdAt),
          ]))
        .get();
  }

  /// 获取已完成的目标
  Future<List<Goal>> getCompleted() async {
    return (_db.select(_db.goals)
          ..where((g) => g.completed.equals(true))
          ..orderBy([(g) => OrderingTerm.desc(g.updatedAt)]))
        .get();
  }

  /// 按类型获取
  Future<List<Goal>> getByType(String type) async {
    return (_db.select(_db.goals)
          ..where((g) => g.type.equals(type))
          ..orderBy([
            (g) => OrderingTerm.asc(g.completed),
            (g) => OrderingTerm.asc(g.endDate),
          ]))
        .get();
  }

  /// 按 ID 获取单个目标
  Future<Goal?> getById(String id) async {
    return (_db.select(_db.goals)..where((g) => g.id.equals(id)))
        .getSingleOrNull();
  }

  /// 插入新目标
  Future<void> insert(GoalsCompanion goal) async {
    await _db.into(_db.goals).insert(goal);
  }

  /// 更新目标
  Future<void> update(Goal goal) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(goal.id))).write(
      GoalsCompanion(
        title: Value(goal.title),
        description: Value(goal.description),
        type: Value(goal.type),
        targetValue: Value(goal.targetValue),
        currentValue: Value(goal.currentValue),
        unit: Value(goal.unit),
        startDate: Value(goal.startDate),
        endDate: Value(goal.endDate),
        completed: Value(goal.completed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 更新进度，返回更新前的值
  Future<int> updateProgress(String id, int newValue) async {
    final goal =
        await (_db.select(_db.goals)..where((g) => g.id.equals(id))).getSingle();

    final previousValue = goal.currentValue;
    final isCompleted = newValue >= goal.targetValue;

    await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(
        currentValue: Value(newValue),
        completed: Value(isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return previousValue;
  }

  /// 增加进度
  Future<void> incrementProgress(String id, {int amount = 1}) async {
    final goal =
        await (_db.select(_db.goals)..where((g) => g.id.equals(id))).getSingle();

    final newValue = goal.currentValue + amount;
    await updateProgress(id, newValue);
  }

  /// 删除目标
  Future<void> delete(String id) async {
    await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
  }

  /// 监听所有目标变化
  Stream<List<Goal>> watchAll() {
    return (_db.select(_db.goals)
          ..orderBy([
            (g) => OrderingTerm.asc(g.completed),
            (g) => OrderingTerm.asc(g.endDate),
            (g) => OrderingTerm.desc(g.createdAt),
          ]))
        .watch();
  }

  /// 监听进行中的目标
  Stream<List<Goal>> watchActive() {
    return (_db.select(_db.goals)
          ..where((g) => g.completed.equals(false))
          ..orderBy([
            (g) => OrderingTerm.asc(g.endDate),
            (g) => OrderingTerm.desc(g.createdAt),
          ]))
        .watch();
  }
}
