import 'package:scene_split/l10n/app_localizations.dart';

enum LegalDocumentType {
  privacy(assetPath: 'assets/legal/privacy_policy.md'),
  terms(assetPath: 'assets/legal/terms_of_service.md');

  const LegalDocumentType({required this.assetPath});

  final String assetPath;

  String title(AppLocalizations l10n) => switch (this) {
    LegalDocumentType.privacy => l10n.legalPrivacyTitle,
    LegalDocumentType.terms => l10n.legalTermsTitle,
  };
}
