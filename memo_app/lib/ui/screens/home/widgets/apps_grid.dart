import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

/// Predefined app items for the home screen grid
const appItems = [
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

/// A 3x2 grid displaying app entry tiles
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

/// Individual app tile with press animation
class _AppTile extends StatefulWidget {
  final AppItem app;

  const _AppTile({required this.app});

  @override
  State<_AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<_AppTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    context.push(widget.app.route);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05 * _shadowAnimation.value),
                    blurRadius: 4 * _shadowAnimation.value,
                    offset: Offset(0, 1 * _shadowAnimation.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
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
              child: Icon(
                widget.app.icon,
                size: 28,
                color: widget.app.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.app.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
