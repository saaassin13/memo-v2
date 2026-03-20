import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../data/database/app_database.dart';
import '../../../providers/diary_provider.dart';
import '../../components/buttons/app_button.dart';
import '../../components/feedback/empty_state.dart';
import 'widgets/mood_selector.dart';
import 'widgets/weather_selector.dart';

/// Combined detail and edit screen for diary entries.
/// Tap content to enter edit mode, supports WYSIWYG markdown editing.
class DiaryDetailEditScreen extends ConsumerStatefulWidget {
  /// The diary ID for viewing/editing. Null for creating a new diary.
  final String? id;

  /// Initial date for new diary (optional).
  final DateTime? initialDate;

  /// Creates a DiaryDetailEditScreen.
  const DiaryDetailEditScreen({super.key, this.id, this.initialDate});

  @override
  ConsumerState<DiaryDetailEditScreen> createState() =>
      _DiaryDetailEditScreenState();
}

class _DiaryDetailEditScreenState extends ConsumerState<DiaryDetailEditScreen> {
  final _titleController = TextEditingController();
  late QuillController _quillController;
  final _contentFocusNode = FocusNode();

  late DateTime _date;
  Weather _weather = Weather.sunny;
  Mood _mood = Mood.happy;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isEditMode = false;
  DiaryEntry? _existingDiary;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _date = widget.initialDate ?? DateTime.now();

