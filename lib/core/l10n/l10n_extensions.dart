import 'package:flutter/widgets.dart';
import 'package:scene_split/l10n/app_localizations.dart';

export 'package:scene_split/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
