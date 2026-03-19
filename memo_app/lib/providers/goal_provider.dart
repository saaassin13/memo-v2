import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/goal_repository.dart';
import 'database_provider.dart';

part 'goal_provider.g.dart';

const _uuid = Uuid();

/// GoalRepository Provider
@Riverpod(keepAlive: true)
GoalRepository goalRepository(GoalRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return GoalRepository(db);
}

/// 目标列表 Provider
@riverpod
class GoalList extends _$GoalList {
  @override
  Future<List<Goal>> build({bool? activeOnly}) async {
    final repo = ref.watch(goalRepositoryProvider);
    if (activeOnly == true) {
      return repo.getActive();
    }
    return repo.getAll();
  }

  /// 添加目标
  Future<void> add({
    required String title,
    String? description,
    required String type,
    int targetValue = 1,
    String? unit,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final repo = ref.read(goalRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(GoalsCompanion(
      id: Value(_uuid.v4()),
      title: Value(title),
      description: Value(description),
      type: Value(type),
      targetValue: Value(targetValue),
      currentValue: const Value(0),
      unit: Value(unit),
      startDate: Value(startDate),
      endDate: Value(endDate),
      completed: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 更新目标
  Future<void> updateGoal(Goal goal) async {
    final repo = ref.read(goalRepositoryProvider);
    await repo.update(goal);
    ref.invalidateSelf();
  }

  /// 更新进度
  Future<void> updateProgress(String id, int newValue) async {
    final repo = ref.read(goalRepositoryProvider);
    await repo.updateProgress(id, newValue);
    ref.invalidateSelf();
  }

  /// 增加进度
  Future<void> incrementProgress(String id, {int amount = 1}) async {
    final repo = ref.read(goalRepositoryProvider);
    await repo.incrementProgress(id, amount: amount);
    ref.invalidateSelf();
  }

  /// 删除目标
  Future<void> delete(String id) async {
    final repo = ref.read(goalRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 进行中的目标 Provider
@riverpod
Future<List<Goal>> activeGoals(ActiveGoalsRef ref) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getActive();
}

/// 已完成的目标 Provider
@riverpod
Future<List<Goal>> completedGoals(CompletedGoalsRef ref) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getCompleted();
}

/// 单个目标 Provider
@riverpod
Future<Goal?> goalById(GoalByIdRef ref, String id) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getById(id);
}

/// 按类型获取目标 Provider
@riverpod
Future<List<Goal>> goalsByType(GoalsByTypeRef ref, String type) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getByType(type);
}

/// 目标流 Provider
@riverpod
Stream<List<Goal>> goalsStream(GoalsStreamRef ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.watchAll();
}

/// 进行中目标流 Provider
@riverpod
Stream<List<Goal>> activeGoalsStream(ActiveGoalsStreamRef ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.watchActive();
}
