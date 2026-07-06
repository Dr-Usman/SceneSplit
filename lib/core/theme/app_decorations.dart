import 'package:flutter/material.dart';

import 'app_theme.dart';

abstract class AppRadius {
  static const lg = 20.0;
  static const xl = 24.0;
  static const md = 16.0;
  static const sm = 14.0;
}

abstract class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> logo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.2),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
    ];
  }
}

abstract class AppGradients {
  static const summaryOwed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const summaryOwe = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );

  static LinearGradient emojiTile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.secondary.withValues(alpha: 0.08),
            ]
          : [
              AppColors.primarySoft.withValues(alpha: 0.5),
              AppColors.secondarySoft.withValues(alpha: 0.35),
            ],
    );
  }

  static LinearGradient avatarRing(BuildContext context) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.secondary],
    );
  }

  static LinearGradient balancePositive(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              AppColors.positive.withValues(alpha: 0.2),
              AppColors.primary.withValues(alpha: 0.12),
            ]
          : [
              AppColors.positive.withValues(alpha: 0.08),
              AppColors.primarySoft.withValues(alpha: 0.4),
            ],
    );
  }

  static LinearGradient balanceNegative(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              AppColors.negative.withValues(alpha: 0.2),
              AppColors.secondary.withValues(alpha: 0.12),
            ]
          : [
              AppColors.negative.withValues(alpha: 0.06),
              AppColors.secondarySoft.withValues(alpha: 0.45),
            ],
    );
  }
}
