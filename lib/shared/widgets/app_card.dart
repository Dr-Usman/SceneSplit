import 'package:flutter/material.dart';

import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.border;

    final decoration = BoxDecoration(
      color: gradient == null ? surface : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: borderColor),
      boxShadow: AppShadows.card(context),
    );

    final content = Padding(padding: padding, child: child);

    // Always provide a Material under the DecoratedBox so ListTile /
    // ExpansionTile ink and tile backgrounds paint above the card fill.
    return Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
