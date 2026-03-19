# 10-home 设计文档

## 页面布局

```
┌─────────────────────────────────────┐
│          Header (可选标题)           │
├─────────────────────────────────────┤
│                                     │
│    ┌─────┐  ┌─────┐  ┌─────┐       │
│    │备忘录│  │倒数日│  │ 日记 │       │
│    └─────┘  └─────┘  └─────┘       │
│                                     │
│    ┌─────┐  ┌─────┐  ┌─────┐       │
│    │ 记账 │  │ 目标 │  │ 体重 │       │
│    └─────┘  └─────┘  └─────┘       │
│                                     │
│         (未来可扩展更多功能)          │
│                                     │
├─────────────────────────────────────┤
│           Bottom Navigation          │
└─────────────────────────────────────┘
```

## AppsGrid 组件

```dart
// lib/ui/screens/home/widgets/apps_grid.dart

class AppItem {
  final String id;
  final String name;
  final IconData icon;
  final String route;
  final Color color;

  const AppItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    required this.color,
  });
}

const appItems = [
  AppItem(
    id: 'memo',
    name: '备忘录',
    icon: LucideIcons.fileText,
    route: '/apps/memo',
    color: AppColors.primary,
  ),
  AppItem(
    id: 'countdown',
    name: '倒数纪念日',
    icon: LucideIcons.calendarHeart,
    route: '/apps/countdown',
    color: AppColors.chart4,
  ),
  AppItem(
    id: 'diary',
    name: '日记',
    icon: LucideIcons.bookOpen,
    route: '/apps/diary',
    color: AppColors.accent,
  ),
  AppItem(
    id: 'accounting',
    name: '记账',
    icon: LucideIcons.wallet,
    route: '/apps/accounting',
    color: AppColors.chart3,
  ),
  AppItem(
    id: 'goals',
    name: '目标',
    icon: LucideIcons.target,
    route: '/apps/goals',
    color: AppColors.chart1,
  ),
  AppItem(
    id: 'weight',
    name: '体重',
    icon: LucideIcons.scale,
    route: '/apps/weight',
    color: AppColors.chart5,
  ),
];

class AppsGrid extends StatelessWidget {
  const AppsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: appItems.map((app) => _AppTile(app: app)).toList(),
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppItem app;

  const _AppTile({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(app.route),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [kShadowSm],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: app.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                app.icon,
                size: 28,
                color: app.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              app.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## HomeScreen

```dart
// lib/ui/screens/home/home_screen.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 可选: 欢迎语或日期
              Text(
                '今天',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              const AppsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 交互效果

- 点击应用图标跳转到对应功能页面
- 按压时缩放动画 (scale 0.95)
- 阴影变化
