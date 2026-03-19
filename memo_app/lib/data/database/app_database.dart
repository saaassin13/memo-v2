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
  WeightRecords,
  Countdowns,
])
class AppDatabase extends _$AppDatabase {
  /// 创建数据库实例
  AppDatabase() : super(_openConnection());

  /// 用于测试的构造函数
  AppDatabase.forTesting(super.executor);

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
        // 当 schemaVersion 增加时，在这里添加迁移代码
        // 例如:
        // if (from < 2) {
        //   await m.addColumn(todos, todos.newColumn);
        // }
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
