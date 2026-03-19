# 01-ui-components 设计文档

## 设计原则

1. **一致性**: 与原 Web 版视觉风格保持一致
2. **可复用**: 组件设计通用，支持多场景使用
3. **可定制**: 通过参数支持样式变体
4. **响应式**: 适配不同屏幕尺寸

## 组件设计

### AppButton

```dart
enum ButtonVariant { primary, secondary, ghost, destructive }
enum ButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool fullWidth;
}
```

**使用示例**:
```dart
AppButton(
  label: '保存',
  icon: LucideIcons.save,
  variant: ButtonVariant.primary,
  onPressed: () {},
)
```

### AppCard

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool elevated;
}
```

### AppBadge

```dart
enum BadgeVariant { default_, secondary, outline }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final Color? color;
  final Color? backgroundColor;
}
```

### AppInput

```dart
class AppInput extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
}
```

### AppDialog

```dart
class AppDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget content;
  final List<Widget>? actions;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required Widget content,
    List<Widget>? actions,
  });
}
```

### AppDrawer (Bottom Sheet)

```dart
class AppDrawer extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget child;
  final double? maxHeight;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? description,
  });
}
```

### TodoItem

```dart
class TodoItem extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final DateTime? dueDate;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
}
```

**样式**:
- 左侧: 圆形复选框
- 中间: 标题 + 分类标签 + 截止日期
- 右侧: 更多操作按钮

### EventCard

```dart
class EventCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? time;
  final String type; // todo, diary, countdown
  final Color? accentColor;
  final VoidCallback? onTap;
}
```

### MemoCard

```dart
class MemoCard extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime updatedAt;
  final bool pinned;
  final bool gridMode; // list vs grid 布局
  final VoidCallback? onTap;
  final VoidCallback? onTogglePin;
  final VoidCallback? onDelete;
}
```

### CategoryChip

```dart
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
}
```

**颜色映射**:
```dart
const categoryColors = {
  '工作': AppColors.chart1,
  '生活': AppColors.accent,
  '学习': AppColors.chart3,
  '杂项': AppColors.muted,
};
```

### EmptyState

```dart
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;
}
```

## 样式变量

### 圆角
```dart
const kRadiusSm = 8.0;
const kRadiusMd = 10.0;
const kRadiusLg = 12.0;
const kRadiusXl = 16.0;
const kRadiusFull = 9999.0;
```

### 间距
```dart
const kSpacing1 = 4.0;
const kSpacing2 = 8.0;
const kSpacing3 = 12.0;
const kSpacing4 = 16.0;
const kSpacing5 = 20.0;
const kSpacing6 = 24.0;
```

### 阴影
```dart
const kShadowSm = BoxShadow(
  color: Colors.black12,
  blurRadius: 4,
  offset: Offset(0, 1),
);

const kShadowMd = BoxShadow(
  color: Colors.black12,
  blurRadius: 8,
  offset: Offset(0, 2),
);
```
