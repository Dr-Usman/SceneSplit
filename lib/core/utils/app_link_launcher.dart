import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_links.dart';
import '../l10n/l10n_extensions.dart';

Future<bool> launchEmail({required String subject, String? body}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: AppLinks.supportEmail,
    queryParameters: {
      'subject': subject,
      if (body != null && body.isNotEmpty) 'body': body,
    },
  );
  return launchUrl(uri);
}

Future<bool> launchSupportEmail(String subject, AppLocalizations l10n) async {
  final info = await PackageInfo.fromPlatform();
  final body = l10n.supportEmailBodyFooter(
    AppLinks.appName,
    info.version,
    info.buildNumber,
  );
  return launchEmail(subject: subject, body: body);
}

/// Opens the system share sheet with a localized pitch and store/web links.
Future<bool> shareApp(BuildContext context) async {
  final l10n = context.l10n;
  final links = AppLinks.shareStoreUrls.join('\n');
  if (links.isEmpty) return false;

  final box = context.findRenderObject() as RenderBox?;
  final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

  try {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: l10n.aboutShareAppMessage(AppLinks.appName, links),
        subject: l10n.aboutShareAppSubject(AppLinks.appName),
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on Object {
    return false;
  }
}

Future<void> requestAppReview() async {
  final review = InAppReview.instance;
  if (await review.isAvailable()) {
    await review.requestReview();
    return;
  }

  final storeUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
      ? AppLinks.appStoreUrl
      : AppLinks.playStoreUrl;
  if (storeUrl.isNotEmpty) {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

Future<bool> launchExternalUrl(String url) async {
  if (url.isEmpty) return false;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return false;
}
