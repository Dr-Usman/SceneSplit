import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
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
    await completeOnboarding(
      db,
      name: _nameController.text.trim(),
      currencyCode: _currencyCode,
    );
    // currentUserProvider stream will flip the app to home automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo mark
                Center(
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
                        padding: const EdgeInsets.all(8),
                        color: AppColors.logoBackground,
                        child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Split expenses with friends.\nNo accounts, no fuss.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader('YOUR NAME'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        autofocus: false,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Usman',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        onSubmitted: (_) {
                          if (_canContinue) _getStarted();
                        },
                      ),
                      const SizedBox(height: 20),
                      const SectionHeader('CURRENCY'),
                      const SizedBox(height: 8),
                      CurrencyPickerField(
                        currencyCode: _currencyCode,
                        onChanged: (code) =>
                            setState(() => _currencyCode = code),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                FilledButton(
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
                      : const Text('Get Started'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Everything stays on your device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
