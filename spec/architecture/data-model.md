# 数据模型

## Todo (待办事项)

```dart
class Todo {
  final String id;
  final String title;
  final String category;    // 工作, 生活, 学习, 杂项
  final DateTime? dueDate;
  final String? note;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**分类选项**: 工作, 生活, 学习, 杂项

## Memo (备忘录)

```dart
class Memo {
  final String id;
  final String title;
  final String content;
  final String category;    // 工作, 生活, 学习
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**分类选项**: 工作, 生活, 学习

## DiaryEntry (日记)

```dart
class DiaryEntry {
  final String id;
  final DateTime date;
  final String weather;     // sunny, cloudy, rainy, snowy, thunder, windy
  final String content;
  final String mood;        // happy, joy, love, calm, sad, angry
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**天气选项**:
- sunny (晴天)
- cloudy (多云)
- rainy (雨天)
- snowy (雪天)
- thunder (雷雨)
- windy (大风)

**心情选项**:
- happy (开心)
- joy (喜悦)
- love (爱)
- calm (平静)
- sad (难过)
- angry (愤怒)

## Transaction (交易记录)

```dart
class Transaction {
  final String id;
  final double amount;
  final String type;        // income, expense
  final String category;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
}
```

**类型**:
- income (收入)
- expense (支出)

**分类选项 (支出)**:
- 餐饮, 交通, 购物, 娱乐, 住房, 医疗, 教育, 其他

**分类选项 (收入)**:
- 工资, 奖金, 投资, 礼金, 其他

## Goal (目标)

```dart
class Goal {
  final String id;
  final String name;
  final int target;
  final int current;
  final String unit;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## WeightRecord (体重记录)

```dart
class WeightRecord {
  final String id;
  final double weight;      // kg
  final DateTime date;
  final bool exercised;
  final String? note;
  final DateTime createdAt;
}
```

## Countdown (倒数纪念日)

```dart
class Countdown {
  final String id;
  final String name;
  final DateTime date;
  final String category;    // birthday, holiday, important
  final bool repeat;        // 是否每年重复
  final DateTime createdAt;
}
```

**分类选项**:
- birthday (生日)
- holiday (节日)
- important (重要日)

## CalendarEvent (日历事件)

复合类型，聚合多种事件:

```dart
class CalendarEvent {
  final String id;
  final String type;        // todo, diary, countdown
  final String title;
  final String? description;
  final DateTime date;
  final String? time;
  final String? color;
}
```

## 数据库表结构 (Drift)

```dart
// todos 表
class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text().withDefault(const Constant('杂项'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// memos 表
class Memos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get category => text().withDefault(const Constant('生活'))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// diary_entries 表
class DiaryEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get weather => text()();
  TextColumn get content => text()();
  TextColumn get mood => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// transactions 表
class Transactions extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// goals 表
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get target => integer()();
  IntColumn get current => integer().withDefault(const Constant(0))();
  TextColumn get unit => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// weight_records 表
class WeightRecords extends Table {
  TextColumn get id => text()();
  RealColumn get weight => real()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get exercised => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// countdowns 表
class Countdowns extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  BoolColumn get repeat => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```
