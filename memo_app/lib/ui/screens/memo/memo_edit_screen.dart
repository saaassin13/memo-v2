import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/memo_provider.dart';
import '../../components/badges/category_chip.dart';

/// Screen for creating or editing a memo.
class MemoEditScreen extends ConsumerStatefulWidget {
  /// The memo ID for editing. Null for creating a new memo.
  final String? id;

  /// Creates a MemoEditScreen.
  const MemoEditScreen({super.key, this.id});

  @override
  ConsumerState<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends ConsumerState<MemoEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  String _category = '生活';
  bool _isLoading = false;
  bool _isInitialized = false;
  Memo? _existingMemo;

  static const List<String> _categories = ['工作', '生活', '学习'];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadMemo();
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMemo() async {
    final memo = await ref.read(memoByIdProvider(widget.id!).future);
    if (memo != null && mounted) {
      setState(() {
        _existingMemo = memo;
        _titleController.text = memo.title;
        _contentController.text = memo.content;
        _category = memo.category;
        _isInitialized = true;
      });
    } else if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  bool get _hasChanges {
    if (widget.id == null) {
      // New memo: has changes if title or content is not empty
      return _titleController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty;
    } else {
      // Editing: has changes if any field differs from original
      return _existingMemo != null &&
          (_titleController.text != _existingMemo!.title ||
              _contentController.text != _existingMemo!.content ||
              _category != _existingMemo!.category);
    }
  }

  bool get _canSave {
    return _titleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.id != null;

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: Text(isEditing ? '编辑备忘录' : '新建备忘录'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? AppColorsDark.background : AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
            onPressed: () async {
              if (_hasChanges) {
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
            isEditing ? '编辑备忘录' : '新建备忘录',
            style: TextStyle(
              color: isDark ? AppColorsDark.foreground : AppColors.foreground,
            ),
          ),
          actions: [
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
                            : (isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
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
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                decoration: InputDecoration(
                  hintText: '标题',
                  hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
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
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: cat,
                    selected: _category == cat,
                    onTap: () => setState(() => _category = cat),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),

              // Content input
              Text(
                '内容',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.input : AppColors.input,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  maxLines: null,
                  minLines: 10,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '记录你的想法...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ),
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
            color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
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
      final content = _contentController.text.trim();

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
        // Invalidate the single memo provider to refresh detail page
        ref.invalidate(memoByIdProvider(widget.id!));
      } else {
        // Create new memo
        await ref.read(memoListProvider().notifier).add(
          title: title,
          content: content,
          category: _category,
        );
      }

      if (mounted) {
        context.pop();
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
}
