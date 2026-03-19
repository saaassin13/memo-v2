# 03-navigation 设计文档

## go_router 配置

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 底部导航 Shell
      ShellRoute(
        builder: (context, state, child) {
          return MobileLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/todo',
            name: 'todo',
            builder: (context, state) => const TodoScreen(),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarScreen(),
            routes: [
              GoRoute(
                path: 'event/:id',
                name: 'calendar-event',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CalendarEventScreen(id: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // 设置页面 (不带底部导航)
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // 备忘录模块
      GoRoute(
        path: '/apps/memo',
        name: 'memo-list',
        builder: (context, state) => const MemoListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'memo-new',
            builder: (context, state) => const MemoEditScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'memo-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MemoDetailScreen(id: id);
            },
          ),
        ],
      ),

      // 日记模块
      GoRoute(
        path: '/apps/diary',
        name: 'diary-list',
        builder: (context, state) => const DiaryListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'diary-new',
            builder: (context, state) => const DiaryEditScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'diary-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DiaryDetailScreen(id: id);
            },
          ),
        ],
      ),

      // 倒数日
      GoRoute(
        path: '/apps/countdown',
        name: 'countdown',
        builder: (context, state) => const CountdownScreen(),
      ),

      // 记账
      GoRoute(
        path: '/apps/accounting',
        name: 'accounting',
        builder: (context, state) => const AccountingScreen(),
      ),

      // 目标
      GoRoute(
        path: '/apps/goals',
        name: 'goals-list',
        builder: (context, state) => const GoalsListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'goal-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return GoalDetailScreen(id: id);
            },
          ),
        ],
      ),

      // 体重
      GoRoute(
        path: '/apps/weight',
        name: 'weight',
        builder: (context, state) => const WeightScreen(),
      ),
    ],
  );
});
```

## 路由常量

```dart
// lib/core/router/routes.dart
abstract class Routes {
  static const home = '/';
  static const todo = '/todo';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const settings = '/settings';

  static const memoList = '/apps/memo';
  static const memoNew = '/apps/memo/new';
  static String memoDetail(String id) => '/apps/memo/$id';

  static const diaryList = '/apps/diary';
  static const diaryNew = '/apps/diary/new';
  static String diaryDetail(String id) => '/apps/diary/$id';

  static const countdown = '/apps/countdown';
  static const accounting = '/apps/accounting';

  static const goalsList = '/apps/goals';
  static String goalDetail(String id) => '/apps/goals/$id';

  static const weight = '/apps/weight';

  static String calendarEvent(String id) => '/calendar/event/$id';
}
```

## MobileLayout

```dart
// lib/ui/layouts/mobile_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;

  const MobileLayout({super.key, required this.child});

  static const _navItems = [
    _NavItem(path: '/', label: '应用', icon: LucideIcons.layoutGrid),
    _NavItem(path: '/todo', label: 'Todo', icon: LucideIcons.checkSquare),
    _NavItem(path: '/calendar', label: '日历', icon: LucideIcons.calendar),
    _NavItem(path: '/profile', label: '我的', icon: LucideIcons.user),
  ];

  int _getSelectedIndex(String location) {
    if (location == '/' || location.startsWith('/apps')) return 0;
    if (location.startsWith('/todo')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(location);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => context.go(item.path),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;

  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
  });
}
```

## 页面转场动画

```dart
// 默认使用 Material 转场
// 可自定义特定页面的转场效果

GoRoute(
  path: '/settings',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const SettingsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: child,
        );
      },
    );
  },
),
```
