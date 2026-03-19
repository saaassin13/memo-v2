import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 月度统计数据
class MonthlyStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> categoryExpenses;
  final Map<String, double> categoryIncomes;

  MonthlyStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryExpenses,
    required this.categoryIncomes,
  });
}

/// 交易记录仓库
class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  /// 获取所有交易记录
  Future<List<Transaction>> getAll() async {
    return (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 按类型获取 (income/expense)
  Future<List<Transaction>> getByType(String type) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 按日期获取
  Future<List<Transaction>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 按月份获取
  Future<List<Transaction>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (_db.select(_db.transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 按 ID 获取单个交易记录
  Future<Transaction?> getById(String id) async {
    return (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取最近的交易记录
  Future<List<Transaction>> getRecent({int limit = 10}) async {
    return (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .get();
  }

  /// 插入新交易记录
  Future<void> insert(TransactionsCompanion transaction) async {
    await _db.into(_db.transactions).insert(transaction);
  }

  /// 删除交易记录
  Future<void> delete(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  /// 获取月度统计
  Future<MonthlyStats> getMonthlyStats(int year, int month) async {
    final transactions = await getByMonth(year, month);

    double totalIncome = 0;
    double totalExpense = 0;
    final categoryExpenses = <String, double>{};
    final categoryIncomes = <String, double>{};

    for (final t in transactions) {
      if (t.type == 'income') {
        totalIncome += t.amount.abs();
        categoryIncomes[t.category] =
            (categoryIncomes[t.category] ?? 0) + t.amount.abs();
      } else {
        totalExpense += t.amount.abs();
        categoryExpenses[t.category] =
            (categoryExpenses[t.category] ?? 0) + t.amount.abs();
      }
    }

    return MonthlyStats(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      categoryExpenses: categoryExpenses,
      categoryIncomes: categoryIncomes,
    );
  }

  /// 监听所有交易记录变化
  Stream<List<Transaction>> watchAll() {
    return (_db.select(_db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// 监听按月份的交易记录
  Stream<List<Transaction>> watchByMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (_db.select(_db.transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }
}
