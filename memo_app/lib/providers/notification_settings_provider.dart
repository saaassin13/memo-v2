import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  const NotificationSettings({
    this.todoReminder = true,
    this.countdownReminder = true,
  });

  final bool todoReminder;
  final bool countdownReminder;

  NotificationSettings copyWith({
    bool? todoReminder,
    bool? countdownReminder,
  }) {
    return NotificationSettings(
      todoReminder: todoReminder ?? this.todoReminder,
      countdownReminder: countdownReminder ?? this.countdownReminder,
    );
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettings> {
  static const _todoKey = 'notify_todo';
  static const _countdownKey = 'notify_countdown';

  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    state = NotificationSettings(
      todoReminder: prefs.getBool(_todoKey) ?? true,
      countdownReminder: prefs.getBool(_countdownKey) ?? true,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_todoKey, state.todoReminder);
    await prefs.setBool(_countdownKey, state.countdownReminder);
  }

  void setTodoReminder(bool value) {
    state = state.copyWith(todoReminder: value);
    _save();
  }

  void setCountdownReminder(bool value) {
    state = state.copyWith(countdownReminder: value);
    _save();
  }
}
