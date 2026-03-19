import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/router/routes.dart';
import 'widgets/user_header.dart';
import 'widgets/stats_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '我的',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.settings),
                  onPressed: () => context.push(Routes.settings),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Header
            const Center(child: UserHeader()),
            const SizedBox(height: 24),

            // Stats Card
            const StatsCard(),
            const SizedBox(height: 24),

            // 关于
            _buildMenuSection(
              context,
              title: '关于',
              items: [
                _MenuItem(
                  icon: LucideIcons.info,
                  title: '版本信息',
                  trailing: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '1.0.0';
                      return Text(
                        'v$version',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                _MenuItem(
                  icon: LucideIcons.messageSquare,
                  title: '意见反馈',
                  onTap: () => _showFeedbackDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    trailing: item.trailing ??
                        (item.onTap != null
                            ? const Icon(LucideIcons.chevronRight, size: 20)
                            : null),
                    onTap: item.onTap,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('意见反馈'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '请输入您的意见或建议...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('感谢您的反馈！')),
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });
}
