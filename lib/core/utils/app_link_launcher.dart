import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_links.dart';

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

Future<bool> launchSupportEmail(String subject) async {
  final info = await PackageInfo.fromPlatform();
  final body =
      '\n\n---\nApp: ${AppLinks.appName} ${info.version} (${info.buildNumber})';
  return launchEmail(subject: subject, body: body);
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
