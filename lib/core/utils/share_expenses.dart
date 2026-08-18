import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/widgets/expense_share_card.dart';
import '../l10n/l10n_extensions.dart';
import 'share_balance_image.dart';

/// Captures [card] as a PNG and opens the system share sheet.
Future<bool> shareExpenseImage(
  BuildContext context, {
  required ExpenseShareCard card,
  required String groupName,
  required String caption,
}) async {
  final l10n = context.l10n;
  final origin = sharePositionOrigin(context);

  final bytes = await captureShareWidget(context, child: card);
  if (bytes == null || !context.mounted) return false;

  try {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            name: 'scenesplit-expenses.png',
            mimeType: 'image/png',
          ),
        ],
        subject: l10n.groupsShareExpensesSubject(groupName),
        text: caption,
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on Object {
    return false;
  }
}

/// Opens the system share sheet with a plain-text expense list.
Future<bool> shareExpenseText(
  BuildContext context, {
  required String body,
  required String groupName,
}) async {
  final l10n = context.l10n;
  final origin = sharePositionOrigin(context);

  try {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: body,
        subject: l10n.groupsShareExpensesSubject(groupName),
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on Object {
    return false;
  }
}
