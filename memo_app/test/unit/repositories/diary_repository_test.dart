import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/data/repositories/diary_repository.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DiaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DiaryRepository', () {
    test('insert 和 getById', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '测试日记',
        content: '今天天气很好',
        createdAt: now,
        updatedAt: now,
      ));

      final diary = await repo.getById('d1');
      expect(diary, isNotNull);
      expect(diary!.title, '测试日记');
      expect(diary.content, '今天天气很好');
    });

    test('getAll 返回所有日记', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '日记1',
        content: '内容1',
        createdAt: now,
        updatedAt: now,
      ));
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd2',
        date: now.add(const Duration(days: 1)),
        title: '日记2',
        content: '内容2',
        createdAt: now,
        updatedAt: now,
      ));

      final diaries = await repo.getAll();
      expect(diaries.length, 2);
    });

    test('getByDate 按日期获取', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '日记1',
        content: '内容1',
        createdAt: now,
        updatedAt: now,
      ));

      final diary = await repo.getByDate(now);
      expect(diary, isNotNull);
      expect(diary!.id, 'd1');
    });

    test('getByMonth 按月份获取', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '六月日记',
        content: '内容',
        createdAt: now,
        updatedAt: now,
      ));
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd2',
        date: DateTime(2024, 7, 1),
        title: '七月日记',
        content: '内容',
        createdAt: now,
        updatedAt: now,
      ));

      final june = await repo.getByMonth(2024, 6);
      expect(june.length, 1);
      expect(june.first.title, '六月日记');
    });

    test('update 更新日记', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '原标题',
        content: '原内容',
        createdAt: now,
        updatedAt: now,
      ));

      final diary = await repo.getById('d1');
      await repo.update(diary!.copyWith(
        title: '新标题',
        content: '新内容',
      ));

      final updated = await repo.getById('d1');
      expect(updated!.title, '新标题');
      expect(updated.content, '新内容');
    });

    test('delete 删除日记', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '测试',
        content: '内容',
        createdAt: now,
        updatedAt: now,
      ));

      await repo.delete('d1');
      final diary = await repo.getById('d1');
      expect(diary, isNull);
    });

    test('search 搜索日记', () async {
      final now = DateTime(2024, 6, 15);
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd1',
        date: now,
        title: '今天去公园',
        content: '阳光明媚',
        createdAt: now,
        updatedAt: now,
      ));
      await repo.insert(DiaryEntriesCompanion.insert(
        id: 'd2',
        date: now.add(const Duration(days: 1)),
        title: '在家休息',
        content: '看书听音乐',
        createdAt: now,
        updatedAt: now,
      ));

      final results = await repo.search('公园');
      expect(results.length, 1);
      expect(results.first.title, '今天去公园');
    });
  });
}
