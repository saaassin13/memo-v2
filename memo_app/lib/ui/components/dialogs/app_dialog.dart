import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// A customizable dialog component with title, description, content, and actions.
class AppDialog extends StatelessWidget {
  /// Creates an AppDialog.
  const AppDialog({
    super.key,
    required this.title,
    this.description,
    required this.content,
    this.actions,
  });

  /// The dialog title.
  final String title;

  /// Optional description text below the title.
  final String? description;

  /// The main content of the dialog.
  final Widget content;

  /// The action buttons at the bottom of the dialog.
  final List<Widget>? actions;

  /// Shows a dialog with the given parameters.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (context) => AppDialog(
        title: title,
        description: description,
        content: content,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          minWidth: 280,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              // Description
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ],
              // Content
              const SizedBox(height: 16),
              content,
              // Actions
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      actions![i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A confirmation dialog with cancel and confirm actions.
class AppConfirmDialog extends StatelessWidget {
  /// Creates an AppConfirmDialog.
  const AppConfirmDialog({
    super.key,
    required this.title,
    this.description,
    required this.message,
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.isDestructive = false,
  });

  /// The dialog title.
  final String title;

  /// Optional description text.
  final String? description;

  /// The confirmation message.
  final String message;

  /// The text for the cancel button.
  final String cancelText;

  /// The text for the confirm button.
  final String confirmText;

  /// Whether this is a destructive action.
  final bool isDestructive;

  /// Shows a confirmation dialog and returns true if confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? description,
    required String message,
    String cancelText = '取消',
    String confirmText = '确定',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => AppConfirmDialog(
        title: title,
        description: description,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          minWidth: 280,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              // Description
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                  ),
                ),
              ],
              // Message
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              // Actions
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? AppColorsDark.mutedForeground : AppColors.mutedForeground,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: isDestructive
                          ? (isDark ? AppColorsDark.destructive : AppColors.destructive)
                          : (isDark ? AppColorsDark.primary : AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(confirmText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
