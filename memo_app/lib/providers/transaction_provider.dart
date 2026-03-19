import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/transaction_repository.dart';
import 'database_provider.dart';

part 'transaction_provider.g.dart';

const _uuid = Uuid();

/// TransactionRepository Provider
@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepository(db);
}

/// 交易记录列表 Provider
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build({int? year, int? month}) async {
    final repo = ref.watch(transactionRepositoryProvider);
    if (year != null && month != null) {
      return repo.getByMonth(year, month);
    }
    return repo.getAll();
  }

  /// 添加交易记录
  Future<void> add({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final repo = ref.read(transactionRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(TransactionsCompanion(
      id: Value(_uuid.v4()),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      date: Value(date),
      note: Value(note),
      createdAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 删除交易记录
  Future<void> delete(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 按类型获取交易记录 Provider
@riverpod
Future<List<Transaction>> transactionsByType(
    TransactionsByTypeRef ref, String type) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getByType(type);
}

/// 按日期获取交易记录 Provider
@riverpod
Future<List<Transaction>> transactionsByDate(
    TransactionsByDateRef ref, DateTime date) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getByDate(date);
}

/// 最近交易记录 Provider
@riverpod
Future<List<Transaction>> recentTransactions(
    RecentTransactionsRef ref, {int limit = 10}) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getRecent(limit: limit);
}

/// 月度统计 Provider
@riverpod
Future<MonthlyStats> monthlyStats(
    MonthlyStatsRef ref, int year, int month) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getMonthlyStats(year, month);
}

/// 交易记录流 Provider
@riverpod
Stream<List<Transaction>> transactionsStream(TransactionsStreamRef ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAll();
}

/// 按月份的交易记录流 Provider
@riverpod
Stream<List<Transaction>> transactionsStreamByMonth(
    TransactionsStreamByMonthRef ref, int year, int month) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchByMonth(year, month);
}
