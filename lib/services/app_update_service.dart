import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_links.dart';
import '../core/l10n/l10n_extensions.dart';
import '../core/utils/version_compare.dart';
import 'analytics_service.dart';
import 'itunes_lookup_io.dart'
    if (dart.library.html) 'itunes_lookup_stub.dart'
    as itunes_lookup;

/// Flexible in-app updates: Play Core on Android, App Store prompt on iOS.
abstract final class AppUpdateService {
  static const _iosBundleId = 'com.avenzor.scenesplit';
  static const _itunesLookupUrl =
      'https://itunes.apple.com/lookup?bundleId=$_iosBundleId';

  static bool _checkedThisSession = false;

  /// Once per process: check for a store update and prompt if appropriate.
  ///
  /// Safe to call from any screen with a [Scaffold]; failures are swallowed
  /// (offline, sideloaded APK, missing App Store listing, etc.).
  static Future<void> checkAndPrompt(
    BuildContext context, {
    AnalyticsService? analytics,
  }) async {
    if (_checkedThisSession || kIsWeb) return;
    _checkedThisSession = true;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Play In-App Updates only work for Play-installed builds.
        if (kDebugMode) return;
        await _checkAndroid(context, analytics: analytics);
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _checkIos(context, analytics: analytics);
      }
    } on Object {
      // Intentionally silent — update checks must never break the app.
    }
  }

  /// Test hook to reset the session gate.
  @visibleForTesting
  static void resetSessionGateForTest() => _checkedThisSession = false;

  static Future<void> _checkAndroid(
    BuildContext context, {
    AnalyticsService? analytics,
  }) async {
    final info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      return;
    }
    if (!info.flexibleUpdateAllowed) return;
    if (!context.mounted) return;

    await analytics?.trackUpdatePrompted(platform: 'android');
    await analytics?.trackUpdateStarted(platform: 'android');

    final result = await InAppUpdate.startFlexibleUpdate();
    if (result != AppUpdateResult.success || !context.mounted) return;

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.updateReadyMessage),
        action: SnackBarAction(
          label: l10n.updateRestartAction,
          onPressed: () {
            InAppUpdate.completeFlexibleUpdate();
          },
        ),
        duration: const Duration(days: 1),
      ),
    );
  }

  static Future<void> _checkIos(
    BuildContext context, {
    AnalyticsService? analytics,
  }) async {
    final store = await itunes_lookup.fetchIosStoreInfo(_itunesLookupUrl);
    if (store == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final storeVersion = store['version'];
    if (storeVersion == null ||
        !isStoreVersionNewer(packageInfo.version, storeVersion)) {
      return;
    }
    if (!context.mounted) return;

    await analytics?.trackUpdatePrompted(platform: 'ios');
    if (!context.mounted) return;

    final l10n = context.l10n;
    final trackViewUrl = store['trackViewUrl'] ?? '';
    final storeUrl = trackViewUrl.isNotEmpty
        ? trackViewUrl
        : AppLinks.appStoreUrl;
    if (storeUrl.isEmpty) return;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.updateAvailableTitle),
          content: Text(l10n.updateAvailableBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.updateLaterAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.updateNowAction),
            ),
          ],
        );
      },
    );

    if (shouldUpdate != true) return;
    await analytics?.trackUpdateStarted(platform: 'ios');
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
