# 22-countdown 变更记录

## [1.0.0] - 2026-03-19

### 新增
- CountdownScreen 主页面
  - 倒数日列表展示
  - 分类筛选（全部/生日/节日/重要日）
  - 分组显示（即将到来/已经过去）
  - FAB 添加按钮
- CountdownCard 卡片组件
  - 分类图标和颜色标识
  - 天数计算显示
  - 滑动删除功能
  - 今日高亮显示
- CountdownEditSheet 编辑弹窗
  - 名称输入
  - 日期选择（支持历史日期）
  - 分类选择
  - 每年重复开关
- CountdownHelper 计算工具类
  - 天数计算逻辑
  - 年重复处理
  - 闰年处理
- CommonEmptyStates.noCountdowns 空状态

### 依赖
- 使用 countdownProvider 进行数据管理
- 复用 CategoryFilter 组件
- 复用 AppInput, AppButton 等 UI 组件
