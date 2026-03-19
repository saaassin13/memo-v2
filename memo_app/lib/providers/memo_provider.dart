import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/memo_repository.dart';
import 'database_provider.dart';

part 'memo_provider.g.dart';

const _uuid = Uuid();

/// MemoRepository Provider
@Riverpod(keepAlive: true)
MemoRepository memoRepository(MemoRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return MemoRepository(db);
}

/// 备忘录列表 Provider
@riverpod
class MemoList extends _$MemoList {
  @override
  Future<List<Memo>> build({String? category}) async {
    final repo = ref.watch(memoRepositoryProvider);
    if (category != null && category != '全部') {
      return repo.getByCategory(category);
    }
    return repo.getAll();
  }

  /// 添加备忘录
  Future<void> add({
    required String title,
    required String content,
    String category = '生活',
    bool pinned = false,
  }) async {
    final repo = ref.read(memoRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(MemosCompanion(
      id: Value(_uuid.v4()),
      title: Value(title),
      content: Value(content),
      category: Value(category),
      pinned: Value(pinned),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 更新备忘录
  Future<void> updateMemo(Memo memo) async {
    final repo = ref.read(memoRepositoryProvider);
    await repo.update(memo);
    ref.invalidateSelf();
  }

  /// 切换置顶状态
  Future<void> togglePin(String id) async {
    final repo = ref.read(memoRepositoryProvider);
    await repo.togglePin(id);
    ref.invalidateSelf();
  }

  /// 删除备忘录
  Future<void> delete(String id) async {
    final repo = ref.read(memoRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 置顶备忘录 Provider
@riverpod
Future<List<Memo>> pinnedMemos(PinnedMemosRef ref) async {
  final repo = ref.watch(memoRepositoryProvider);
  return repo.getPinned();
}

/// 搜索备忘录 Provider
@riverpod
Future<List<Memo>> searchMemos(SearchMemosRef ref, String query) async {
  if (query.isEmpty) {
    return [];
  }
  final repo = ref.watch(memoRepositoryProvider);
  return repo.search(query);
}

/// 单个备忘录 Provider
@riverpod
Future<Memo?> memoById(MemoByIdRef ref, String id) async {
  final repo = ref.watch(memoRepositoryProvider);
  return repo.getById(id);
}

/// 备忘录流 Provider
@riverpod
Stream<List<Memo>> memosStream(MemosStreamRef ref) {
  final repo = ref.watch(memoRepositoryProvider);
  return repo.watchAll();
}
