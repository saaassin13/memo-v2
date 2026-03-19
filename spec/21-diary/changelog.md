# 21-diary 变更记录

## [1.0.0] - 2026-03-19

### 新增
- DiaryListScreen: 日记列表主页面，集成日历视图
- DiaryCalendar: 日历组件，支持月份导航和日期选择，显示日记指示点
- DiaryEditScreen: 日记编辑页面，支持新建和编辑模式
- DiaryDetailScreen: 日记详情页面，显示完整日记内容
- WeatherSelector: 天气选择组件，6种天气选项
- MoodSelector: 心情选择组件，6种心情选项
- DiaryCard: 日记卡片组件，用于列表展示

### 技术细节
- 使用 Riverpod 进行状态管理
- 集成 diaryProvider、diaryByDateProvider、diaryDatesProvider
- 支持深色/浅色主题
- 路由配置支持 initialDate 参数用于指定日期新建日记

## [未发布]

### 计划中
- 图片附件支持
- 日记导出功能
- 搜索功能
