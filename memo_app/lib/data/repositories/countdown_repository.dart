import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// 倒数纪念日仓库
class CountdownRepository {
  final AppDatabase _db;

  CountdownRepository(this._db);

  /// 获取所有倒数纪念日
  Future<List<Countdown>> getAll() async {
    return (_db.select(_db.countdowns)
          ..orderBy([(c) => OrderingTerm.asc(c.targetDate)]))
        .get();
  }

  /// 获取即将到来的 (按天数)
  Future<List<Countdown>> getUpcoming({int days = 30}) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    return (_db.select(_db.countdowns)
          ..where((c) =>
              c.targetDate.isBiggerOrEqualValue(now) &
              c.targetDate.isSmallerOrEqualValue(end))
          ..orderBy([(c) => OrderingTerm.asc(c.targetDate)]))
        .get();
  }

  /// 按类型获取 (countdown/anniversary)
  Future<List<Countdown>> getByType(String type) async {
    return (_db.select(_db.countdowns)
          ..where((c) => c.type.equals(type))
          ..orderBy([(c) => OrderingTerm.asc(c.targetDate)]))
        .get();
  }

  /// 按 ID 获取单个
  Future<Countdown?> getById(String id) async {
    return (_db.select(_db.countdowns)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// 插入新倒数纪念日
  Future<void> insert(CountdownsCompanion countdown) async {
    await _db.into(_db.countdowns).insert(countdown);
  }

  /// 更新倒数纪念日
  Future<void> update(Countdown countdown) async {
    await (_db.update(_db.countdowns)..where((c) => c.id.equals(countdown.id)))
        .write(
      CountdownsCompanion(
        title: Value(countdown.title),
        targetDate: Value(countdown.targetDate),
        type: Value(countdown.type),
        repeatYearly: Value(countdown.repeatYearly),
        remind: Value(countdown.remind),
        remindAdvance: Value(countdown.remindAdvance),
        icon: Value(countdown.icon),
        color: Value(countdown.color),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 删除倒数纪念日
  Future<void> delete(String id) async {
    await (_db.delete(_db.countdowns)..where((c) => c.id.equals(id))).go();
  }

  /// 监听所有倒数纪念日变化
  Stream<List<Countdown>> watchAll() {
    return (_db.select(_db.countdowns)
          ..orderBy([(c) => OrderingTerm.asc(c.targetDate)]))
        .watch();
  }

  /// 监听即将到来的倒数纪念日
  Stream<List<Countdown>> watchUpcoming({int days = 30}) {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    return (_db.select(_db.countdowns)
          ..where((c) =>
              c.targetDate.isBiggerOrEqualValue(now) &
              c.targetDate.isSmallerOrEqualValue(end))
          ..orderBy([(c) => OrderingTerm.asc(c.targetDate)]))
        .watch();
  }
}
