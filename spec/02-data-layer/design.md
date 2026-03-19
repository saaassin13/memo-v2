# 02-data-layer 设计文档

## 架构设计

```
┌─────────────────────────────────────────┐
│             Riverpod Providers          │
│  todoProvider, memoProvider, ...        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│              Repositories               │
│  TodoRepository, MemoRepository, ...    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│          Drift (SQLite ORM)             │
│             AppDatabase                 │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────┴───────────────────────┐
│               SQLite                    │
│             memo_app.db                 │
└─────────────────────────────────────────┘
```

## Drift 数据库配置

```dart
// lib/data/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Todos,
  Memos,
  DiaryEntries,
  Transactions,
  Goals,
  WeightRecords,
  Countdowns,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 版本迁移逻辑
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memo_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

## 表定义

### Todos
```dart
class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text().withDefault(const Constant('杂项'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Memos
```dart
class Memos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get category => text().withDefault(const Constant('生活'))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

## Repository 模式

```dart
// lib/data/repositories/todo_repository.dart
class TodoRepository {
  final AppDatabase _db;

  TodoRepository(this._db);

  // 获取所有待办
  Future<List<Todo>> getAll() async {
    return _db.select(_db.todos).get();
  }

  // 按分类获取
  Future<List<Todo>> getByCategory(String category) async {
    return (_db.select(_db.todos)
      ..where((t) => t.category.equals(category)))
      .get();
  }

  // 获取待完成
  Future<List<Todo>> getPending() async {
    return (_db.select(_db.todos)
      ..where((t) => t.completed.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
      .get();
  }

  // 获取已完成
  Future<List<Todo>> getCompleted() async {
    return (_db.select(_db.todos)
      ..where((t) => t.completed.equals(true)))
      .get();
  }

  // 按日期获取
  Future<List<Todo>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.todos)
      ..where((t) => t.dueDate.isBetweenValues(start, end)))
      .get();
  }

  // 插入
  Future<void> insert(TodosCompanion todo) async {
    await _db.into(_db.todos).insert(todo);
  }

  // 更新
  Future<void> update(Todo todo) async {
    await (_db.update(_db.todos)
      ..where((t) => t.id.equals(todo.id)))
      .write(TodosCompanion(
        title: Value(todo.title),
        category: Value(todo.category),
        dueDate: Value(todo.dueDate),
        note: Value(todo.note),
        completed: Value(todo.completed),
        updatedAt: Value(DateTime.now()),
      ));
  }

  // 切换完成状态
  Future<void> toggleComplete(String id) async {
    final todo = await (_db.select(_db.todos)
      ..where((t) => t.id.equals(id)))
      .getSingle();

    await (_db.update(_db.todos)
      ..where((t) => t.id.equals(id)))
      .write(TodosCompanion(
        completed: Value(!todo.completed),
        updatedAt: Value(DateTime.now()),
      ));
  }

  // 删除
  Future<void> delete(String id) async {
    await (_db.delete(_db.todos)
      ..where((t) => t.id.equals(id)))
      .go();
  }

  // 监听变化
  Stream<List<Todo>> watchAll() {
    return _db.select(_db.todos).watch();
  }
}
```

## Riverpod Provider

```dart
// lib/providers/database_provider.dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

// lib/providers/todo_provider.dart
@Riverpod(keepAlive: true)
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TodoRepository(db);
}

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

  Future<void> add(Todo todo) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.insert(TodosCompanion(
      id: Value(todo.id),
      title: Value(todo.title),
      category: Value(todo.category),
      dueDate: Value(todo.dueDate),
      note: Value(todo.note),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    ref.invalidateSelf();
  }

  Future<void> toggle(String id) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.toggleComplete(id);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
```

## 数据模型转换

```dart
// Drift 生成的 Todo 类转业务模型
extension TodoDataExtension on Todo {
  TodoModel toModel() {
    return TodoModel(
      id: id,
      title: title,
      category: category,
      dueDate: dueDate,
      note: note,
      completed: completed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```
