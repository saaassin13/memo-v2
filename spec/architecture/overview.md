# 架构总览

## 应用架构

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────────┐ │
│  │  Home   │  Todo   │Calendar │ Profile │  Feature Pages  │ │
│  └────┬────┴────┬────┴────┬────┴────┬────┴────────┬────────┘ │
│       │         │         │         │              │          │
│  ┌────┴─────────┴─────────┴─────────┴──────────────┴────────┐ │
│  │                    UI Components                          │ │
│  └──────────────────────────┬───────────────────────────────┘ │
└─────────────────────────────┼───────────────────────────────┘
                              │
┌─────────────────────────────┼───────────────────────────────┐
│                        State Layer                           │
│  ┌──────────────────────────┴───────────────────────────────┐ │
│  │                  Riverpod Providers                       │ │
│  └──────────────────────────┬───────────────────────────────┘ │
└─────────────────────────────┼───────────────────────────────┘
                              │
┌─────────────────────────────┼───────────────────────────────┐
│                        Data Layer                            │
│  ┌──────────────────────────┴───────────────────────────────┐ │
│  │                    Repositories                           │ │
│  └──────────────────────────┬───────────────────────────────┘ │
│  ┌──────────────────────────┴───────────────────────────────┐ │
│  │                 Drift (SQLite ORM)                        │ │
│  └──────────────────────────┬───────────────────────────────┘ │
│  ┌──────────────────────────┴───────────────────────────────┐ │
│  │                      SQLite                               │ │
│  └──────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # MaterialApp 配置
│
├── core/                        # 核心模块
│   ├── theme/                   # 主题配置
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── router/                  # 路由配置
│   │   └── app_router.dart
│   └── constants/               # 常量
│       └── app_constants.dart
│
├── data/                        # 数据层
│   ├── database/                # 数据库
│   │   ├── app_database.dart
│   │   ├── app_database.g.dart
│   │   └── tables/
│   │       ├── todos.dart
│   │       ├── memos.dart
│   │       ├── diary_entries.dart
│   │       ├── transactions.dart
│   │       ├── goals.dart
│   │       ├── weight_records.dart
│   │       └── countdowns.dart
│   ├── models/                  # 数据模型
│   │   └── ...
│   └── repositories/            # 数据仓库
│       └── ...
│
├── providers/                   # Riverpod Providers
│   ├── database_provider.dart
│   ├── todo_provider.dart
│   ├── memo_provider.dart
│   └── ...
│
├── ui/                          # UI 层
│   ├── components/              # 通用组件
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   ├── inputs/
│   │   └── ...
│   ├── layouts/                 # 布局组件
│   │   └── mobile_layout.dart
│   └── screens/                 # 页面
│       ├── home/
│       ├── todo/
│       ├── calendar/
│       ├── profile/
│       ├── memo/
│       ├── diary/
│       ├── countdown/
│       ├── accounting/
│       ├── goals/
│       └── weight/
│
└── utils/                       # 工具函数
    ├── date_utils.dart
    └── format_utils.dart
```

## 导航结构

```
/                           → Home (AppsGrid)
├── /todo                   → Todo 页面
├── /calendar               → 日历页面
│   └── /calendar/event/:id → 事件详情
├── /profile                → 我的页面
├── /settings               → 设置页面
├── /apps/memo              → 备忘录列表
│   ├── /apps/memo/new      → 新建备忘录
│   └── /apps/memo/:id      → 备忘录详情
├── /apps/diary             → 日记列表
│   ├── /apps/diary/new     → 新建日记
│   └── /apps/diary/:id     → 日记详情
├── /apps/countdown         → 倒数日列表
├── /apps/accounting        → 记账
├── /apps/goals             → 目标列表
│   └── /apps/goals/:id     → 目标详情
└── /apps/weight            → 体重记录
```

## 状态管理

使用 Riverpod 进行状态管理:

```dart
// Provider 示例
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    final repo = ref.watch(todoRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Todo todo) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.insert(todo);
    ref.invalidateSelf();
  }
}
```

## 数据持久化

使用 Drift (SQLite ORM):

```dart
// 表定义示例
class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```
