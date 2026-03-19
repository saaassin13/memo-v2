# 13-profile 变更记录

## [1.0.0] - 2026-03-19

### 新增
- ProfileScreen 页面
  - 用户头像和昵称展示 (UserHeader 组件)
  - 统计数据卡片 (StatsCard 组件)，显示待办、日记、备忘录数量
  - 版本信息展示
  - 意见反馈功能
- SettingsScreen 页面
  - 主题切换 (ThemeSelector 组件)，支持跟随系统/浅色/深色
  - 通知设置（待办提醒、倒数日提醒）
  - 数据管理 (DataManagement 组件)
    - 数据备份：导出为 JSON 文件
    - 数据恢复：从备份文件导入
    - 清除数据：删除所有本地数据
  - 语言设置
  - 重置设置

### 依赖
- share_plus: 用于分享备份文件
- file_picker: 用于选择恢复文件
- package_info_plus: 用于获取应用版本信息
