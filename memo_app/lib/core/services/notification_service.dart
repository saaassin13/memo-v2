import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 通知服务 - 管理本地推送通知
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 初始化通知服务
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    await requestPermission();
    _initialized = true;
  }

  /// 请求通知权限
  Future<bool> requestPermission() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// 立即发送通知
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'memo_channel',
      '备忘提醒',
      channelDescription: '待办和倒计时提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// 定时发送通知
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'memo_channel',
      '备忘提醒',
      channelDescription: '待办和倒计时提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// 为 Todo 设置到期提醒
  /// 提前 1 天和当天各提醒一次
  Future<void> scheduleTodoReminder({
    required String todoId,
    required String title,
    required DateTime dueDate,
  }) async {
    final todoHash = todoId.hashCode & 0x7FFFFFFF;
    final now = DateTime.now();

    // 提前 1 天提醒
    final oneDayBefore = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 1,
      9, // 早上 9 点
      0,
    );
    if (oneDayBefore.isAfter(now)) {
      await schedule(
        id: todoHash,
        title: '待办即将到期',
        body: '"$title" 将于明天到期',
        scheduledDate: oneDayBefore,
      );
    }

    // 当天提醒
    final onDueDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9,
      0,
    );
    if (onDueDay.isAfter(now)) {
      await schedule(
        id: todoHash + 1,
        title: '待办今日到期',
        body: '"$title" 今天到期，请及时处理',
        scheduledDate: onDueDay,
      );
    } else if (onDueDay.year == now.year &&
        onDueDay.month == now.month &&
        onDueDay.day == now.day) {
      // 到期日当天但已过 9 点，立即提醒
      await show(
        id: todoHash + 1,
        title: '待办今日到期',
        body: '"$title" 今天到期，请及时处理',
      );
    }
  }

  /// 为 Countdown 设置到期提醒
  /// 目标日当天提醒
  Future<void> scheduleCountdownReminder({
    required String countdownId,
    required String title,
    required DateTime targetDate,
  }) async {
    final hash = countdownId.hashCode & 0x7FFFFFFF;
    final now = DateTime.now();
    final reminderTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      8, // 早上 8 点
      0,
    );

    if (reminderTime.isAfter(now)) {
      await schedule(
        id: hash + 1000000, // 避免与 Todo ID 冲突
        title: '倒计时提醒',
        body: '"$title" 的目标日到了！',
        scheduledDate: reminderTime,
      );
    } else if (reminderTime.year == now.year &&
        reminderTime.month == now.month &&
        reminderTime.day == now.day) {
      // 目标日当天但已过 8 点，立即提醒
      await show(
        id: hash + 1000000,
        title: '倒计时提醒',
        body: '"$title" 的目标日到了！',
      );
    }
  }

  /// 取消指定通知
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
