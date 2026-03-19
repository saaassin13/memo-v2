import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 备忘录仓库
class MemoRepository {
  final AppDatabase _db;

  MemoRepository(this._db);

  /// 获取所有备忘录
  Future<List<Memo>> getAll() async {
    return (_db.select(_db.memos)
          ..orderBy([
            (m) => OrderingTerm.desc(m.pinned),
            (m) => OrderingTerm.desc(m.updatedAt),
          ]))
        .get();
  }

  /// 按分类获取
  Future<List<Memo>> getByCategory(String category) async {
    return (_db.select(_db.memos)
          ..where((m) => m.category.equals(category))
          ..orderBy([
            (m) => OrderingTerm.desc(m.pinned),
            (m) => OrderingTerm.desc(m.updatedAt),
          ]))
        .get();
  }

  /// 获取置顶的备忘录
  Future<List<Memo>> getPinned() async {
    return (_db.select(_db.memos)
          ..where((m) => m.pinned.equals(true))
          ..orderBy([(m) => OrderingTerm.desc(m.updatedAt)]))
        .get();
  }

  /// 按 ID 获取单个备忘录
  Future<Memo?> getById(String id) async {
    return (_db.select(_db.memos)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  /// 搜索备忘录
  Future<List<Memo>> search(String query) async {
    final pattern = '%$query%';
    return (_db.select(_db.memos)
          ..where((m) =>
              m.title.like(pattern) |
              m.content.like(pattern))
          ..orderBy([
            (m) => OrderingTerm.desc(m.pinned),
            (m) => OrderingTerm.desc(m.updatedAt),
          ]))
        .get();
  }

  /// 插入新备忘录
  Future<void> insert(MemosCompanion memo) async {
    await _db.into(_db.memos).insert(memo);
  }

  /// 更新备忘录
  Future<void> update(Memo memo) async {
    await (_db.update(_db.memos)..where((m) => m.id.equals(memo.id))).write(
      MemosCompanion(
        title: Value(memo.title),
        content: Value(memo.content),
        category: Value(memo.category),
        pinned: Value(memo.pinned),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 切换置顶状态
  Future<void> togglePin(String id) async {
    final memo =
        await (_db.select(_db.memos)..where((m) => m.id.equals(id))).getSingle();

    await (_db.update(_db.memos)..where((m) => m.id.equals(id))).write(
      MemosCompanion(
        pinned: Value(!memo.pinned),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 删除备忘录
  Future<void> delete(String id) async {
    await (_db.delete(_db.memos)..where((m) => m.id.equals(id))).go();
  }

  /// 监听所有备忘录变化
  Stream<List<Memo>> watchAll() {
    return (_db.select(_db.memos)
          ..orderBy([
            (m) => OrderingTerm.desc(m.pinned),
            (m) => OrderingTerm.desc(m.updatedAt),
          ]))
        .watch();
  }

  /// 监听按分类的备忘录
  Stream<List<Memo>> watchByCategory(String category) {
    return (_db.select(_db.memos)
          ..where((m) => m.category.equals(category))
          ..orderBy([
            (m) => OrderingTerm.desc(m.pinned),
            (m) => OrderingTerm.desc(m.updatedAt),
          ]))
        .watch();
  }
}
