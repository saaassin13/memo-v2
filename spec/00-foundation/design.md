# 00-foundation 设计文档

## 设计目标

1. 创建标准 Flutter 项目结构
2. 配置 Material 3 主题系统
3. 实现深色/浅色主题切换
4. 配置所有依赖包

## 主题系统

### 颜色方案

基于原 Web 项目的 CSS 变量转换:

```dart
// Light Theme Colors
class AppColors {
  // Primary
  static const primary = Color(0xFF4B7BEC);        // oklch(0.55 0.15 250)
  static const primaryForeground = Colors.white;

  // Background
  static const background = Color(0xFFF8F9FA);     // oklch(0.98 0.005 240)
  static const foreground = Color(0xFF1A1D21);     // oklch(0.15 0.01 240)

  // Card
  static const card = Colors.white;
  static const cardForeground = Color(0xFF1A1D21);

  // Secondary
  static const secondary = Color(0xFFF1F3F4);      // oklch(0.96 0.01 240)
  static const secondaryForeground = Color(0xFF3D4044);

  // Muted
  static const muted = Color(0xFFEBEDF0);          // oklch(0.94 0.01 240)
  static const mutedForeground = Color(0xFF6B7280);

  // Accent
  static const accent = Color(0xFF26D67D);         // oklch(0.65 0.18 160)
  static const accentForeground = Colors.white;

  // Destructive
  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Colors.white;

  // Border
  static const border = Color(0xFFE5E7EB);
  static const input = Color(0xFFE8EAED);

  // Chart colors
  static const chart1 = Color(0xFF4B7BEC);
  static const chart2 = Color(0xFF26D67D);
  static const chart3 = Color(0xFFF59E0B);
  static const chart4 = Color(0xFFEC4899);
  static const chart5 = Color(0xFF3B82F6);
}
```

### Dark Theme Colors

```dart
class AppColorsDark {
  static const primary = Color(0xFF6B9BFF);
  static const primaryForeground = Colors.white;
  static const background = Color(0xFF1A1D21);
  static const foreground = Color(0xFFF5F5F5);
  static const card = Color(0xFF2D3035);
  static const cardForeground = Color(0xFFF5F5F5);
  static const secondary = Color(0xFF3D4044);
  static const secondaryForeground = Color(0xFFE5E7EB);
  static const muted = Color(0xFF363A3F);
  static const mutedForeground = Color(0xFF9CA3AF);
  static const accent = Color(0xFF1DB068);
  static const accentForeground = Colors.white;
  static const destructive = Color(0xFFDC2626);
  static const destructiveForeground = Colors.white;
  static const border = Color(0xFF404449);
  static const input = Color(0xFF3D4044);
}
```

### 主题配置

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.card,
        background: AppColors.background,
        error: AppColors.destructive,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // ... 其他配置
    );
  }

  static ThemeData dark() {
    // 类似配置，使用 AppColorsDark
  }
}
```

## 目录结构

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   ├── router/
│   │   └── app_router.dart
│   └── constants/
│       └── app_constants.dart
├── data/
├── providers/
├── ui/
└── utils/
```

## 入口文件

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: const MemoApp(),
    ),
  );
}

// lib/app.dart
class MemoApp extends ConsumerWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Memo',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```
