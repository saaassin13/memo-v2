import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memo_app/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('初始主题为 system', () async {
      final container = ProviderContainer();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(themeModeProvider), ThemeMode.system);
      container.dispose();
    });

    test('setThemeMode 切换到 light', () async {
      final container = ProviderContainer();
      await Future<void>.delayed(Duration.zero);
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
      container.dispose();
    });

    test('setThemeMode 切换到 dark', () async {
      final container = ProviderContainer();
      await Future<void>.delayed(Duration.zero);
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      container.dispose();
    });

    test('toggle 从 light 到 dark', () async {
      final container = ProviderContainer();
      await Future<void>.delayed(Duration.zero);
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      container.read(themeModeProvider.notifier).toggle();
      expect(container.read(themeModeProvider), ThemeMode.dark);
      container.dispose();
    });

    test('toggle 从 dark 到 light', () async {
      final container = ProviderContainer();
      await Future<void>.delayed(Duration.zero);
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      container.read(themeModeProvider.notifier).toggle();
      expect(container.read(themeModeProvider), ThemeMode.light);
      container.dispose();
    });

    test('从 SharedPreferences 恢复主题', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      final container = ProviderContainer();

      // Poll until loaded (max 2 seconds)
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (container.read(themeModeProvider) == ThemeMode.dark) break;
      }

      expect(container.read(themeModeProvider), ThemeMode.dark);
      container.dispose();
    });
  });
}
