import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/weight_repository.dart';
import 'database_provider.dart';

part 'weight_provider.g.dart';

const _uuid = Uuid();

/// WeightRepository Provider
@Riverpod(keepAlive: true)
WeightRepository weightRepository(WeightRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return WeightRepository(db);
}

/// 体重记录列表 Provider
@riverpod
class WeightList extends _$WeightList {
  @override
  Future<List<WeightRecord>> build({int? limit}) async {
    final repo = ref.watch(weightRepositoryProvider);
    if (limit != null) {
      return repo.getRecent(limit: limit);
    }
    return repo.getAll();
  }

  /// 添加体重记录
  Future<void> add({
    required double weight,
    required DateTime date,
    String? note,
  }) async {
    final repo = ref.read(weightRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(WeightRecordsCompanion(
      id: Value(_uuid.v4()),
      weight: Value(weight),
      date: Value(date),
      note: Value(note),
      createdAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 更新体重记录
  Future<void> updateRecord(WeightRecord record) async {
    final repo = ref.read(weightRepositoryProvider);
    await repo.update(record);
    ref.invalidateSelf();
  }

  /// 删除体重记录
  Future<void> delete(String id) async {
    final repo = ref.read(weightRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 最近体重记录 Provider
@riverpod
Future<List<WeightRecord>> recentWeights(RecentWeightsRef ref, {int limit = 30}) async {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.getRecent(limit: limit);
}

/// 最新体重记录 Provider
@riverpod
Future<WeightRecord?> latestWeight(LatestWeightRef ref) async {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.getLatest();
}

/// 体重统计 Provider
@riverpod
Future<WeightStats> weightStats(WeightStatsRef ref) async {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.getStats();
}

/// 按日期范围获取体重记录 Provider
@riverpod
Future<List<WeightRecord>> weightsByDateRange(
    WeightsByDateRangeRef ref, DateTime start, DateTime end) async {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.getByDateRange(start, end);
}

/// 体重记录流 Provider
@riverpod
Stream<List<WeightRecord>> weightsStream(WeightsStreamRef ref) {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.watchAll();
}

/// 最近体重记录流 Provider
@riverpod
Stream<List<WeightRecord>> recentWeightsStream(RecentWeightsStreamRef ref, {int limit = 30}) {
  final repo = ref.watch(weightRepositoryProvider);
  return repo.watchRecent(limit: limit);
}
