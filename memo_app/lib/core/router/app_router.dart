import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/layouts/mobile_layout.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/todo/todo_screen.dart';
import '../../ui/screens/calendar/calendar_screen.dart';
import '../../ui/screens/calendar/calendar_event_screen.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/screens/memo/memo_list_screen.dart';
import '../../ui/screens/memo/memo_detail_edit_screen.dart';
import '../../ui/screens/diary/diary_list_screen.dart';
import '../../ui/screens/diary/diary_detail_edit_screen.dart';
import '../../ui/screens/countdown/countdown_screen.dart';
import '../../ui/screens/accounting/accounting_screen.dart';
import '../../ui/screens/accounting/accounting_stats_screen.dart';
import '../../ui/screens/goals/goals_list_screen.dart';
import '../../ui/screens/goals/goal_detail_screen.dart';
import '../../ui/screens/weight/weight_screen.dart';
import 'page_transitions.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Main shell with bottom navigation
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
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PageTransitions.slideFromRight(
                    key: state.pageKey,
                    child: CalendarEventScreen(id: id),
                  );
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

      // Settings (no bottom nav) - slide from right
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),

      // Memo module - using combined detail/edit screen
      GoRoute(
        path: '/apps/memo',
        name: 'memo-list',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const MemoListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: 'memo-new',
            pageBuilder: (context, state) => PageTransitions.slideFromBottom(
              key: state.pageKey,
              child: const MemoDetailEditScreen(),
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'memo-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return PageTransitions.slideFromRight(
                key: state.pageKey,
                child: MemoDetailEditScreen(id: id),
              );
            },
          ),
        ],
      ),

      // Diary module - using combined detail/edit screen
      GoRoute(
        path: '/apps/diary',
        name: 'diary-list',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const DiaryListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            name: 'diary-new',
            pageBuilder: (context, state) {
              // Parse optional date parameter
              final dateStr = state.uri.queryParameters['date'];
              DateTime? initialDate;
              if (dateStr != null) {
                initialDate = DateTime.tryParse(dateStr);
              }
              return PageTransitions.slideFromBottom(
                key: state.pageKey,
                child: DiaryDetailEditScreen(initialDate: initialDate),
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'diary-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return PageTransitions.slideFromRight(
                key: state.pageKey,
                child: DiaryDetailEditScreen(id: id),
              );
            },
          ),
        ],
      ),

      // Countdown
      GoRoute(
        path: '/apps/countdown',
        name: 'countdown',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const CountdownScreen(),
        ),
      ),

      // Accounting
      GoRoute(
        path: '/apps/accounting',
        name: 'accounting',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const AccountingScreen(),
        ),
        routes: [
          GoRoute(
            path: 'stats',
            name: 'accounting-stats',
            pageBuilder: (context, state) => PageTransitions.slideFromRight(
              key: state.pageKey,
              child: const AccountingStatsScreen(),
            ),
          ),
        ],
      ),

      // Goals
      GoRoute(
        path: '/apps/goals',
        name: 'goals-list',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const GoalsListScreen(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'goal-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return PageTransitions.slideFromRight(
                key: state.pageKey,
                child: GoalDetailScreen(id: id),
              );
            },
          ),
        ],
      ),

      // Weight
      GoRoute(
        path: '/apps/weight',
        name: 'weight',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          key: state.pageKey,
          child: const WeightScreen(),
        ),
      ),
    ],
  );
});
