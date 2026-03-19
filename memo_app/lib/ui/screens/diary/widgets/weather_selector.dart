import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/colors.dart';

/// Weather enum for diary entries
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

  /// Get Weather enum from string value
  static Weather? fromValue(String? value) {
    if (value == null) return null;
    return Weather.values.where((w) => w.value == value).firstOrNull;
  }
}

/// A selector widget for choosing weather conditions.
class WeatherSelector extends StatelessWidget {
  /// Creates a WeatherSelector.
  const WeatherSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// The currently selected weather.
  final Weather selected;

  /// Called when the selection changes.
  final ValueChanged<Weather> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  ? (isDark ? AppColorsDark.primary : AppColors.primary)
                  : (isDark ? AppColorsDark.card : AppColors.card),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColorsDark.primary : AppColors.primary)
                    : (isDark ? AppColorsDark.border : AppColors.border),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  weather.icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColorsDark.mutedForeground
                          : AppColors.mutedForeground),
                ),
                const SizedBox(width: 4),
                Text(
                  weather.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColorsDark.foreground
                            : AppColors.foreground),
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
