import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lunar/lunar.dart';

import '../../../../core/theme/colors.dart';

/// A widget for picking either solar or lunar date.
class LunarDatePicker extends StatefulWidget {
  /// Creates a LunarDatePicker.
  const LunarDatePicker({
    super.key,
    required this.initialDate,
    this.isLunar = false,
    required this.onDateChanged,
    required this.onLunarToggled,
  });

  /// The initial date.
  final DateTime initialDate;

  /// Whether currently using lunar calendar.
  final bool isLunar;

  /// Called when date changes.
  final ValueChanged<DateTime> onDateChanged;

  /// Called when lunar toggle changes.
  final ValueChanged<bool> onLunarToggled;

  @override
  State<LunarDatePicker> createState() => _LunarDatePickerState();
}

class _LunarDatePickerState extends State<LunarDatePicker> {
  late DateTime _selectedDate;
  late bool _isLunar;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _isLunar = widget.isLunar;
  }

  Future<void> _selectDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    if (_isLunar) {
      // Show lunar date picker dialog
      await _showLunarPicker(isDark);
    } else {
      // Show standard date picker
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(now.year + 100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme(
                brightness: isDark ? Brightness.dark : Brightness.light,
                primary: isDark ? AppColorsDark.primary : AppColors.primary,
                onPrimary: isDark
                    ? AppColorsDark.primaryForeground
                    : AppColors.primaryForeground,
                secondary: isDark ? AppColorsDark.accent : AppColors.accent,
                onSecondary: isDark
                    ? AppColorsDark.accentForeground
                    : AppColors.accentForeground,
                error: isDark ? AppColorsDark.destructive : AppColors.destructive,
                onError: isDark
                    ? AppColorsDark.destructiveForeground
                    : AppColors.destructiveForeground,
                surface: isDark ? AppColorsDark.card : AppColors.card,
                onSurface: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
              dialogBackgroundColor: isDark ? AppColorsDark.card : AppColors.card,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
        widget.onDateChanged(picked);
      }
    }
  }

  Future<void> _showLunarPicker(bool isDark) async {
    // Convert current date to lunar for initial values
    final solar = Solar.fromDate(_selectedDate);
    final lunar = solar.getLunar();

    int selectedYear = lunar.getYear();
    int selectedMonth = lunar.getMonth();
    int selectedDay = lunar.getDay();
    bool isLeapMonth = lunar.getMonth() < 0;
    if (isLeapMonth) {
      selectedMonth = -selectedMonth;
    }

    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Get available months for selected year
            final lunarYear = LunarYear.fromYear(selectedYear);
            final months = <int>[];
            for (int m = 1; m <= 12; m++) {
              months.add(m);
            }
            // Check for leap month
            final leapMonth = lunarYear.getLeapMonth();

            // Get days in selected month
            final lunarMonthObj = LunarMonth.fromYm(selectedYear, isLeapMonth ? -selectedMonth : selectedMonth);
            final daysInMonth = lunarMonthObj?.getDayCount() ?? 30;

            return AlertDialog(
              backgroundColor: isDark ? AppColorsDark.card : AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '选择农历日期',
                style: TextStyle(
                  color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year picker
                    Row(
                      children: [
                        Text(
                          '年份',
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, size: 18),
                          onPressed: () {
                            setDialogState(() {
                              selectedYear--;
                            });
                          },
                        ),
                        Text(
                          '${selectedYear}年',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColorsDark.foreground
                                : AppColors.foreground,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight, size: 18),
                          onPressed: () {
                            setDialogState(() {
                              selectedYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Month picker
                    Row(
                      children: [
                        Text(
                          '月份',
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: isLeapMonth
                              ? '闰${_getLunarMonthName(selectedMonth)}'
                              : _getLunarMonthName(selectedMonth),
                          items: [
                            ...months.map((m) {
                              return DropdownMenuItem(
                                value: _getLunarMonthName(m),
                                child: Text(_getLunarMonthName(m)),
                              );
                            }),
                            if (leapMonth > 0)
                              DropdownMenuItem(
                                value: '闰${_getLunarMonthName(leapMonth)}',
                                child: Text('闰${_getLunarMonthName(leapMonth)}'),
                              ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              if (value != null) {
                                if (value.startsWith('闰')) {
                                  isLeapMonth = true;
                                  selectedMonth = _getLunarMonthNumber(value.substring(1));
                                } else {
                                  isLeapMonth = false;
                                  selectedMonth = _getLunarMonthNumber(value);
                                }
                                // Adjust day if out of range
                                final newLunarMonth = LunarMonth.fromYm(
                                    selectedYear, isLeapMonth ? -selectedMonth : selectedMonth);
                                final newDaysInMonth = newLunarMonth?.getDayCount() ?? 30;
                                if (selectedDay > newDaysInMonth) {
                                  selectedDay = newDaysInMonth;
                                }
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Day picker
                    Row(
                      children: [
                        Text(
                          '日期',
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.mutedForeground
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<int>(
                          value: selectedDay,
                          items: List.generate(daysInMonth, (i) => i + 1)
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(_getLunarDayName(d)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedDay = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColorsDark.primary : AppColors.primary)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '农历 ${selectedYear}年${isLeapMonth ? "闰" : ""}${_getLunarMonthName(selectedMonth)}${_getLunarDayName(selectedDay)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColorsDark.primary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Convert lunar to solar
                    final lunarDate = Lunar.fromYmd(
                      selectedYear,
                      isLeapMonth ? -selectedMonth : selectedMonth,
                      selectedDay,
                    );
                    final solarDate = lunarDate.getSolar();
                    Navigator.pop(
                      context,
                      DateTime(
                        solarDate.getYear(),
                        solarDate.getMonth(),
                        solarDate.getDay(),
                      ),
                    );
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(
                      color: isDark ? AppColorsDark.primary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
      widget.onDateChanged(result);
    }
  }

  String _getLunarMonthName(int month) {
    const months = [
      '正月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '冬月',
      '腊月'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '${month}月';
  }

  int _getLunarMonthNumber(String name) {
    const months = [
      '正月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '冬月',
      '腊月'
    ];
    final idx = months.indexOf(name);
    return idx >= 0 ? idx + 1 : 1;
  }

  String _getLunarDayName(int day) {
    const days = [
      '初一',
      '初二',
      '初三',
      '初四',
      '初五',
      '初六',
      '初七',
      '初八',
      '初九',
      '初十',
      '十一',
      '十二',
      '十三',
      '十四',
      '十五',
      '十六',
      '十七',
      '十八',
      '十九',
      '二十',
      '廿一',
      '廿二',
      '廿三',
      '廿四',
      '廿五',
      '廿六',
      '廿七',
      '廿八',
      '廿九',
      '三十'
    ];
    if (day >= 1 && day <= 30) {
      return days[day - 1];
    }
    return '$day';
  }

  String _formatDate(DateTime date) {
    if (_isLunar) {
      final solar = Solar.fromDate(date);
      final lunar = solar.getLunar();
      final month = lunar.getMonth();
      final isLeap = month < 0;
      final actualMonth = isLeap ? -month : month;
      return '农历 ${lunar.getYear()}年${isLeap ? "闰" : ""}${_getLunarMonthName(actualMonth)}${_getLunarDayName(lunar.getDay())}';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar type toggle
        Row(
          children: [
            Text(
              '日历类型',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColorsDark.foreground : AppColors.foreground,
              ),
            ),
            const Spacer(),
            _buildToggleChip(
              label: '公历',
              selected: !_isLunar,
              onTap: () {
                setState(() {
                  _isLunar = false;
                });
                widget.onLunarToggled(false);
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildToggleChip(
              label: '农历',
              selected: _isLunar,
              onTap: () {
                setState(() {
                  _isLunar = true;
                });
                widget.onLunarToggled(true);
              },
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Date picker button
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.input : AppColors.input,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 20,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? AppColorsDark.foreground : AppColors.foreground,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDark
                      ? AppColorsDark.mutedForeground
                      : AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColorsDark.primary : AppColors.primary)
              : (isDark ? AppColorsDark.muted : AppColors.muted),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? (isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground)
                : (isDark ? AppColorsDark.foreground : AppColors.foreground),
          ),
        ),
      ),
    );
  }
}
