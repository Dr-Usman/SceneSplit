import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/database_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/currency_picker_sheet.dart';
import '../../shared/widgets/section_header.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _desktopBreakpoint = 900.0;
  static const _narrowMaxWidth = 520.0;
  static const _wideMaxWidth = 1100.0;
  static const _formMaxWidth = 460.0;

  final _nameController = TextEditingController();
  String _currencyCode = 'PKR';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue => _nameController.text.trim().isNotEmpty && !_saving;

  Future<void> _getStarted() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final name = _nameController.text.trim();
    final userId = await completeOnboarding(
      db,
      name: name,
      currencyCode: _currencyCode,
    );
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.identifyUser(
      userId,
      name: name,
      currencyCode: _currencyCode,
    );
    await analytics.trackSignUpCompleted(
      userId: userId,
      name: name,
      defaultCurrency: _currencyCode,
    );
    // currentUserProvider stream will flip the app to home automatically.
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final minHeight = media.size.height - media.padding.vertical;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _desktopBreakpoint;
            final horizontalPadding = isWide ? 48.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? _wideMaxWidth : _narrowMaxWidth,
                    ),
                    child: isWide
                        ? _buildWideLayout(context)
                        : _buildNarrowLayout(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        _buildHero(context, centered: true),
        const SizedBox(height: 48),
        _buildFormCard(context),
        const SizedBox(height: 36),
        _buildGetStartedButton(),
        const SizedBox(height: 16),
        _buildPrivacyNote(context, textAlign: TextAlign.center),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildHero(context, centered: false)),
          const SizedBox(width: 48),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _formMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormCard(context),
                const SizedBox(height: 28),
                _buildGetStartedButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, {required bool centered}) {
    final l10n = context.l10n;
    final taglineStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      height: 1.5,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.logo(context),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 200,
                height: 180,
                padding: const EdgeInsets.all(12),
                color: AppColors.logoBackground,
                child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.onboardingTagline,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: taglineStyle,
        ),
        if (!centered) ...[
          const SizedBox(height: 20),
          _buildPrivacyNote(context, textAlign: TextAlign.start),
        ],
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(l10n.onboardingYourName),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            autofocus: false,
            decoration: InputDecoration(
              hintText: l10n.onboardingNameHint,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            onSubmitted: (_) {
              if (_canContinue) _getStarted();
            },
          ),
          const SizedBox(height: 20),
          SectionHeader(l10n.onboardingCurrency),
          const SizedBox(height: 8),
          CurrencyPickerField(
            currencyCode: _currencyCode,
            onChanged: (code) => setState(() => _currencyCode = code),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    final l10n = context.l10n;
    return FilledButton(
      onPressed: _canContinue ? _getStarted : null,
      child: _saving
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(l10n.onboardingGetStarted),
    );
  }

  Widget _buildPrivacyNote(
    BuildContext context, {
    required TextAlign textAlign,
  }) {
    return Text(
      context.l10n.onboardingPrivacyNote,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
