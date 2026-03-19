import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/theme_provider.dart';

/// 主题选择器组件
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '深色模式',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ThemeOption(
              label: '跟随系统',
              selected: themeMode == ThemeMode.system,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.system),
            ),
            const SizedBox(width: 8),
            _ThemeOption(
              label: '浅色',
              selected: themeMode == ThemeMode.light,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.light),
            ),
            const SizedBox(width: 8),
            _ThemeOption(
              label: '深色',
              selected: themeMode == ThemeMode.dark,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
