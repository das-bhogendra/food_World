import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColors on BuildContext {
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textTertiary => AppColors.textTertiary;

  Color get surfaceColor => AppColors.surface;
  List<BoxShadow> get softShadow => AppColors.softShadow;
  Color get dividerColor => AppColors.textTertiary.withOpacity(0.3);
}
