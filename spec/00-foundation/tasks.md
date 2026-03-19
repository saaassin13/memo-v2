# 00-foundation 任务明细

## 任务列表

### F-001: 创建 Flutter 项目
- **优先级**: P0
- **预估**: 0.5h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**步骤**:
1. 运行 `flutter create memo_app`
2. 清理默认文件
3. 创建目录结构

**验收标准**:
- 项目可正常运行 `flutter run`

**完成说明**: Flutter 项目已创建，目录结构符合设计规范。

---

### F-002: 配置 pubspec.yaml
- **优先级**: P0
- **预估**: 0.5h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**依赖**:
```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^14.0.0
  sqflite: ^2.3.0
  drift: ^2.15.0
  path_provider: ^2.1.0
  path: ^1.9.0
  lucide_icons: ^0.257.0
  fl_chart: ^0.66.0
  intl: ^0.19.0
  uuid: ^4.3.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  drift_dev: ^2.15.0
```

**验收标准**:
- `flutter pub get` 成功

**完成说明**: 所有依赖包已配置，`flutter pub get` 执行成功。

---

### F-003: 实现颜色系统
- **优先级**: P0
- **预估**: 1h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/core/theme/colors.dart`

**验收标准**:
- Light/Dark 颜色定义完整
- 颜色与 Web 版视觉一致

**完成说明**: 已实现 AppColors 和 AppColorsDark 两个类，包含完整的颜色定义（primary、background、card、secondary、muted、accent、destructive、border、chart 等）。

---

### F-004: 实现主题配置
- **优先级**: P0
- **预估**: 2h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/core/theme/app_theme.dart`

**内容**:
- ThemeData light/dark
- ColorScheme 配置
- CardTheme, AppBarTheme, BottomNavigationBarTheme 等

**验收标准**:
- 主题可正常切换
- 组件样式与 Web 版一致

**完成说明**: 已实现完整的 light() 和 dark() 主题配置，包含 ColorScheme、CardTheme、AppBarTheme、BottomNavigationBarTheme、FloatingActionButtonTheme、InputDecorationTheme、ElevatedButtonTheme、TextButtonTheme、DividerTheme、ChipTheme 等。

---

### F-005: 配置主题切换 Provider
- **优先级**: P1
- **预估**: 0.5h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/providers/theme_provider.dart`

**内容**:
```dart
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}
```

**验收标准**:
- 可在 system/light/dark 间切换

**完成说明**: 使用 StateNotifier 实现 ThemeModeNotifier，支持 setThemeMode() 和 toggle() 方法。

---

### F-006: 创建应用入口
- **优先级**: P0
- **预估**: 0.5h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**:
- `lib/main.dart`
- `lib/app.dart`

**验收标准**:
- 应用可启动
- ProviderScope 配置正确

**完成说明**: main.dart 配置了 WidgetsFlutterBinding 和 ProviderScope；app.dart 实现了 MemoApp ConsumerWidget，集成了主题系统和路由配置。

---

### F-007: 创建常量文件
- **优先级**: P2
- **预估**: 0.5h
- **状态**: 已完成
- **完成日期**: 2026-03-19

**文件**: `lib/core/constants/app_constants.dart`

**内容**:
- 分类常量 (Todo, Memo, Diary 等)
- 图标映射
- 默认值

**完成说明**: 已实现完整的常量文件，包含 TodoCategories、MemoCategories、Weather、Mood、CountdownCategories、TransactionTypes、ExpenseCategories、IncomeCategories、AppSpacing、AppRadius 等。

---

## 进度统计

| 状态 | 数量 |
|------|------|
| 待开发 | 0 |
| 开发中 | 0 |
| 已完成 | 7 |
| **总计** | **7** |
