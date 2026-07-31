/// App-wide links and contact details. Update before store submission.
abstract class AppLinks {
  static const appName = 'SceneSplit';
  static const supportEmail = 'dr.usman7860@gmail.com';

  /// Public HTTPS URL — required for App Store / Play Store at submission.
  static const privacyPolicyUrl = 'https://write.as/nfhnsrkt1rcch.md';

  /// Optional public terms URL.
  static const termsUrl = '';

  /// Play Store listing — fill after publish for Rate us / Share fallback.
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.avenzor.scenesplit';

  /// App Store listing — fill after publish for Rate us / Share fallback.
  static const appStoreUrl = '';

  /// Live web demo / download landing page.
  static const webUrl = 'https://dr-usman.github.io/SceneSplit/';

  /// Store and web URLs included when sharing the app (non-empty only).
  static List<String> get shareStoreUrls {
    return [
      if (playStoreUrl.isNotEmpty) playStoreUrl,
      if (appStoreUrl.isNotEmpty) appStoreUrl,
      if (webUrl.isNotEmpty) webUrl,
    ];
  }
}
