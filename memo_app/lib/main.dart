import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 locale 数据，确保 DateFormat 可以正常工作
  await initializeDateFormatting();

  runApp(
    const ProviderScope(
      child: MemoApp(),
    ),
  );
}