    if (widget.id != null) {
      _loadDiary();
    } else {
      _isInitialized = true;
      _isEditMode = true; // New diary starts in edit mode
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDiary() async {
    final diary = await ref.read(diaryByIdProvider(widget.id!).future);
    if (diary != null && mounted) {
      setState(() {
        _existingDiary = diary;
        _titleController.text = diary.title;
        _date = diary.date;
        _weather = Weather.fromValue(diary.weather) ?? Weather.sunny;
        _mood = Mood.fromValue(diary.mood) ?? Mood.happy;
        _isInitialized = true;
        // Load content from Delta JSON format or plain text
        if (diary.content.isNotEmpty) {
          try {
            // Try to parse as Delta JSON
            final deltaJson = jsonDecode(diary.content) as List;
            _quillController = QuillController(
              document: Document.fromJson(deltaJson),
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (_) {
            // Fallback to plain text if not valid JSON
            _quillController = QuillController(
              document: Document()..insert(0, diary.content),
              selection: const TextSelection.collapsed(offset: 0),
            );
          }
        }
      });
    } else if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  /// Get content as Delta JSON for preserving format
  String get _deltaJsonContent {
    return jsonEncode(_quillController.document.toDelta().toJson());
  }

  /// Get plain text content for display/preview
  String get _plainTextContent {
    return _quillController.document.toPlainText().trim();
  }

  bool get _hasChanges {
    if (widget.id == null) {
      return _titleController.text.trim().isNotEmpty ||
          _plainTextContent.isNotEmpty;
    } else {
      return _existingDiary != null &&
          (_titleController.text != _existingDiary!.title ||
              _plainTextContent != _existingDiary!.content ||
              _weather.value != _existingDiary!.weather ||
              _mood.value != _existingDiary!.mood);
    }
  }

  bool get _canSave {
    return _plainTextContent.isNotEmpty;
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
          title: Text(isNew ? '写日记' : '日记'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // For existing diary that doesn't exist
    if (widget.id != null && _existingDiary == null && _isInitialized) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: const Text('日记'),
        ),
        body: CommonEmptyStates.error(
          message: '日记不存在',
          action: AppButton(
            label: '返回',
            variant: ButtonVariant.secondary,
            onPressed: () => context.pop(),
          ),
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
            isNew ? '写日记' : (_isEditMode ? '编辑日记' : '日记详情'),
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
        IconButton(
          icon: Icon(
            LucideIcons.trash2,
            color: isDark ? AppColorsDark.destructive : AppColors.destructive,
          ),
          onPressed: () => _confirmDelete(context, isDark),
        ),
        const SizedBox(width: 8),
      ];
    }
  }

  Widget _buildViewMode(bool isDark) {
    final diary = _existingDiary!;
    final weather = Weather.fromValue(diary.weather);
    final mood = Mood.fromValue(diary.mood);

    return GestureDetector(
      onTap: _enterEditMode,
      behavior: HitTestBehavior.opaque,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date display with weather and mood on right - NEW LAYOUT (Bug 3)
          _buildDateHeaderWithIcons(isDark, diary.date, weather, mood),
          const SizedBox(height: 24),

          // Edit hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.muted : AppColors.muted)
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.pencil,
                  size: 14,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  '点击任意位置编辑',
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
          const SizedBox(height: 24),

          // Title (if exists)
          if (diary.title.isNotEmpty) ...[
            Text(
              diary.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Content - render as Quill document for rich text display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.card : AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildContentDisplay(diary.content, isDark),
          ),
          const SizedBox(height: 24),

          // Timestamps
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.muted : AppColors.muted)
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '创建于 ${_formatDateTime(diary.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                if (diary.updatedAt != diary.createdAt) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.pencil,
                        size: 14,
                        color: isDark
                            ? AppColorsDark.mutedForeground
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '更新于 ${_formatDateTime(diary.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColorsDark.mutedForeground
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the date header with weather and mood icons on the right (Bug 3)
  Widget _buildDateHeaderWithIcons(
      bool isDark, DateTime date, Weather? weather, Mood? mood) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColorsDark.primary : AppColors.primary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left side: Date
          Expanded(
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: isDark ? AppColorsDark.primary : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColorsDark.primary : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Right side: Weather and Mood icons (clickable in edit mode)
          Row(
            children: [
              if (weather != null)
                _buildIconButton(
                  icon: weather.icon,
                  color: _getWeatherColor(weather, isDark),
                  tooltip: weather.label,
                  onTap: _isEditMode ? () => _showWeatherPicker() : null,
                ),
              const SizedBox(width: 8),
              if (mood != null)
                _buildMoodButton(
                  emoji: mood.emoji,
                  tooltip: mood.label,
                  onTap: _isEditMode ? () => _showMoodPicker() : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _buildMoodButton({
    required String emoji,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  void _showWeatherPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择天气',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            WeatherSelector(
              selected: _weather,
              onChanged: (w) {
                setState(() => _weather = w);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMoodPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择心情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            MoodSelector(
              selected: _mood,
              onChanged: (m) {
                setState(() => _mood = m);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build content display widget that renders rich text from Delta JSON
  Widget _buildContentDisplay(String content, bool isDark) {
    try {
      final deltaJson = jsonDecode(content) as List;
      final document = Document.fromJson(deltaJson);
      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      return QuillEditor.basic(
        controller: controller,
        config: QuillEditorConfig(
          padding: EdgeInsets.zero,
          expands: false,
          scrollable: false,
          showCursor: false,
        ),
      );
    } catch (_) {
      // Fallback to plain text if not valid JSON
      return Text(
        content,
        style: TextStyle(
          fontSize: 15,
          height: 1.8,
          color: isDark ? AppColorsDark.foreground : AppColors.foreground,
        ),
      );
    }
  }

  Widget _buildEditMode(bool isDark) {
    return Column(
      children: [
        // Header section (non-scrollable)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date display with clickable weather and mood icons
              // (No separate weather/mood selectors - click icons to change)
              _buildDateHeaderWithIcons(isDark, _date, _weather, _mood),
              const SizedBox(height: 16),

              // Title input (optional)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.input : AppColors.input,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColorsDark.foreground : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '给今天起个标题...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // Quill editor (fullscreen, takes remaining space)
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    showCodeBlock: false,
                    showQuote: true,
                    showLink: false,
                    showBackgroundColorButton: false,
                    showColorButton: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showHeaderStyle: true,
                    showClearFormat: true,
                    showAlignmentButtons: false,
                    showInlineCode: false,
                    showUndo: true,
                    showRedo: true,
                    multiRowsDisplay: false,
                  ),
                ),
                Divider(
                  color: isDark ? AppColorsDark.border : AppColors.border,
                  height: 1,
                ),
                // Editor (expanded to fill remaining space)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: QuillEditor.basic(
                      controller: _quillController,
                      focusNode: _contentFocusNode,
                      config: QuillEditorConfig(
                        placeholder: '今天发生了什么...',
                        padding: EdgeInsets.zero,
                        expands: true,
                        scrollable: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getWeatherColor(Weather weather, bool isDark) {
    switch (weather) {
      case Weather.sunny:
        return const Color(0xFFF59E0B);
      case Weather.cloudy:
        return isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground;
      case Weather.rainy:
        return const Color(0xFF3B82F6);
      case Weather.snowy:
        return const Color(0xFF06B6D4);
      case Weather.thunder:
        return const Color(0xFF8B5CF6);
      case Weather.windy:
        return const Color(0xFF10B981);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
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
      // Save content as Delta JSON to preserve formatting
      final content = _deltaJsonContent;

      if (widget.id != null && _existingDiary != null) {
        // Update existing diary
        final updatedDiary = DiaryEntry(
          id: _existingDiary!.id,
          date: _date,
          title: title,
          content: content,
          mood: _mood.value,
          weather: _weather.value,
          images: _existingDiary!.images,
          createdAt: _existingDiary!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref
            .read(diaryListProvider(year: _date.year, month: _date.month)
                .notifier)
            .updateEntry(updatedDiary);
        ref.invalidate(diaryByIdProvider(widget.id!));

        // Reload and exit edit mode
        final updated = await ref.read(diaryByIdProvider(widget.id!).future);
        if (mounted && updated != null) {
          setState(() {
            _existingDiary = updated;
            _isEditMode = false;
          });
        }
      } else {
        // Create new diary
        await ref
            .read(diaryListProvider(year: _date.year, month: _date.month)
                .notifier)
            .add(
              date: _date,
              title: title,
              content: content,
              mood: _mood.value,
              weather: _weather.value,
            );

        // Invalidate related providers
        ref.invalidate(diaryDatesProvider(_date.year, _date.month));
        ref.invalidate(diaryByDateProvider(_date));

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

  void _confirmDelete(BuildContext context, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '删除日记',
          style: TextStyle(
            color: isDark ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        content: Text(
          '确定要删除这篇日记吗？此操作无法撤销。',
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

    if (confirmed == true && mounted) {
      final now = DateTime.now();
      ref
          .read(diaryListProvider(year: now.year, month: now.month).notifier)
          .delete(widget.id!);
      context.pop();
    }
  }
}
