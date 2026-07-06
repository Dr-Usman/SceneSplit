import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );

    if (trailing == null) {
      return Text(title, style: style);
    }

    return Row(
      children: [
        Expanded(child: Text(title, style: style)),
        trailing!,
      ],
    );
  }
}
