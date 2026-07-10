import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_links.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_link_launcher.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/settings_tile.dart';
import '../legal/legal_document_screen.dart';
import '../legal/legal_document_type.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _sendEmail(BuildContext context, String subject) async {
    final launched = await launchSupportEmail(subject);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '…';
          final build = snapshot.data?.buildNumber ?? '…';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppShadows.logo(context),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: 120,
                      height: 108,
                      color: AppColors.logoBackground,
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLinks.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Version $version ($build)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Split expenses with friends.\nOffline-first. No account required.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            type: LegalDocumentType.privacy,
                          ),
                        ),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            type: LegalDocumentType.terms,
                          ),
                        ),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Contact us',
                      onTap: () => _sendEmail(context, 'SceneSplit Support'),
                    ),
                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send feedback',
                      onTap: () => _sendEmail(context, 'SceneSplit Feedback'),
                    ),
                    SettingsTile(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Suggest a feature',
                      onTap: () =>
                          _sendEmail(context, 'SceneSplit Feature Suggestion'),
                    ),
                    SettingsTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate ${AppLinks.appName}',
                      showDivider: false,
                      onTap: () => requestAppReview(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '© ${DateTime.now().year} ${AppLinks.appName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
