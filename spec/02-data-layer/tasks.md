# 02-data-layer 任务明细

## 任务列表

### D-001: 配置 Drift 数据库
- **优先级**: P0
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**内容**:
- 创建 AppDatabase 类
- 配置数据库连接
- 配置迁移策略

**文件**:
- `lib/data/database/app_database.dart`

---

### D-002: 定义 Todos 表
- **优先级**: P0
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/todos.dart`

---

### D-003: 定义 Memos 表
- **优先级**: P0
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/memos.dart`

---

### D-004: 定义 DiaryEntries 表
- **优先级**: P0
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/diary_entries.dart`

---

### D-005: 定义 Transactions 表
- **优先级**: P1
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/transactions.dart`

---

### D-006: 定义 Goals 表
- **优先级**: P1
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/goals.dart`

---

### D-007: 定义 WeightRecords 表
- **优先级**: P1
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/weight_records.dart`

---

### D-008: 定义 Countdowns 表
- **优先级**: P1
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/data/database/tables/countdowns.dart`

---

### D-009: 实现 TodoRepository
- **优先级**: P0
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getByCategory, getPending, getCompleted
- getByDate, getById
- insert, update, delete
- toggleComplete
- watchAll, watchPending, watchByCategory

**文件**: `lib/data/repositories/todo_repository.dart`

---

### D-010: 实现 MemoRepository
- **优先级**: P0
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getByCategory, getById
- getPinned, search
- insert, update, delete
- togglePin
- watchAll, watchByCategory

**文件**: `lib/data/repositories/memo_repository.dart`

---

### D-011: 实现 DiaryRepository
- **优先级**: P0
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getByDate, getByMonth, getById
- getDatesWithEntries, search
- insert, update, delete
- watchAll, watchByMonth

**文件**: `lib/data/repositories/diary_repository.dart`

---

### D-012: 实现 TransactionRepository
- **优先级**: P1
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getByType, getByDate, getByMonth, getById
- getRecent
- insert, delete
- getMonthlyStats
- watchAll, watchByMonth

**文件**: `lib/data/repositories/transaction_repository.dart`

---

### D-013: 实现 GoalRepository
- **优先级**: P1
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getActive, getCompleted, getByType, getById
- insert, update, delete
- updateProgress, incrementProgress
- watchAll, watchActive

**文件**: `lib/data/repositories/goal_repository.dart`

---

### D-014: 实现 WeightRepository
- **优先级**: P1
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getRecent, getByDateRange, getById
- getLatest
- insert, update, delete
- getStats
- watchAll, watchRecent

**文件**: `lib/data/repositories/weight_repository.dart`

---

### D-015: 实现 CountdownRepository
- **优先级**: P1
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**方法**:
- getAll, getUpcoming, getByType, getById
- insert, update, delete
- watchAll, watchUpcoming

**文件**: `lib/data/repositories/countdown_repository.dart`

---

### D-016: 配置 Database Provider
- **优先级**: P0
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/providers/database_provider.dart`

---

### D-017: 实现 Todo Provider
- **优先级**: P0
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/providers/todo_provider.dart`

**Providers**:
- todoRepositoryProvider
- todoListProvider (with category filter)
- pendingTodosProvider
- completedTodosProvider
- todosByDateProvider
- todosStreamProvider

---

### D-018: 实现其他 Providers
- **优先级**: P1
- **预估**: 4h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**:
- `lib/providers/memo_provider.dart`
- `lib/providers/diary_provider.dart`
- `lib/providers/transaction_provider.dart`
- `lib/providers/goal_provider.dart`
- `lib/providers/weight_provider.dart`
- `lib/providers/countdown_provider.dart`

---

### D-019: 运行代码生成
- **优先级**: P0
- **预估**: 0.5h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**命令**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**生成文件**:
- `lib/data/database/app_database.g.dart`
- `lib/providers/database_provider.g.dart`
- `lib/providers/todo_provider.g.dart`
- `lib/providers/memo_provider.g.dart`
- `lib/providers/diary_provider.g.dart`
- `lib/providers/transaction_provider.g.dart`
- `lib/providers/goal_provider.g.dart`
- `lib/providers/weight_provider.g.dart`
- `lib/providers/countdown_provider.g.dart`

---

## 进度统计

| 状态 | 数量 |
|------|------|
| 待开发 | 0 |
| 开发中 | 0 |
| 已完成 | 19 |
| **总计** | **19** |
