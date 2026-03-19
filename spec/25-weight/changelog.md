# 25-weight 变更记录

## [1.0.0] - 2026-03-19

### 新增
- WeightScreen 页面框架
  - 图表/列表视图切换
  - 与 Riverpod Provider 集成
  - 空状态引导
- WeightSummary 组件
  - 当前体重大字显示
  - 与上次体重对比（增减指示器）
  - 最低/平均/最高统计
- WeightChart 组件
  - fl_chart 折线图展示
  - 周/月/年时间范围切换
  - 触摸交互显示详情
  - 渐变填充效果
- WeightRecordList 组件
  - 按日期分组显示
  - 运动标记图标
  - 滑动删除（带确认对话框）
  - 体重变化指示
- AddWeightSheet 组件
  - 体重数字输入（支持一位小数）
  - 日期选择器
  - 运动开关
  - 备注输入

### 技术说明
- 使用 weightsStreamProvider 实现实时数据更新
- 使用 weightStatsProvider 获取统计数据
- 使用 weightListProvider 进行数据操作（增删）
