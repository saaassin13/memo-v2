# 技术栈说明

## 核心框架

### Flutter 3.x
- 跨平台移动应用框架
- Material 3 设计系统
- 热重载开发

### Dart
- Flutter 官方语言
- 强类型、空安全
- 异步编程支持 (async/await)

## 依赖包

### 状态管理
```yaml
flutter_riverpod: ^2.5.0
riverpod_annotation: ^2.3.0
```
- 声明式状态管理
- Provider 自动生成
- 编译时安全

### 路由
```yaml
go_router: ^14.0.0
```
- 声明式路由
- 深度链接支持
- 类型安全路由

### 数据库
```yaml
sqflite: ^2.3.0
drift: ^2.15.0
```
- SQLite 本地数据库
- 类型安全 ORM
- 响应式查询

### UI 组件
```yaml
lucide_icons: ^0.257.0
```
- 与原 Web 版图标一致

### 图表
```yaml
fl_chart: ^0.66.0
```
- 折线图、柱状图
- 用于体重、记账统计

### 日期处理
```yaml
intl: ^0.19.0
```
- 日期格式化
- 国际化支持

### 代码生成
```yaml
build_runner: ^2.4.0
riverpod_generator: ^2.3.0
drift_dev: ^2.15.0
```

## pubspec.yaml 模板

```yaml
name: memo_app
description: Memo Flutter App
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # 路由
  go_router: ^14.0.0

  # 数据库
  sqflite: ^2.3.0
  drift: ^2.15.0
  path_provider: ^2.1.0
  path: ^1.9.0

  # UI
  lucide_icons: ^0.257.0
  fl_chart: ^0.66.0

  # 工具
  intl: ^0.19.0
  uuid: ^4.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  drift_dev: ^2.15.0

flutter:
  uses-material-design: true
```

## 开发工具

### VSCode 插件
- Flutter
- Dart
- Riverpod Snippets

### 命令行工具
```bash
# 代码生成
flutter pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run

# 构建发布版
flutter build apk
flutter build ios
```
