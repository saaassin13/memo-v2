# 00-foundation 变更记录

## [1.0.0] - 2026-03-19

### Added
- **F-001**: 创建 Flutter 项目 `memo_app`，建立标准目录结构
- **F-002**: 配置 pubspec.yaml，添加所有必要依赖包
  - 状态管理: flutter_riverpod, riverpod_annotation
  - 路由: go_router
  - 数据库: sqflite, drift, path_provider, path
  - UI: lucide_icons, fl_chart
  - 工具: intl, uuid
  - 开发依赖: build_runner, riverpod_generator, drift_dev
- **F-003**: 实现颜色系统 (`lib/core/theme/colors.dart`)
  - AppColors: Light 主题颜色定义
  - AppColorsDark: Dark 主题颜色定义
  - 包含 primary、background、card、secondary、muted、accent、destructive、border、chart 等颜色
- **F-004**: 实现主题配置 (`lib/core/theme/app_theme.dart`)
  - Material 3 主题支持
  - 完整的 light() 和 dark() 主题配置
  - ColorScheme、CardTheme、AppBarTheme、BottomNavigationBarTheme 等组件主题
- **F-005**: 配置主题切换 Provider (`lib/providers/theme_provider.dart`)
  - ThemeModeNotifier 支持 system/light/dark 切换
  - 提供 setThemeMode() 和 toggle() 方法
- **F-006**: 创建应用入口
  - `lib/main.dart`: 应用启动入口，ProviderScope 配置
  - `lib/app.dart`: MemoApp ConsumerWidget，集成主题和路由
- **F-007**: 创建常量文件 (`lib/core/constants/app_constants.dart`)
  - TodoCategories、MemoCategories: 分类常量
  - Weather、Mood: 枚举类型，带图标和标签
  - CountdownCategories、TransactionTypes、ExpenseCategories、IncomeCategories: 业务常量
  - AppSpacing、AppRadius: 间距和圆角常量

### Impact
- 完成基础框架搭建，为所有后续模块提供主题、路由、状态管理基础
- 所有依赖模块现在可以基于此基础进行开发

---

## 变更模板

### [版本号] - YYYY-MM-DD

#### Added
- 新增功能

#### Changed
- 修改内容

#### Fixed
- 修复问题

#### Removed
- 移除内容

#### Impact
- 影响范围说明
