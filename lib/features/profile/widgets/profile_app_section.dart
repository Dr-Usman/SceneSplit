import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_links.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../../about/about_screen.dart';

class ProfileAppSection extends StatelessWidget {
  const ProfileAppSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.profileApp),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.profileAboutApp(AppLinks.appName),
            subtitle: l10n.profileAboutSubtitle,
            showDivider: false,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.data?.version ?? '…';
            final buildNumber = snapshot.data?.buildNumber ?? '…';
            return Text(
              l10n.profileVersionFooter(AppLinks.appName, version, buildNumber),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ],
    );
  }
}
