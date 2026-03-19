# 02-data-layer 变更记录

## [1.0.0] - 2026-03-19

### Added

#### 数据库配置
- AppDatabase 类配置完成
- 数据库连接配置 (SQLite via Drift)
- 迁移策略配置
- 支持测试环境的构造函数

#### 数据表 (7个)
- `todos` - 待办事项表 (id, title, category, dueDate, note, completed, createdAt, updatedAt)
- `memos` - 备忘录表 (id, title, content, category, pinned, createdAt, updatedAt)
- `diary_entries` - 日记表 (id, date, title, content, mood, weather, images, createdAt, updatedAt)
- `transactions` - 交易记录表 (id, amount, type, category, note, date, createdAt)
- `goals` - 目标表 (id, title, description, type, targetValue, currentValue, unit, startDate, endDate, completed, createdAt, updatedAt)
- `weight_records` - 体重记录表 (id, weight, date, note, createdAt)
- `countdowns` - 倒数纪念日表 (id, title, targetDate, type, repeatYearly, icon, color, createdAt, updatedAt)

#### Repository (7个)
- `TodoRepository` - 待办事项数据访问
- `MemoRepository` - 备忘录数据访问
- `DiaryRepository` - 日记数据访问
- `TransactionRepository` - 交易记录数据访问 (含月度统计)
- `GoalRepository` - 目标数据访问 (含进度管理)
- `WeightRepository` - 体重记录数据访问 (含统计分析)
- `CountdownRepository` - 倒数纪念日数据访问

#### Riverpod Provider (8个)
- `appDatabaseProvider` - 数据库单例
- `todoRepositoryProvider` + `TodoList` + 辅助 Providers
- `memoRepositoryProvider` + `MemoList` + 辅助 Providers
- `diaryRepositoryProvider` + `DiaryList` + 辅助 Providers
- `transactionRepositoryProvider` + `TransactionList` + 辅助 Providers
- `goalRepositoryProvider` + `GoalList` + 辅助 Providers
- `weightRepositoryProvider` + `WeightList` + 辅助 Providers
- `countdownRepositoryProvider` + `CountdownList` + 辅助 Providers

### Technical Notes

- 使用 Drift 2.15.0 作为 SQLite ORM
- 使用 riverpod_annotation 进行代码生成
- 所有 Repository 支持 Stream 监听实时变化
- Provider 使用 @Riverpod(keepAlive: true) 保持全局单例

---

## 变更模板

### [版本号] - YYYY-MM-DD

#### Added
- 新增表/字段

#### Changed
- Schema 变更

#### Migration
- 迁移步骤说明

#### Impact
- 影响的功能模块
