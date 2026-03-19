# 02-data-layer - 数据层

## 模块说明

SQLite 数据库配置、数据模型定义、Repository 实现、Riverpod Provider 配置。

## 依赖模块

- 00-foundation

## 被依赖模块

- 所有功能模块 (10-13, 20-25)

## 核心文件

```
lib/data/
├── database/
│   ├── app_database.dart        # Drift 数据库定义
│   ├── app_database.g.dart      # 生成文件
│   └── tables/
│       ├── todos.dart
│       ├── memos.dart
│       ├── diary_entries.dart
│       ├── transactions.dart
│       ├── goals.dart
│       ├── weight_records.dart
│       └── countdowns.dart
├── models/
│   ├── todo.dart
│   ├── memo.dart
│   ├── diary_entry.dart
│   ├── transaction.dart
│   ├── goal.dart
│   ├── weight_record.dart
│   ├── countdown.dart
│   └── calendar_event.dart
└── repositories/
    ├── todo_repository.dart
    ├── memo_repository.dart
    ├── diary_repository.dart
    ├── transaction_repository.dart
    ├── goal_repository.dart
    ├── weight_repository.dart
    └── countdown_repository.dart

lib/providers/
├── database_provider.dart
├── todo_provider.dart
├── memo_provider.dart
├── diary_provider.dart
├── transaction_provider.dart
├── goal_provider.dart
├── weight_provider.dart
└── countdown_provider.dart
```

## 数据表

| 表名 | 说明 |
|------|------|
| todos | 待办事项 |
| memos | 备忘录 |
| diary_entries | 日记 |
| transactions | 交易记录 |
| goals | 目标 |
| weight_records | 体重记录 |
| countdowns | 倒数纪念日 |

## 状态

- [x] 设计完成
- [x] 开发完成
- [ ] 测试完成
- [ ] 发布就绪

## 开发进度

| 任务类型 | 完成数 | 总数 |
|---------|--------|------|
| 数据库配置 | 1 | 1 |
| 数据表定义 | 7 | 7 |
| Repository | 7 | 7 |
| Provider | 8 | 8 |
| 代码生成 | 1 | 1 |
| **总计** | **19** | **19** |

## 相关文档

- [设计文档](./design.md)
- [任务明细](./tasks.md)
- [变更记录](./changelog.md)
- [数据模型](../architecture/data-model.md)
