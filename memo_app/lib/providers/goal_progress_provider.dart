import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/goal_progress_repository.dart';
import 'database_provider.dart';

part 'goal_progress_provider.g.dart';

const _uuid = Uuid();

/// GoalProgressRepository Provider
@Riverpod(keepAlive: true)
GoalProgressRepository goalProgressRepository(GoalProgressRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return GoalProgressRepository(db);
}

/// 目标进度记录列表 Provider
@riverpod
class GoalProgressList extends _$GoalProgressList {
  @override
  Future<List<GoalProgressRecord>> build(String goalId) async {
    final repo = ref.watch(goalProgressRepositoryProvider);
    return repo.getByGoalId(goalId);
  }

  /// 添加进度记录
  Future<void> add({
    required String goalId,
    required int previousValue,
    required int newValue,
    String? note,
  }) async {
    final repo = ref.read(goalProgressRepositoryProvider);
    final change = newValue - previousValue;
    final now = DateTime.now();

    await repo.insert(GoalProgressRecordsCompanion(
      id: Value(_uuid.v4()),
      goalId: Value(goalId),
      previousValue: Value(previousValue),
      newValue: Value(newValue),
      change: Value(change),
      note: Value(note),
      createdAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 删除进度记录
  Future<void> delete(String id) async {
    final repo = ref.read(goalProgressRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  /// 删除目标的所有进度记录
  Future<void> deleteAllForGoal(String goalId) async {
    final repo = ref.read(goalProgressRepositoryProvider);
    await repo.deleteByGoalId(goalId);
    ref.invalidateSelf();
  }
}

/// 目标进度记录流 Provider
@riverpod
Stream<List<GoalProgressRecord>> goalProgressStream(
  GoalProgressStreamRef ref,
  String goalId,
) {
  final repo = ref.watch(goalProgressRepositoryProvider);
  return repo.watchByGoalId(goalId);
}

/// 最近进度记录 Provider
@riverpod
Future<List<GoalProgressRecord>> recentGoalProgress(
  RecentGoalProgressRef ref,
  String goalId, {
  int limit = 10,
}) async {
  final repo = ref.watch(goalProgressRepositoryProvider);
  return repo.getRecentByGoalId(goalId, limit: limit);
}
