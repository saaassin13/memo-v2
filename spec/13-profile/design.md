# 13-profile 设计文档

## ProfileScreen 布局

```
┌─────────────────────────────────────┐
│  Header: 我的              [设置]   │
├─────────────────────────────────────┤
│                                     │
│         ┌─────────┐                 │
│         │  头像   │                 │
│         └─────────┘                 │
│           用户名                    │
│                                     │
├─────────────────────────────────────┤
│  ┌─────────┬─────────┬─────────┐   │
│  │   12    │    8    │   15    │   │
│  │  待办   │  日记   │  备忘录  │   │
│  └─────────┴─────────┴─────────┘   │
├─────────────────────────────────────┤
│                                     │
│  数据与存储                         │
│  ┌─────────────────────────────────┐│
│  │ 数据备份                    >  ││
│  │ 数据恢复                    >  ││
│  │ 清除数据                    >  ││
│  └─────────────────────────────────┘│
│                                     │
│  关于                               │
│  ┌─────────────────────────────────┐│
│  │ 版本信息              v1.0.0   ││
│  │ 检查更新                    >  ││
│  │ 意见反馈                    >  ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│           Bottom Navigation          │
└─────────────────────────────────────┘
```

## SettingsScreen 布局

```
┌─────────────────────────────────────┐
│  [<] 设置                           │
├─────────────────────────────────────┤
│                                     │
│  外观                               │
│  ┌─────────────────────────────────┐│
│  │ 深色模式                        ││
│  │ [跟随系统] [浅色] [深色]        ││
│  └─────────────────────────────────┘│
│                                     │
│  通知                               │
│  ┌─────────────────────────────────┐│
│  │ 待办提醒               [开关]  ││
│  │ 倒数日提醒             [开关]  ││
│  └─────────────────────────────────┘│
│                                     │
│  其他                               │
│  ┌─────────────────────────────────┐│
│  │ 语言                    简体中文││
│  │ 重置设置                    >  ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

## ProfileScreen

```dart
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            UserHeader(),
            const SizedBox(height: 24),
            StatsCard(stats: stats),
            const SizedBox(height: 24),
            _buildMenuSection(
              context,
              title: '数据与存储',
              items: [
                MenuItem(
                  icon: LucideIcons.download,
                  title: '数据备份',
                  onTap: () {},
                ),
                MenuItem(
                  icon: LucideIcons.upload,
                  title: '数据恢复',
                  onTap: () {},
                ),
                MenuItem(
                  icon: LucideIcons.trash2,
                  title: '清除数据',
                  onTap: () {},
                  destructive: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMenuSection(
              context,
              title: '关于',
              items: [
                MenuItem(
                  icon: LucideIcons.info,
                  title: '版本信息',
                  trailing: 'v1.0.0',
                ),
                MenuItem(
                  icon: LucideIcons.messageSquare,
                  title: '意见反馈',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}
```

## StatsCard

```dart
class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [kShadowSm],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: '待办', value: stats.todoCount),
          _StatItem(label: '日记', value: stats.diaryCount),
          _StatItem(label: '备忘录', value: stats.memoCount),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
```

## ThemeSelector

```dart
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '深色模式',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ThemeOption(
              label: '跟随系统',
              selected: themeMode == ThemeMode.system,
              onTap: () => ref.read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.system),
            ),
            const SizedBox(width: 8),
            _ThemeOption(
              label: '浅色',
              selected: themeMode == ThemeMode.light,
              onTap: () => ref.read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.light),
            ),
            const SizedBox(width: 8),
            _ThemeOption(
              label: '深色',
              selected: themeMode == ThemeMode.dark,
              onTap: () => ref.read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}
```
