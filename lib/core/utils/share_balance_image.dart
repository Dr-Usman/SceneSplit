import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/widgets/balance_share_card.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// Renders [card] off-screen, captures a PNG, and opens the system share sheet.
Future<bool> shareBalanceImage(
  BuildContext context, {
  required BalanceShareCard card,
  required String groupName,
}) async {
  final l10n = context.l10n;
  final box = context.findRenderObject() as RenderBox?;
  final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

  final bytes = await captureBalanceShareCard(context, card: card);
  if (bytes == null || !context.mounted) return false;

  try {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            name: 'scenesplit-balances.png',
            mimeType: 'image/png',
          ),
        ],
        subject: l10n.groupsShareBalancesSubject(groupName),
        text: l10n.groupsShareBalancesText(groupName),
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on Object {
    return false;
  }
}

/// Builds [card] in an off-screen overlay and returns PNG bytes.
@visibleForTesting
Future<Uint8List?> captureBalanceShareCard(
  BuildContext context, {
  required BalanceShareCard card,
  double pixelRatio = 3,
}) async {
  final boundaryKey = GlobalKey();
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return null;

  final entry = OverlayEntry(
    builder: (_) {
      return Positioned(
        left: -10000,
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling, boldText: false),
            child: Directionality(
              textDirection: Directionality.of(context),
              child: Theme(
                data: AppTheme.light,
                child: RepaintBoundary(key: boundaryKey, child: card),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(Duration.zero);
  await WidgetsBinding.instance.endOfFrame;

  try {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    // Wait until layout has a real size.
    if (boundary.hasSize == false || boundary.size.isEmpty) {
      await WidgetsBinding.instance.endOfFrame;
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}
