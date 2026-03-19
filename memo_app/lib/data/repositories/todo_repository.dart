import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 待办事项仓库
class TodoRepository {
  final AppDatabase _db;

  TodoRepository(this._db);

  /// 获取所有待办
  Future<List<Todo>> getAll() async {
    return (_db.select(_db.todos)
          ..orderBy([
            (t) => OrderingTerm.asc(t.completed),
            (t) => OrderingTerm.asc(t.dueDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  /// 按分类获取
  Future<List<Todo>> getByCategory(String category) async {
    return (_db.select(_db.todos)
          ..where((t) => t.category.equals(category))
          ..orderBy([
            (t) => OrderingTerm.asc(t.completed),
            (t) => OrderingTerm.asc(t.dueDate),
          ]))
        .get();
  }

  /// 获取待完成的待办
  Future<List<Todo>> getPending() async {
    return (_db.select(_db.todos)
          ..where((t) => t.completed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// 获取已完成的待办
  Future<List<Todo>> getCompleted() async {
    return (_db.select(_db.todos)
          ..where((t) => t.completed.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  /// 按日期获取
  Future<List<Todo>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.todos)
          ..where((t) => t.dueDate.isBetweenValues(start, end))
          ..orderBy([
            (t) => OrderingTerm.asc(t.completed),
            (t) => OrderingTerm.asc(t.dueDate),
          ]))
        .get();
  }

  /// 按 ID 获取单个待办
  Future<Todo?> getById(String id) async {
    return (_db.select(_db.todos)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 插入新待办
  Future<void> insert(TodosCompanion todo) async {
    await _db.into(_db.todos).insert(todo);
  }

  /// 更新待办
  Future<void> update(Todo todo) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(todo.id))).write(
      TodosCompanion(
        title: Value(todo.title),
        category: Value(todo.category),
        dueDate: Value(todo.dueDate),
        note: Value(todo.note),
        completed: Value(todo.completed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 切换完成状态
  Future<void> toggleComplete(String id) async {
    final todo =
        await (_db.select(_db.todos)..where((t) => t.id.equals(id))).getSingle();

    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        completed: Value(!todo.completed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 删除待办
  Future<void> delete(String id) async {
    await (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }

  /// 监听所有待办变化
  Stream<List<Todo>> watchAll() {
    return (_db.select(_db.todos)
          ..orderBy([
            (t) => OrderingTerm.asc(t.completed),
            (t) => OrderingTerm.asc(t.dueDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// 监听待完成的待办
  Stream<List<Todo>> watchPending() {
    return (_db.select(_db.todos)
          ..where((t) => t.completed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// 监听按分类的待办
  Stream<List<Todo>> watchByCategory(String category) {
    return (_db.select(_db.todos)
          ..where((t) => t.category.equals(category))
          ..orderBy([
            (t) => OrderingTerm.asc(t.completed),
            (t) => OrderingTerm.asc(t.dueDate),
          ]))
        .watch();
  }
}
