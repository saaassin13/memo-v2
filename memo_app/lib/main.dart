import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 locale 数据，确保 DateFormat 可以正常工作
  await initializeDateFormatting();

  // 初始化通知服务
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: MemoApp(),
    ),
  );
}
