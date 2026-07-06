enum LegalDocumentType {
  privacy(title: 'Privacy Policy', assetPath: 'assets/legal/privacy_policy.md'),
  terms(
    title: 'Terms of Service',
    assetPath: 'assets/legal/terms_of_service.md',
  );

  const LegalDocumentType({required this.title, required this.assetPath});

  final String title;
  final String assetPath;
}
