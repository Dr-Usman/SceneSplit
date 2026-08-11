import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Horizontal dashed rule — theme border color by default.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color,
    this.dashWidth = 4,
    this.dashSpace = 3,
    this.strokeWidth = 1,
  });

  final Color? color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.borderDark
            : AppColors.border);
    return CustomPaint(
      painter: _DashedLinePainter(
        color: resolved,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        strokeWidth: strokeWidth,
      ),
      child: SizedBox(width: double.infinity, height: strokeWidth),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.strokeWidth != strokeWidth;
}
