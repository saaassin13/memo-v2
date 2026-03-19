import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/database/app_database.dart';

part 'database_provider.g.dart';

/// 数据库 Provider - 全局单例
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}
