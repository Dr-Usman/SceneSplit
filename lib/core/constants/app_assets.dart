import 'package:flutter/material.dart';

/// Central registry of bundled asset paths.
abstract class AppAssets {
  static const String logo = 'assets/images/logo_light.png';
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';
  static const String logoMark = 'assets/images/logo_mark.png';

  /// Returns the appropriate logo asset based on theme brightness.
  static String logoForBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? logoDark : logoLight;

  /// Returns the appropriate logo asset for the given [BuildContext].
  static String logoFor(BuildContext context) =>
      logoForBrightness(Theme.of(context).brightness);
}
