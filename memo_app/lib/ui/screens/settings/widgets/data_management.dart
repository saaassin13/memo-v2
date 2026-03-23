import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../data/database/app_database.dart';
import '../../../../providers/database_provider.dart';

/// 数据管理组件
class DataManagement extends ConsumerWidget {
  const DataManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据管理',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _MenuItem(
                icon: LucideIcons.download,
                title: '数据备份',
                subtitle: '导出所有数据到文件',
                onTap: () => _handleBackup(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              _MenuItem(
                icon: LucideIcons.upload,
                title: '数据恢复',
                subtitle: '从备份文件恢复数据',
                onTap: () => _handleRestore(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              _MenuItem(
                icon: LucideIcons.trash2,
                title: '清除数据',
                subtitle: '删除所有本地数据',
                destructive: true,
                onTap: () => _handleClearData(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 处理数据备份
  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    try {
      _showLoadingDialog(context, '正在备份数据...');
      final db = ref.read(appDatabaseProvider);
      final backupData = await _exportData(db);

      // 收集所有图片路径
      final imagePaths = await _collectImagePaths(db);
      debugPrint('[Backup] 收集到 ${imagePaths.length} 张图片: $imagePaths');

      // 创建 ZIP 归档
      final archive = Archive();

      // 添加 backup.json
      final jsonBytes = utf8.encode(jsonEncode(backupData));
      archive.addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes));

      // 添加图片文件
      for (final imagePath in imagePaths) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();
          final fileName = 'images/${p.basename(imagePath)}';
          archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
        }
      }

      // 编码为 ZIP
      final zipBytes = ZipEncoder().encode(archive)!;

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final tempFile = File('${tempDir.path}/memo_backup_$timestamp.zip');
      await tempFile.writeAsBytes(zipBytes);

      if (context.mounted) Navigator.of(context).pop();

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存备份文件',
        fileName: 'memo_backup_$timestamp.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: Uint8List.fromList(zipBytes),
      );

      if (context.mounted) {
        if (savedPath != null) {
          _showSuccessSnackBar(context, '备份已保存（含 ${imagePaths.length} 张图片）');
        } else {
          _showErrorSnackBar(context, '已取消保存');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, '备份失败: $e');
      }
    }
  }

  /// 处理数据恢复
  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: '恢复数据',
      content: '恢复数据将覆盖当前所有数据，确定要继续吗？',
    );
    if (!confirmed || !context.mounted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final fileBytes = await file.readAsBytes();

      if (!context.mounted) return;
      _showLoadingDialog(context, '正在恢复数据...');

      final db = ref.read(appDatabaseProvider);
      Map<String, dynamic> data;
      Map<String, List<int>> imageFiles = {};

      // 判断是 ZIP 还是旧版 JSON
      if (file.path.endsWith('.zip')) {
        final archive = ZipDecoder().decodeBytes(fileBytes);
        // 读取 backup.json
        final jsonFile = archive.findFile('backup.json');
        if (jsonFile == null) {
          throw Exception('备份文件格式无效：缺少 backup.json');
        }
        data = jsonDecode(utf8.decode(jsonFile.content as List<int>)) as Map<String, dynamic>;
        // 读取图片文件
        for (final archiveFile in archive) {
          if (archiveFile.name.startsWith('images/') && archiveFile.isFile) {
            final fileName = p.basename(archiveFile.name);
            imageFiles[fileName] = archiveFile.content!;
          }
        }
        debugPrint('[Restore] ZIP 中找到 ${imageFiles.length} 张图片: ${imageFiles.keys.toList()}');
      } else {
        // 兼容旧版 JSON 格式
        data = jsonDecode(utf8.decode(fileBytes)) as Map<String, dynamic>;
      }

      // 恢复图片文件并构建路径映射
      final pathMapping = <String, String>{};
      if (imageFiles.isNotEmpty) {
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/memo_images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        for (final entry in imageFiles.entries) {
          final imageFile = File('${imagesDir.path}/${entry.key}');
          await imageFile.writeAsBytes(entry.value);
          pathMapping[entry.key] = imageFile.path;
        }
      }
      debugPrint('[Restore] pathMapping: $pathMapping');

      await _importData(db, data, pathMapping);

      if (context.mounted) {
        Navigator.of(context).pop();
        final imageCount = imageFiles.length;
        _showSuccessSnackBar(
          context,
          imageCount > 0 ? '数据恢复成功（含 $imageCount 张图片）' : '数据恢复成功',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, '恢复失败: $e');
      }
    }
  }

  /// 处理清除数据
  Future<void> _handleClearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: '清除数据',
      content: '此操作将删除所有本地数据且无法恢复，确定要继续吗？',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      _showLoadingDialog(context, '正在清除数据...');
      final db = ref.read(appDatabaseProvider);
      await _clearAllData(db);

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar(context, '数据已清除');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, '清除失败: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _exportData(AppDatabase db) async {
    final todos = await db.select(db.todos).get();
    final memos = await db.select(db.memos).get();
    final diaries = await db.select(db.diaryEntries).get();
    final transactions = await db.select(db.transactions).get();
    final goals = await db.select(db.goals).get();
    final goalProgressRecords = await db.select(db.goalProgressRecords).get();
    final weights = await db.select(db.weightRecords).get();
    final countdowns = await db.select(db.countdowns).get();

    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'todos': todos.map((e) => {
        'id': e.id, 'title': e.title, 'category': e.category,
        'dueDate': e.dueDate?.toIso8601String(), 'note': e.note,
        'completed': e.completed, 'remind': e.remind,
        'remindAdvance': e.remindAdvance,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
      'memos': memos.map((e) => {
        'id': e.id, 'title': e.title, 'content': e.content,
        'category': e.category, 'pinned': e.pinned,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
      'diaries': diaries.map((e) => {
        'id': e.id, 'date': e.date.toIso8601String(), 'title': e.title,
        'content': e.content, 'mood': e.mood, 'weather': e.weather,
        'images': e.images, 'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
      'transactions': transactions.map((e) => {
        'id': e.id, 'type': e.type, 'amount': e.amount, 'category': e.category,
        'note': e.note, 'date': e.date.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'goals': goals.map((e) => {
        'id': e.id, 'title': e.title, 'description': e.description,
        'type': e.type, 'targetValue': e.targetValue, 'currentValue': e.currentValue,
        'unit': e.unit, 'startDate': e.startDate.toIso8601String(),
        'endDate': e.endDate?.toIso8601String(),
        'completed': e.completed, 'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
      'goalProgressRecords': goalProgressRecords.map((e) => {
        'id': e.id, 'goalId': e.goalId, 'previousValue': e.previousValue,
        'newValue': e.newValue, 'change': e.change, 'note': e.note,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'weights': weights.map((e) => {
        'id': e.id, 'weight': e.weight, 'date': e.date.toIso8601String(),
        'note': e.note, 'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'countdowns': countdowns.map((e) => {
        'id': e.id, 'title': e.title, 'targetDate': e.targetDate.toIso8601String(),
        'type': e.type, 'repeatYearly': e.repeatYearly, 'remind': e.remind,
        'remindAdvance': e.remindAdvance,
        'color': e.color, 'icon': e.icon,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      }).toList(),
    };
  }

  Future<void> _importData(AppDatabase db, Map<String, dynamic> data, Map<String, String> pathMapping) async {
    await _clearAllData(db);

    // Import todos
    final todos = data['todos'] as List? ?? [];
    for (final item in todos) {
      await db.into(db.todos).insert(TodosCompanion.insert(
        id: item['id'],
        title: item['title'],
        category: Value(item['category'] ?? '杂项'),
        dueDate: Value(item['dueDate'] != null ? DateTime.parse(item['dueDate']) : null),
        note: Value(item['note']),
        completed: Value(item['completed'] ?? false),
        remind: Value(item['remind'] ?? false),
        remindAdvance: Value(item['remindAdvance'] ?? 1440),
        createdAt: DateTime.parse(item['createdAt']),
        updatedAt: DateTime.parse(item['updatedAt']),
      ));
    }

    // Import memos（重新映射图片路径）
    final memos = data['memos'] as List? ?? [];
    for (final item in memos) {
      String content = item['content'];
      if (pathMapping.isNotEmpty) {
        content = _remapMemoContent(content, pathMapping);
      }
      await db.into(db.memos).insert(MemosCompanion.insert(
        id: item['id'],
        title: item['title'],
        content: content,
        category: Value(item['category'] ?? '生活'),
        pinned: Value(item['pinned'] ?? false),
        createdAt: DateTime.parse(item['createdAt']),
        updatedAt: DateTime.parse(item['updatedAt']),
      ));
    }

    // Import diaries（重新映射图片路径）
    final diaries = data['diaries'] as List? ?? [];
    debugPrint('[Restore] 导入 ${diaries.length} 条日记');
    for (final item in diaries) {
      String content = item['content'];
      String? images = item['images'];
      if (pathMapping.isNotEmpty) {
        content = _remapMemoContent(content, pathMapping);
        images = _remapDiaryImages(images, pathMapping);
      }
      await db.into(db.diaryEntries).insert(DiaryEntriesCompanion.insert(
        id: item['id'],
        date: DateTime.parse(item['date']),
        title: item['title'],
        content: content,
        mood: Value(item['mood']),
        weather: Value(item['weather']),
        images: Value(images),
        createdAt: DateTime.parse(item['createdAt']),
        updatedAt: DateTime.parse(item['updatedAt']),
      ));
    }

    // Import transactions
    final transactions = data['transactions'] as List? ?? [];
    for (final item in transactions) {
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
        id: item['id'],
        type: item['type'],
        amount: item['amount'],
        category: item['category'],
        note: Value(item['note']),
        date: DateTime.parse(item['date']),
        createdAt: DateTime.parse(item['createdAt']),
      ));
    }

    // Import goals
    final goals = data['goals'] as List? ?? [];
    for (final item in goals) {
      await db.into(db.goals).insert(GoalsCompanion.insert(
        id: item['id'],
        title: item['title'],
        description: Value(item['description']),
        type: item['type'],
        targetValue: Value(item['targetValue'] ?? 1),
        currentValue: Value(item['currentValue'] ?? 0),
        unit: Value(item['unit']),
        startDate: DateTime.parse(item['startDate']),
        endDate: Value(item['endDate'] != null ? DateTime.parse(item['endDate']) : null),
        completed: Value(item['completed'] ?? false),
        createdAt: DateTime.parse(item['createdAt']),
        updatedAt: DateTime.parse(item['updatedAt']),
      ));
    }

    // Import goal progress records
    final progressRecords = data['goalProgressRecords'] as List? ?? [];
    for (final item in progressRecords) {
      await db.into(db.goalProgressRecords).insert(GoalProgressRecordsCompanion.insert(
        id: item['id'],
        goalId: item['goalId'],
        previousValue: item['previousValue'],
        newValue: item['newValue'],
        change: item['change'],
        note: Value(item['note']),
        createdAt: DateTime.parse(item['createdAt']),
      ));
    }

    // Import weights
    final weights = data['weights'] as List? ?? [];
    for (final item in weights) {
      await db.into(db.weightRecords).insert(WeightRecordsCompanion.insert(
        id: item['id'],
        weight: item['weight'],
        date: DateTime.parse(item['date']),
        note: Value(item['note']),
        createdAt: DateTime.parse(item['createdAt']),
      ));
    }

    // Import countdowns
    final countdowns = data['countdowns'] as List? ?? [];
    for (final item in countdowns) {
      await db.into(db.countdowns).insert(CountdownsCompanion.insert(
        id: item['id'],
        title: item['title'],
        targetDate: DateTime.parse(item['targetDate']),
        type: item['type'],
        repeatYearly: Value(item['repeatYearly'] ?? false),
        remind: Value(item['remind'] ?? false),
        remindAdvance: Value(item['remindAdvance'] ?? 1440),
        icon: Value(item['icon']),
        color: Value(item['color']),
        createdAt: DateTime.parse(item['createdAt']),
        updatedAt: DateTime.parse(item['updatedAt']),
      ));
    }
  }

  Future<void> _clearAllData(AppDatabase db) async {
    await db.delete(db.todos).go();
    await db.delete(db.memos).go();
    await db.delete(db.diaryEntries).go();
    await db.delete(db.transactions).go();
    await db.delete(db.goalProgressRecords).go();
    await db.delete(db.goals).go();
    await db.delete(db.weightRecords).go();
    await db.delete(db.countdowns).go();
  }

  /// 从 Delta JSON 内容中提取图片路径（兼容 List 和 Map 格式）
  Set<String> _extractImagePathsFromDelta(String content) {
    final imagePaths = <String>{};
    try {
      final decoded = jsonDecode(content);
      List ops;
      if (decoded is List) {
        ops = decoded;
      } else if (decoded is Map<String, dynamic>) {
        ops = decoded['ops'] as List? ?? [];
      } else {
        return imagePaths;
      }
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is Map && insert['image'] is String) {
          final imagePath = insert['image'] as String;
          if (imagePath.startsWith('/')) {
            imagePaths.add(imagePath);
          }
        }
      }
    } catch (_) {}
    return imagePaths;
  }

  /// 收集所有备忘录和日记中引用的图片路径
  Future<Set<String>> _collectImagePaths(AppDatabase db) async {
    final imagePaths = <String>{};

    // 从备忘录 Delta JSON 中提取图片路径
    final memos = await db.select(db.memos).get();
    for (final memo in memos) {
      imagePaths.addAll(_extractImagePathsFromDelta(memo.content));
    }

    // 从日记中提取图片路径
    final diaries = await db.select(db.diaryEntries).get();
    for (final diary in diaries) {
      // 从日记 Delta JSON content 中提取图片路径
      imagePaths.addAll(_extractImagePathsFromDelta(diary.content));
      // 从旧的 images 列中提取路径（向后兼容）
      if (diary.images != null && diary.images!.isNotEmpty) {
        try {
          final paths = jsonDecode(diary.images!) as List;
          for (final p in paths) {
            if (p is String && p.startsWith('/')) {
              imagePaths.add(p);
            }
          }
        } catch (_) {}
      }
    }

    return imagePaths;
  }

  /// 重新映射 JSON 数据中的图片路径（恢复时使用）
  /// Flutter Quill 的 Delta.toJson() 返回 List 格式，同时也兼容 {"ops": [...]} 格式
  String _remapMemoContent(String content, Map<String, String> pathMapping) {
    try {
      final decoded = jsonDecode(content);
      List ops;
      dynamic root;
      if (decoded is List) {
        // Flutter Quill Delta.toJson() 直接返回 List
        ops = decoded;
        root = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // 兼容 {"ops": [...]} 格式
        ops = decoded['ops'] as List? ?? [];
        root = decoded;
      } else {
        return content;
      }
      bool modified = false;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is Map && insert['image'] is String) {
          final oldPath = insert['image'] as String;
          final fileName = p.basename(oldPath);
          if (pathMapping.containsKey(fileName)) {
            insert['image'] = pathMapping[fileName]!;
            modified = true;
          }
        }
      }
      if (modified) {
        debugPrint('[Remap] 图片路径已重新映射');
        return jsonEncode(root);
      }
    } catch (_) {}
    return content;
  }

  /// 重新映射日记图片路径列表
  String? _remapDiaryImages(String? images, Map<String, String> pathMapping) {
    if (images == null || images.isEmpty) return images;
    try {
      final paths = jsonDecode(images) as List;
      final newPaths = paths.map((p) {
        if (p is String) {
          final fileName = p.split('/').last;
          return pathMapping[fileName] ?? p;
        }
        return p;
      }).toList();
      return jsonEncode(newPaths);
    } catch (_) {
      return images;
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive ? theme.colorScheme.error : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            )
          : null,
      trailing: const Icon(LucideIcons.chevronRight, size: 20),
      onTap: onTap,
    );
  }
}
