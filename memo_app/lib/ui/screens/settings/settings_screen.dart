import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/notification_settings_provider.dart';
import 'widgets/theme_selector.dart';
import 'widgets/data_management.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifySettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 外观设置
          _buildSectionTitle(context, '外观'),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ThemeSelector(),
            ),
          ),
          const SizedBox(height: 24),

          // 通知设置
          _buildSectionTitle(context, '通知'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  context,
                  icon: LucideIcons.bell,
                  title: '待办提醒',
                  subtitle: '在待办截止时发送通知',
                  value: notifySettings.todoReminder,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setTodoReminder(value);
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSwitchTile(
                  context,
                  icon: LucideIcons.calendar,
                  title: '倒数日提醒',
                  subtitle: '在倒数日当天发送通知',
                  value: notifySettings.countdownReminder,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setCountdownReminder(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 数据管理
          const DataManagement(),
          const SizedBox(height: 24),

          // 其他设置
          _buildSectionTitle(context, '其他'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.globe),
                  title: const Text('语言'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '简体中文',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronRight, size: 20),
                    ],
                  ),
                  onTap: () {
                    // TODO: 语言选择
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(LucideIcons.rotateCcw),
                  title: const Text('重置设置'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 20),
                  onTap: () => _handleResetSettings(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }

  void _handleResetSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置已重置')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
