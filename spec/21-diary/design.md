# 21-diary 设计文档

## DiaryListScreen 布局

```
┌─────────────────────────────────────┐
│  [<] 日记                [管理日记] │
├─────────────────────────────────────┤
│    [<]     2026年3月      [>]       │
├─────────────────────────────────────┤
│  日   一   二   三   四   五   六   │
│                           1    2    │
│   3    4    5    6    7   8    9    │
│  10   11   12   13   14  15●  16   │
│  17●  18●  19   20   21  22   23    │
│  24   25   26   27   28  29   30    │
├─────────────────────────────────────┤
│                                     │
│  [选中日期有日记时显示日记卡片]      │
│  ┌─────────────────────────────────┐│
│  │ ☀️ 开心          2026-03-18    ││
│  │ 今天是美好的一天...              ││
│  └─────────────────────────────────┘│
│                                     │
│  [选中日期无日记时显示新建按钮]      │
│  ┌─────────────────────────────────┐│
│  │     📖                          ││
│  │   这一天还没有日记              ││
│  │    [+ 写日记]                   ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

**点击日期行为**: 点击日历上的日期，下方切换展示该日期的日记卡片。若该日期没有日记，则显示「新建日记」按钮，点击按钮进入新建日记页面，日期为选中的日期。

## DiaryManagementScreen 布局（日记管理页面）

```
┌─────────────────────────────────────┐
│  [<] 日记管理           [共 N 篇]  │
├─────────────────────────────────────┤
│         [<] 3月16日-3月22日 [>]     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │  周视图        月视图           ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │ ☀️ 开心          3月20日       ││
│  │ 今天天气很好...                  ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ ☁️ 平静          3月18日       ││
│  │ 有点累...                       ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

**功能说明**:
- 显示日记总数标签（右上角）
- 支持周视图和月视图切换（TabBar）
- 周视图：按周导航，展示该周内所有日记
- 月视图：按月导航，展示该月内所有日记
- 点击日记卡片进入日记详情页面

## 天气和心情选项

```dart
enum Weather {
  sunny('sunny', '晴天', LucideIcons.sun),
  cloudy('cloudy', '多云', LucideIcons.cloud),
  rainy('rainy', '雨天', LucideIcons.cloudRain),
  snowy('snowy', '雪天', LucideIcons.cloudSnow),
  thunder('thunder', '雷雨', LucideIcons.cloudLightning),
  windy('windy', '大风', LucideIcons.wind);

  final String value;
  final String label;
  final IconData icon;

  const Weather(this.value, this.label, this.icon);
}

enum Mood {
  happy('happy', '开心', '😊'),
  joy('joy', '喜悦', '😄'),
  love('love', '爱', '❤️'),
  calm('calm', '平静', '😌'),
  sad('sad', '难过', '😢'),
  angry('angry', '愤怒', '😠');

  final String value;
  final String label;
  final String emoji;

  const Mood(this.value, this.label, this.emoji);
}
```

## DiaryEditScreen

```dart
class DiaryEditScreen extends ConsumerStatefulWidget {
  final String? id;
  final DateTime? initialDate;

  const DiaryEditScreen({super.key, this.id, this.initialDate});

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  late DateTime _date;
  Weather _weather = Weather.sunny;
  Mood _mood = Mood.happy;
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    if (widget.id != null) {
      _loadDiary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.id != null ? '编辑日记' : '写日记'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date display
          _buildDateDisplay(context),
          const SizedBox(height: 24),

          // Weather selector
          Text('天气', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          WeatherSelector(
            selected: _weather,
            onChanged: (w) => setState(() => _weather = w),
          ),
          const SizedBox(height: 24),

          // Mood selector
          Text('心情', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          MoodSelector(
            selected: _mood,
            onChanged: (m) => setState(() => _mood = m),
          ),
          const SizedBox(height: 24),

          // Content
          Text('内容', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          AppTextArea(
            controller: _contentController,
            placeholder: '今天发生了什么...',
            minLines: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.calendar,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(_date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
```

## WeatherSelector

```dart
class WeatherSelector extends StatelessWidget {
  final Weather selected;
  final ValueChanged<Weather> onChanged;

  const WeatherSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Weather.values.map((weather) {
        final isSelected = weather == selected;
        return GestureDetector(
          onTap: () => onChanged(weather),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  weather.icon,
                  size: 16,
                  color: isSelected ? Colors.white : null,
                ),
                const SizedBox(width: 4),
                Text(
                  weather.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
```
