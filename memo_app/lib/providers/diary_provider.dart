import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/diary_repository.dart';
import 'database_provider.dart';

part 'diary_provider.g.dart';

const _uuid = Uuid();

/// DiaryRepository Provider
@Riverpod(keepAlive: true)
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return DiaryRepository(db);
}

/// 日记列表 Provider
@riverpod
class DiaryList extends _$DiaryList {
  @override
  Future<List<DiaryEntry>> build({int? year, int? month}) async {
    final repo = ref.watch(diaryRepositoryProvider);
    if (year != null && month != null) {
      return repo.getByMonth(year, month);
    }
    return repo.getAll();
  }

  /// 添加日记
  Future<void> add({
    required DateTime date,
    required String title,
    required String content,
    String? mood,
    String? weather,
    String? images,
  }) async {
    final repo = ref.read(diaryRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(DiaryEntriesCompanion(
      id: Value(_uuid.v4()),
      date: Value(date),
      title: Value(title),
      content: Value(content),
      mood: Value(mood),
      weather: Value(weather),
      images: Value(images),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 更新日记
  Future<void> updateEntry(DiaryEntry entry) async {
    final repo = ref.read(diaryRepositoryProvider);
    await repo.update(entry);
    ref.invalidateSelf();
  }

  /// 删除日记
  Future<void> delete(String id) async {
    final repo = ref.read(diaryRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 按日期获取日记 Provider
@riverpod
Future<DiaryEntry?> diaryByDate(DiaryByDateRef ref, DateTime date) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.getByDate(date);
}

/// 单个日记 Provider
@riverpod
Future<DiaryEntry?> diaryById(DiaryByIdRef ref, String id) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.getById(id);
}

/// 有日记的日期列表 Provider
@riverpod
Future<List<DateTime>> diaryDates(DiaryDatesRef ref, int year, int month) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.getDatesWithEntries(year, month);
}

/// 搜索日记 Provider
@riverpod
Future<List<DiaryEntry>> searchDiaries(SearchDiariesRef ref, String query) async {
  if (query.isEmpty) {
    return [];
  }
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.search(query);
}

/// 日记流 Provider
@riverpod
Stream<List<DiaryEntry>> diariesStream(DiariesStreamRef ref) {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.watchAll();
}
