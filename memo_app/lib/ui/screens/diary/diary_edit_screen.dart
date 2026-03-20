import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/diary_provider.dart';
import '../../components/inputs/app_textarea.dart';
import 'widgets/mood_selector.dart';
import 'widgets/weather_selector.dart';

/// Screen for creating or editing a diary entry.
class DiaryEditScreen extends ConsumerStatefulWidget {
  /// The diary ID for editing. Null for creating a new diary.
  final String? id;

  /// Initial date for new diary (optional).
  final DateTime? initialDate;

  /// Creates a DiaryEditScreen.
  const DiaryEditScreen({super.key, this.id, this.initialDate});

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentFocusNode = FocusNode();

  late DateTime _date;
  Weather _weather = Weather.sunny;
  Mood _mood = Mood.happy;
  bool _isLoading = false;
  bool _isInitialized = false;
  DiaryEntry? _existingDiary;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();

    if (widget.id != null) {
      _loadDiary();
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDiary() async {
    final diary = await ref.read(diaryByIdProvider(widget.id!).future);
    if (diary != null && mounted) {
      setState(() {
        _existingDiary = diary;
        _titleController.text = diary.title;
        _contentController.text = diary.content;
        _date = diary.date;
        _weather = Weather.fromValue(diary.weather) ?? Weather.sunny;
        _mood = Mood.fromValue(diary.mood) ?? Mood.happy;
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
      // New diary: has changes if content is not empty
      return _titleController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty;
    } else {
      // Editing: has changes if any field differs from original
      return _existingDiary != null &&
          (_titleController.text != _existingDiary!.title ||
              _contentController.text != _existingDiary!.content ||
              _weather.value != _existingDiary!.weather ||
              _mood.value != _existingDiary!.mood);
    }
  }

  bool get _canSave {
    return _contentController.text.trim().isNotEmpty;
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
          title: Text(isEditing ? '编辑日记' : '写日记'),
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
            isEditing ? '编辑日记' : '写日记',
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
                            : (isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date display
            _buildDateDisplay(context, isDark),
            const SizedBox(height: 24),

            // Weather selector
            Text(
              '天气',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            WeatherSelector(
              selected: _weather,
              onChanged: (w) => setState(() => _weather = w),
            ),
            const SizedBox(height: 24),

            // Mood selector
            Text(
              '心情',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            MoodSelector(
              selected: _mood,
              onChanged: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 24),

            // Title input (optional)
            Text(
              '标题（可选）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColorsDark.mutedForeground
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.input : AppColors.input,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
                decoration: InputDecoration(
                  hintText: '给今天起个标题...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColorsDark.mutedForeground
                        : AppColors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            // Content
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
            AppTextArea(
              controller: _contentController,
              focusNode: _contentFocusNode,
              placeholder: '今天发生了什么...',
              minLines: 10,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDisplay(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.primary : AppColors.primary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.calendar,
            color: isDark ? AppColorsDark.primary : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(_date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColorsDark.primary : AppColors.primary,
            ),
          ),
        ],
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
      final content = _contentController.text.trim();
      // Ensure mood and weather always have values
      final moodValue = _mood.value;
      final weatherValue = _weather.value;

      if (widget.id != null && _existingDiary != null) {
        // Update existing diary
        // Normalize date to midnight to ensure consistent date matching
        final normalizedDate = DateTime(_date.year, _date.month, _date.day);
        final updatedDiary = DiaryEntry(
          id: _existingDiary!.id,
          date: normalizedDate,
          title: title,
          content: content,
          mood: moodValue,
          weather: weatherValue,
          images: _existingDiary!.images,
          createdAt: _existingDiary!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref
            .read(diaryListProvider(year: _date.year, month: _date.month).notifier)
            .updateEntry(updatedDiary);
        // Invalidate the single diary provider to refresh detail page
        ref.invalidate(diaryByIdProvider(widget.id!));
      } else {
        // Create new diary
        await ref
            .read(diaryListProvider(year: _date.year, month: _date.month).notifier)
            .add(
              date: _date,
              title: title,
              content: content,
              mood: moodValue,
              weather: weatherValue,
            );
      }

      // Invalidate diary dates to refresh calendar indicators
      ref.invalidate(diaryDatesProvider(_date.year, _date.month));
      // Invalidate diary by date to refresh selected date display
      ref.invalidate(diaryByDateProvider(_date));

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
