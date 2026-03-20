import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../providers/todo_provider.dart';
import '../../../../providers/diary_provider.dart';
import '../../../../providers/memo_provider.dart';

/// 用户统计数据
class UserStats {
  final int todoCount;
  final int diaryCount;
  final int memoCount;

  const UserStats({
    this.todoCount = 0,
    this.diaryCount = 0,
    this.memoCount = 0,
  });
}

/// 统计数据卡片组件
class StatsCard extends ConsumerWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取各模块数据
    final todosAsync = ref.watch(todoListProvider());
    final diariesAsync = ref.watch(diaryListProvider());
    final memosAsync = ref.watch(memoListProvider());

    // 计算统计数据
    final todoCount = todosAsync.valueOrNull?.length ?? 0;
    final diaryCount = diariesAsync.valueOrNull?.length ?? 0;
    final memoCount = memosAsync.valueOrNull?.length ?? 0;

    // Bug 18: Make stats items clickable to navigate to corresponding pages
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: '待办',
              value: todoCount,
              onTap: () => context.go(Routes.todo),
            ),
            _buildDivider(context),
            _StatItem(
              label: '日记',
              value: diaryCount,
              onTap: () => context.push(Routes.diaryList),
            ),
            _buildDivider(context),
            _StatItem(
              label: '备忘录',
              value: memoCount,
              onTap: () => context.push(Routes.memoList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onTap; // Bug 18: Add tap callback

  const _StatItem({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
