import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/todos.dart';
import 'tables/memos.dart';
import 'tables/diary_entries.dart';
import 'tables/transactions.dart';
import 'tables/goals.dart';
import 'tables/goal_progress_records.dart';
import 'tables/weight_records.dart';
import 'tables/countdowns.dart';

part 'app_database.g.dart';

/// Memo App 主数据库
@DriftDatabase(tables: [
  Todos,
  Memos,
  DiaryEntries,
  Transactions,
  Goals,
  GoalProgressRecords,
  WeightRecords,
  Countdowns,
])
class AppDatabase extends _$AppDatabase {
  /// 创建数据库实例
  AppDatabase() : super(_openConnection());

  /// 用于测试的构造函数
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 版本迁移逻辑
        if (from < 2) {
          // 添加目标进度记录表
          await m.createTable(goalProgressRecords);
        }
        if (from < 3) {
          // 添加提醒字段
          await m.addColumn(todos, todos.remind);
          await m.addColumn(countdowns, countdowns.remind);
        }
      },
      beforeOpen: (details) async {
        // 启用外键约束
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

/// 打开数据库连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memo_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
