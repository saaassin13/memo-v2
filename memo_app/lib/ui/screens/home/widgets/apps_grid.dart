import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/router/routes.dart';

/// Model representing an app entry in the grid
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

/// All available app items
const _allAppItems = [
  AppItem(
    id: 'memo',
    name: '备忘录',
    icon: LucideIcons.fileText,
    route: Routes.memoList,
    color: AppColors.primary,
  ),
  AppItem(
    id: 'countdown',
    name: '倒数纪念日',
    icon: LucideIcons.calendarHeart,
    route: Routes.countdown,
    color: AppColors.chart4,
  ),
  AppItem(
    id: 'diary',
    name: '日记',
    icon: LucideIcons.bookOpen,
    route: Routes.diaryList,
    color: AppColors.accent,
  ),
  AppItem(
    id: 'accounting',
    name: '记账',
    icon: LucideIcons.wallet,
    route: Routes.accounting,
    color: AppColors.chart3,
  ),
  AppItem(
    id: 'goals',
    name: '目标',
    icon: LucideIcons.target,
    route: Routes.goalsList,
    color: AppColors.chart1,
  ),
  AppItem(
    id: 'weight',
    name: '体重',
    icon: LucideIcons.scale,
    route: Routes.weight,
    color: AppColors.chart5,
  ),
];

const _defaultOrder = ['memo', 'countdown', 'diary', 'accounting', 'goals', 'weight'];

/// A 3x2 grid with long-press drag reorder
class AppsGrid extends StatefulWidget {
  const AppsGrid({super.key});

  @override
  State<AppsGrid> createState() => _AppsGridState();
}

class _AppsGridState extends State<AppsGrid> {
  late List<AppItem> _orderedItems;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _orderedItems = List.from(_allAppItems);
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final order = prefs.getStringList('app_grid_order') ?? _defaultOrder;
    final itemMap = {for (final item in _allAppItems) item.id: item};
    final ordered = <AppItem>[];
    for (final id in order) {
      if (itemMap.containsKey(id)) ordered.add(itemMap[id]!);
    }
    for (final item in _allAppItems) {
      if (!ordered.any((e) => e.id == item.id)) ordered.add(item);
    }
    if (mounted) setState(() => _orderedItems = ordered);
    _loaded = true;
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'app_grid_order',
      _orderedItems.map((e) => e.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(height: 240);

    return ReorderableGridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      dragStartDelay: const Duration(milliseconds: 300),
      onDragStart: (_) => HapticFeedback.mediumImpact(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final item = _orderedItems.removeAt(oldIndex);
          _orderedItems.insert(newIndex, item);
        });
        _saveOrder();
      },
      children: _orderedItems
          .map((app) => _AppTile(key: ValueKey(app.id), app: app))
          .toList(),
    );
  }
}

/// Individual app tile with press animation
class _AppTile extends StatefulWidget {
  final AppItem app;

  const _AppTile({required ValueKey super.key, required this.app});

  @override
  State<_AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<_AppTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => context.push(widget.app.route),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.05);
          final shadowOpacity = 1.0 - (_controller.value * 0.5);
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05 * shadowOpacity),
                    blurRadius: 4 * shadowOpacity,
                    offset: Offset(0, 1 * shadowOpacity),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.app.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(widget.app.icon, size: 28, color: widget.app.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.app.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
