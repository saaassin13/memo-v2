# Goals Changelog

## 2026-03-20 (Hotfix)

### Bug Fixes

- **[30] 已完成目标的设置菜单**
  - 问题：已完成目标应只显示"克隆目标"和"删除目标"选项
  - 修复：修改 `_showSettingsMenu()` 根据 `goal.completed` 条件显示不同菜单项
    - 未完成目标：显示"编辑目标"、"完成目标"、"删除目标"
    - 已完成目标：显示"克隆目标"、"删除目标"
  - 修改文件：`lib/ui/screens/goals/goal_detail_screen.dart`

## 2026-03-20

### New Features

- **目标进度历史记录** - 新增进度历史记录功能
  - 新建 `goal_progress_records` 数据表存储进度变更历史
  - 每次更新进度自动记录：更新时间、进度变化、备注
  - 目标详情页展示完整进度历史列表

- **进度更新弹窗** - 新增专用进度更新弹窗组件
  - 支持增加/减少切换
  - 快捷数值按钮（1, 5, 10, 20, 50）
  - 自定义数值输入
  - 备注输入（可选）
  - 实时预览更新后的进度值
  - 新建文件：`lib/ui/screens/goals/widgets/progress_update_sheet.dart`

### UI Redesign

- **[23] 目标详情页重新设计**
  - 去掉详情内的进度更新 UI（+/-按钮等）
  - 右上角编辑按钮改为设置按钮，点击弹出菜单：
    - 编辑目标
    - 完成目标/标记为进行中
    - 克隆目标重新开始（仅已完成目标）
    - 删除目标
  - 页面主体展示历史进度列表：时间、进度变化、备注描述
  - 修改文件：`lib/ui/screens/goals/goal_detail_screen.dart`

- **[24] 目标列表页卡片重新设计**
  - 去掉快捷设置进度按钮（+1/-/+5/完成）
  - 新增"更新"按钮，点击弹出进度更新弹窗
  - 修改文件：`lib/ui/screens/goals/widgets/goal_card.dart`
  - 修改文件：`lib/ui/screens/goals/goals_list_screen.dart`

### Database Changes

- 新建表 `goal_progress_records`：
  ```dart
  class GoalProgressRecords extends Table {
    TextColumn get id => text()();
    TextColumn get goalId => text()();
    IntColumn get previousValue => integer()();
    IntColumn get newValue => integer()();
    IntColumn get change => integer()();
    TextColumn get note => text().nullable()();
    DateTimeColumn get createdAt => dateTime()();
  }
  ```
- 数据库版本升级到 2，添加迁移脚本

### New Files

- `lib/data/database/tables/goal_progress_records.dart` - 进度记录表定义
- `lib/data/repositories/goal_progress_repository.dart` - 进度记录仓库
- `lib/providers/goal_progress_provider.dart` - 进度记录 Provider
- `lib/ui/screens/goals/widgets/progress_update_sheet.dart` - 进度更新弹窗

### Modified Files

- `lib/data/database/app_database.dart` - 添加表，版本升级
- `lib/data/repositories/goal_repository.dart` - `updateProgress` 返回更新前的值
- `lib/providers/goal_provider.dart` - 集成进度记录，更新/删除时联动
- `lib/ui/screens/goals/goal_detail_screen.dart` - 完全重写
- `lib/ui/screens/goals/widgets/goal_card.dart` - 重新设计布局
- `lib/ui/screens/goals/goals_list_screen.dart` - 集成进度更新弹窗
