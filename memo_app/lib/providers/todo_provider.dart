import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/todo_repository.dart';
import 'database_provider.dart';

part 'todo_provider.g.dart';

const _uuid = Uuid();

/// TodoRepository Provider
@Riverpod(keepAlive: true)
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TodoRepository(db);
}

/// 待办列表 Provider
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build({String? category}) async {
    final repo = ref.watch(todoRepositoryProvider);
    if (category != null && category != '全部') {
      return repo.getByCategory(category);
    }
    return repo.getAll();
  }

  /// 添加待办
  Future<void> add({
    required String title,
    String category = '杂项',
    DateTime? dueDate,
    String? note,
  }) async {
    final repo = ref.read(todoRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(TodosCompanion(
      id: Value(_uuid.v4()),
      title: Value(title),
      category: Value(category),
      dueDate: Value(dueDate),
      note: Value(note),
      completed: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 更新待办
  Future<void> updateTodo(Todo todo) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.update(todo);
    ref.invalidateSelf();
  }

  /// 切换完成状态
  Future<void> toggle(String id) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.toggleComplete(id);
    ref.invalidateSelf();
  }

  /// 删除待办
  Future<void> delete(String id) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 待完成待办 Provider
@riverpod
Future<List<Todo>> pendingTodos(PendingTodosRef ref) async {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getPending();
}

/// 已完成待办 Provider
@riverpod
Future<List<Todo>> completedTodos(CompletedTodosRef ref) async {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getCompleted();
}

/// 按日期获取待办 Provider
@riverpod
Future<List<Todo>> todosByDate(TodosByDateRef ref, DateTime date) async {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getByDate(date);
}

/// 待办流 Provider (用于实时监听)
@riverpod
Stream<List<Todo>> todosStream(TodosStreamRef ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.watchAll();
}
