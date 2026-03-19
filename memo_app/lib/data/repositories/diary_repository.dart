import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 日记仓库
class DiaryRepository {
  final AppDatabase _db;

  DiaryRepository(this._db);

  /// 获取所有日记
  Future<List<DiaryEntry>> getAll() async {
    return (_db.select(_db.diaryEntries)
          ..orderBy([(d) => OrderingTerm.desc(d.date)]))
        .get();
  }

  /// 按日期获取
  Future<DiaryEntry?> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.diaryEntries)
          ..where((d) => d.date.isBetweenValues(start, end)))
        .getSingleOrNull();
  }

  /// 按月份获取
  Future<List<DiaryEntry>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (_db.select(_db.diaryEntries)
          ..where((d) => d.date.isBetweenValues(start, end))
          ..orderBy([(d) => OrderingTerm.desc(d.date)]))
        .get();
  }

  /// 按 ID 获取单个日记
  Future<DiaryEntry?> getById(String id) async {
    return (_db.select(_db.diaryEntries)..where((d) => d.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取有日记的日期列表
  Future<List<DateTime>> getDatesWithEntries(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final entries = await (_db.select(_db.diaryEntries)
          ..where((d) => d.date.isBetweenValues(start, end)))
        .get();
    return entries.map((e) => e.date).toList();
  }

  /// 搜索日记
  Future<List<DiaryEntry>> search(String query) async {
    final pattern = '%$query%';
    return (_db.select(_db.diaryEntries)
          ..where((d) =>
              d.title.like(pattern) |
              d.content.like(pattern))
          ..orderBy([(d) => OrderingTerm.desc(d.date)]))
        .get();
  }

  /// 插入新日记
  Future<void> insert(DiaryEntriesCompanion entry) async {
    await _db.into(_db.diaryEntries).insert(entry);
  }

  /// 更新日记
  Future<void> update(DiaryEntry entry) async {
    await (_db.update(_db.diaryEntries)..where((d) => d.id.equals(entry.id)))
        .write(
      DiaryEntriesCompanion(
        date: Value(entry.date),
        title: Value(entry.title),
        content: Value(entry.content),
        mood: Value(entry.mood),
        weather: Value(entry.weather),
        images: Value(entry.images),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 删除日记
  Future<void> delete(String id) async {
    await (_db.delete(_db.diaryEntries)..where((d) => d.id.equals(id))).go();
  }

  /// 监听所有日记变化
  Stream<List<DiaryEntry>> watchAll() {
    return (_db.select(_db.diaryEntries)
          ..orderBy([(d) => OrderingTerm.desc(d.date)]))
        .watch();
  }

  /// 监听按月份的日记
  Stream<List<DiaryEntry>> watchByMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (_db.select(_db.diaryEntries)
          ..where((d) => d.date.isBetweenValues(start, end))
          ..orderBy([(d) => OrderingTerm.desc(d.date)]))
        .watch();
  }
}
