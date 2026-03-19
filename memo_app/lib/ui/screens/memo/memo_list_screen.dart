import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/memo_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/cards/memo_card.dart';
import '../../components/feedback/empty_state.dart';
import '../../components/inputs/search_input.dart';
import '../todo/widgets/category_filter.dart';
import 'widgets/display_settings_sheet.dart';

/// The main Memo list screen displaying memos with category filter.
class MemoListScreen extends ConsumerStatefulWidget {
  /// Creates a MemoListScreen.
  const MemoListScreen({super.key});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  String _activeCategory = '全部';
  String _viewMode = 'list'; // list, grid
  String _sortMode = 'updatedAt'; // createdAt, updatedAt
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _categories = ['全部', '工作', '生活', '学习'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch memos based on search state
    final memosAsync = _isSearching && _searchQuery.isNotEmpty
        ? ref.watch(searchMemosProvider(_searchQuery))
        : ref.watch(memoListProvider(
            category: _activeCategory == '全部' ? null : _activeCategory,
          ));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Search bar (when searching)
            if (_isSearching) _buildSearchBar(context),
            // Category Filter (when not searching)
            if (!_isSearching)
              CategoryFilter(
                categories: _categories,
                activeCategory: _activeCategory,
                onCategoryChanged: (cat) => setState(() => _activeCategory = cat),
              ),
            // Memo List
            Expanded(
              child: memosAsync.when(
                data: (memos) => _buildMemoContent(memos),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => CommonEmptyStates.error(
                  message: '加载失败: $e',
                  action: AppButton(
                    label: '重试',
                    variant: ButtonVariant.secondary,
                    onPressed: () => ref.invalidate(memoListProvider(
                      category: _activeCategory == '全部' ? null : _activeCategory,
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.memoNew),
        backgroundColor: isDark ? AppColorsDark.primary : AppColors.primary,
        foregroundColor: isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.background : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColorsDark.border : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Text(
              '备忘录',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
            ),
          ),
          // Search button
          IconButton(
            icon: Icon(
              _isSearching ? LucideIcons.x : LucideIcons.search,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          // Settings button
          IconButton(
            icon: Icon(
              LucideIcons.settings2,
              color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
            ),
            onPressed: () => _showDisplaySettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchInput(
        controller: _searchController,
        placeholder: '搜索备忘录...',
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onClear: () {
          setState(() {
            _searchQuery = '';
          });
        },
      ),
    );
  }

  Widget _buildMemoContent(List<Memo> memos) {
    // Handle search results
    if (_isSearching) {
      if (_searchQuery.isEmpty) {
        return const EmptyState(
          message: '输入关键词搜索备忘录',
          icon: LucideIcons.search,
        );
      }
      if (memos.isEmpty) {
        return CommonEmptyStates.noSearchResults(query: _searchQuery);
      }
      return _buildMemoList(memos, showSections: false);
    }

    // Check if empty
    if (memos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMemoList(memos, showSections: true);
  }

  Widget _buildMemoList(List<Memo> memos, {required bool showSections}) {
    // Sort memos based on sort mode
    final sortedMemos = List<Memo>.from(memos);
    sortedMemos.sort((a, b) {
      final aDate = _sortMode == 'createdAt' ? a.createdAt : a.updatedAt;
      final bDate = _sortMode == 'createdAt' ? b.createdAt : b.updatedAt;
      return bDate.compareTo(aDate); // Descending order (newest first)
    });

    if (!showSections) {
      // Simple list for search results
      return _buildMemoGrid(sortedMemos);
    }

    // Split into pinned and others
    final pinned = sortedMemos.where((m) => m.pinned).toList();
    final others = sortedMemos.where((m) => !m.pinned).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pinned section
        if (pinned.isNotEmpty) ...[
          _buildSectionHeader('置顶', LucideIcons.pin),
          const SizedBox(height: 12),
          _buildMemoGrid(pinned),
          const SizedBox(height: 24),
        ],
        // Others section
        if (others.isNotEmpty) ...[
          if (pinned.isNotEmpty) ...[
            _buildSectionHeader('其他', null),
            const SizedBox(height: 12),
          ],
          _buildMemoGrid(others),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData? icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoGrid(List<Memo> memos) {
    if (_viewMode == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: memos.length,
        itemBuilder: (context, index) {
          final memo = memos[index];
          return MemoCard(
            id: memo.id,
            title: memo.title,
            content: memo.content,
            category: memo.category,
            updatedAt: memo.updatedAt,
            pinned: memo.pinned,
            gridMode: true,
            onTap: () => context.push(Routes.memoDetail(memo.id)),
            onTogglePin: () => _togglePin(memo.id),
            onDelete: () => _confirmDelete(memo),
          );
        },
      );
    }

    // List mode
    return Column(
      children: memos.map((memo) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: MemoCard(
          id: memo.id,
          title: memo.title,
          content: memo.content,
          category: memo.category,
          updatedAt: memo.updatedAt,
          pinned: memo.pinned,
          gridMode: false,
          onTap: () => context.push(Routes.memoDetail(memo.id)),
          onTogglePin: () => _togglePin(memo.id),
          onDelete: () => _confirmDelete(memo),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState() {
    return CommonEmptyStates.noMemos(
      action: AppButton(
        label: '新建备忘录',
        icon: LucideIcons.plus,
        onPressed: () => context.push(Routes.memoNew),
      ),
    );
  }

  void _togglePin(String id) {
    ref
        .read(memoListProvider(
          category: _activeCategory == '全部' ? null : _activeCategory,
        ).notifier)
        .togglePin(id);
  }

  void _confirmDelete(Memo memo) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '删除备忘录',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '确定要删除「${memo.title}」吗？此操作无法撤销。',
          style: TextStyle(
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '删除',
              style: TextStyle(
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref
          .read(memoListProvider(
            category: _activeCategory == '全部' ? null : _activeCategory,
          ).notifier)
          .delete(memo.id);
    }
  }

  void _showDisplaySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DisplaySettingsSheet(
        viewMode: _viewMode,
        sortMode: _sortMode,
        onViewModeChanged: (mode) => setState(() => _viewMode = mode),
        onSortModeChanged: (mode) => setState(() => _sortMode = mode),
      ),
    );
  }
}
