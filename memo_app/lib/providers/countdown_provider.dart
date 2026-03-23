import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../data/repositories/countdown_repository.dart';
import 'database_provider.dart';

part 'countdown_provider.g.dart';

const _uuid = Uuid();

/// CountdownRepository Provider
@Riverpod(keepAlive: true)
CountdownRepository countdownRepository(CountdownRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return CountdownRepository(db);
}

/// 倒数纪念日列表 Provider
@riverpod
class CountdownList extends _$CountdownList {
  @override
  Future<List<Countdown>> build({String? type}) async {
    final repo = ref.watch(countdownRepositoryProvider);
    if (type != null) {
      return repo.getByType(type);
    }
    return repo.getAll();
  }

  /// 添加倒数纪念日
  Future<void> add({
    required String title,
    required DateTime targetDate,
    required String type,
    bool repeatYearly = false,
    bool remind = false,
    int remindAdvance = 1440,
    String? icon,
    String? color,
  }) async {
    final repo = ref.read(countdownRepositoryProvider);
    final now = DateTime.now();
    await repo.insert(CountdownsCompanion(
      id: Value(_uuid.v4()),
      title: Value(title),
      targetDate: Value(targetDate),
      type: Value(type),
      repeatYearly: Value(repeatYearly),
      remind: Value(remind),
      remindAdvance: Value(remindAdvance),
      icon: Value(icon),
      color: Value(color),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    ref.invalidateSelf();
  }

  /// 更新倒数纪念日
  Future<void> updateCountdown(Countdown countdown) async {
    final repo = ref.read(countdownRepositoryProvider);
    await repo.update(countdown);
    ref.invalidateSelf();
  }

  /// 删除倒数纪念日
  Future<void> delete(String id) async {
    final repo = ref.read(countdownRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

/// 即将到来的倒数纪念日 Provider
@riverpod
Future<List<Countdown>> upcomingCountdowns(UpcomingCountdownsRef ref, {int days = 30}) async {
  final repo = ref.watch(countdownRepositoryProvider);
  return repo.getUpcoming(days: days);
}

/// 单个倒数纪念日 Provider
@riverpod
Future<Countdown?> countdownById(CountdownByIdRef ref, String id) async {
  final repo = ref.watch(countdownRepositoryProvider);
  return repo.getById(id);
}

/// 按类型获取倒数纪念日 Provider
@riverpod
Future<List<Countdown>> countdownsByType(CountdownsByTypeRef ref, String type) async {
  final repo = ref.watch(countdownRepositoryProvider);
  return repo.getByType(type);
}

/// 倒数纪念日流 Provider
@riverpod
Stream<List<Countdown>> countdownsStream(CountdownsStreamRef ref) {
  final repo = ref.watch(countdownRepositoryProvider);
  return repo.watchAll();
}

/// 即将到来的倒数纪念日流 Provider
@riverpod
Stream<List<Countdown>> upcomingCountdownsStream(UpcomingCountdownsStreamRef ref, {int days = 30}) {
  final repo = ref.watch(countdownRepositoryProvider);
  return repo.watchUpcoming(days: days);
}
