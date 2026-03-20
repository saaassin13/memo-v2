import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/memo_provider.dart';
import '../../components/badges/app_badge.dart';
import '../../components/badges/category_chip.dart';
import '../../components/feedback/empty_state.dart';

/// Combined detail and edit screen for memos.
/// Tap content to enter edit mode, supports WYSIWYG markdown editing.
class MemoDetailEditScreen extends ConsumerStatefulWidget {
  /// The memo ID for viewing/editing. Null for creating a new memo.
  final String? id;

  /// Creates a MemoDetailEditScreen.
  const MemoDetailEditScreen({super.key, this.id});

  @override
  ConsumerState<MemoDetailEditScreen> createState() =>
      _MemoDetailEditScreenState();
}

class _MemoDetailEditScreenState extends ConsumerState<MemoDetailEditScreen> {
  final _titleController = TextEditingController();
  late QuillController _quillController;
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  final _scrollController = ScrollController();

  String _category = '生活';
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isEditMode = false;
  Memo? _existingMemo;

  static const List<String> _categories = ['工作', '生活', '学习'];

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();

    if (widget.id != null) {
      _loadMemo();
    } else {
      _isInitialized = true;
      _isEditMode = true; // New memo starts in edit mode
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMemo() async {
    final memo = await ref.read(memoByIdProvider(widget.id!).future);
    if (memo != null && mounted) {
      setState(() {
        _existingMemo = memo;
        _titleController.text = memo.title;
        _category = memo.category;
        _isInitialized = true;
        // Convert plain text to Quill document
        if (memo.content.isNotEmpty) {
          _quillController = QuillController(
            document: Document()..insert(0, memo.content),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      });
    } else if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  String get _plainTextContent {
    return _quillController.document.toPlainText().trim();
  }

  bool get _hasChanges {
    if (widget.id == null) {
      return _titleController.text.trim().isNotEmpty ||
          _plainTextContent.isNotEmpty;
    } else {
      return _existingMemo != null &&
          (_titleController.text != _existingMemo!.title ||
              _plainTextContent != _existingMemo!.content ||
              _category != _existingMemo!.category);
    }
  }

  bool get _canSave {
    return _titleController.text.trim().isNotEmpty;
  }

  void _enterEditMode() {
    if (!_isEditMode) {
      setState(() {
        _isEditMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNew = widget.id == null;

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: Text(isNew ? '新建备忘录' : '备忘录'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // For existing memo that doesn't exist
    if (widget.id != null && _existingMemo == null && _isInitialized) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: const Text('备忘录'),
        ),
        body: const EmptyState(
          message: '备忘录不存在',
          description: '该备忘录可能已被删除',
          icon: LucideIcons.fileX,
        ),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isEditMode && _hasChanges) {
          final shouldPop = await _showDiscardDialog();
          if (shouldPop && mounted) {
            context.pop();
          }
        } else {
          if (mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColorsDark.background : AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () async {
              if (_isEditMode && _hasChanges) {
                final shouldPop = await _showDiscardDialog();
                if (shouldPop && mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
          title: Text(
            isNew
                ? '新建备忘录'
                : (_isEditMode ? '编辑备忘录' : '备忘录详情'),
            style: TextStyle(
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          actions: _buildAppBarActions(isDark),
        ),
        body: _isEditMode ? _buildEditMode(isDark) : _buildViewMode(isDark),
      ),
    );
  }

  List<Widget> _buildAppBarActions(bool isDark) {
    if (_isEditMode) {
      return [
        TextButton(
          onPressed: _canSave && !_isLoading ? _save : null,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColorsDark.primary : AppColors.primary,
                  ),
                )
              : Text(
                  '保存',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _canSave
                        ? (isDark ? AppColorsDark.primary : AppColors.primary)
                        : (isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground),
                  ),
                ),
        ),
        const SizedBox(width: 8),
      ];
    } else {
      return [
        if (_existingMemo != null) ...[
          IconButton(
            icon: Icon(
              _existingMemo!.pinned ? LucideIcons.pinOff : LucideIcons.pin,
              color: _existingMemo!.pinned
                  ? (isDark ? AppColorsDark.primary : AppColors.primary)
                  : (isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground),
            ),
            onPressed: () => _togglePin(),
            tooltip: _existingMemo!.pinned ? '取消置顶' : '置顶',
          ),
          IconButton(
            icon: Icon(
              LucideIcons.trash2,
              color: isDark ? AppColorsDark.destructive : AppColors.destructive,
            ),
            onPressed: () => _confirmDelete(context),
            tooltip: '删除',
          ),
        ],
      ];
    }
  }

  Widget _buildViewMode(bool isDark) {
    final memo = _existingMemo!;

    return GestureDetector(
      onTap: _enterEditMode,
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category and pin status
            Row(
              children: [
                AppBadge(
                  label: memo.category,
                  color: _getCategoryColor(memo.category),
                  backgroundColor:
                      _getCategoryColor(memo.category).withOpacity(0.15),
                ),
                if (memo.pinned) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColorsDark.primary : AppColors.primary)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.pin,
                          size: 12,
                          color:
                              isDark ? AppColorsDark.primary : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '置顶',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColorsDark.primary
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                // Edit hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColorsDark.muted : AppColors.muted)
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.pencil,
                        size: 12,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '点击编辑',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              memo.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Timestamps
            Row(
              children: [
                Icon(
                  LucideIcons.calendarDays,
                  size: 14,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '创建于 ${_formatDate(memo.createdAt)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '更新于 ${_formatDate(memo.updatedAt)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(
              color: isDark ? AppColorsDark.border : AppColors.border,
              height: 1,
            ),
            const SizedBox(height: 24),

            // Content
            if (memo.content.isEmpty)
              Text(
                '暂无内容',
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              )
            else
              Text(
                memo.content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color:
                      isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title input
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  autofocus: widget.id == null,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '标题',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Category selector
                Text(
                  '分类',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _categories
                      .map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: cat,
                              selected: _category == cat,
                              onTap: () => setState(() => _category = cat),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Content label
                Text(
                  '内容',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),

                // Quill editor
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColorsDark.input : AppColors.input,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Toolbar
                      QuillSimpleToolbar(
                        controller: _quillController,
                        config: QuillSimpleToolbarConfig(
                          showBoldButton: true,
                          showItalicButton: true,
                          showUnderLineButton: true,
                          showStrikeThrough: false,
                          showListBullets: true,
                          showListNumbers: true,
                          showCodeBlock: true,
                          showQuote: true,
                          showLink: false,
                          showBackgroundColorButton: false,
                          showColorButton: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showHeaderStyle: true,
                          showClearFormat: true,
                          showAlignmentButtons: false,
                          showInlineCode: true,
                          showUndo: true,
                          showRedo: true,
                          multiRowsDisplay: false,
                        ),
                      ),
                      Divider(
                        color: isDark ? AppColorsDark.border : AppColors.border,
                        height: 1,
                      ),
                      // Editor
                      Container(
                        constraints: const BoxConstraints(minHeight: 200),
                        padding: const EdgeInsets.all(16),
                        child: QuillEditor.basic(
                          controller: _quillController,
                          focusNode: _contentFocusNode,
                          config: QuillEditorConfig(
                            placeholder: '记录你的想法...',
                            padding: EdgeInsets.zero,
                            expands: false,
                            scrollable: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showDiscardDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '放弃更改？',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '你有未保存的更改，确定要放弃吗？',
          style: TextStyle(
            color: isDark
                ? AppColorsDark.mutedForeground
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '继续编辑',
              style: TextStyle(
                color: isDark ? AppColorsDark.primary : AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '放弃',
              style: TextStyle(
                color: isDark ? AppColorsDark.destructive : AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    if (!_canSave || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _plainTextContent;

      if (widget.id != null && _existingMemo != null) {
        // Update existing memo
        final updatedMemo = Memo(
          id: _existingMemo!.id,
          title: title,
          content: content,
          category: _category,
          pinned: _existingMemo!.pinned,
          createdAt: _existingMemo!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref.read(memoListProvider().notifier).updateMemo(updatedMemo);
        ref.invalidate(memoByIdProvider(widget.id!));

        // Reload memo and exit edit mode
        final updated = await ref.read(memoByIdProvider(widget.id!).future);
        if (mounted && updated != null) {
          setState(() {
            _existingMemo = updated;
            _isEditMode = false;
          });
        }
      } else {
        // Create new memo
        await ref.read(memoListProvider().notifier).add(
              title: title,
              content: content,
              category: _category,
            );

        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePin() {
    if (_existingMemo != null) {
      ref.read(memoListProvider().notifier).togglePin(_existingMemo!.id);
      // Refresh
      ref.invalidate(memoByIdProvider(widget.id!));
      _loadMemo();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
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
          '确定要删除「${_existingMemo!.title}」吗？此操作无法撤销。',
          style: TextStyle(
            color: isDark
                ? AppColorsDark.mutedForeground
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
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
      await ref.read(memoListProvider().notifier).delete(_existingMemo!.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '工作':
        return AppColors.chart1;
      case '生活':
        return AppColors.accent;
      case '学习':
        return AppColors.chart3;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (dateDay == today) {
      return '今天 $time';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return '昨天 $time';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日 $time';
    } else {
      return '${date.year}年${date.month}月${date.day}日 $time';
    }
  }
}
