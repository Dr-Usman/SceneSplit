import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/currencies.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/database_provider.dart';

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
                    width: 200,
                    height: 180,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.logoBackground,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                  ),
                ),
                // const SizedBox(height: 28),
                // Text(
                //   'SceneSplit',
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                //     fontWeight: FontWeight.w800,
                //     letterSpacing: -0.5,
                //   ),
                // ),
                const SizedBox(height: 10),
                Text(
                  'Split expenses with friends.\nNo accounts, no fuss.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'YOUR NAME',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
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
                Text(
                  'CURRENCY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _CurrencyPicker(
                  selected: _currencyCode,
                  onChanged: (code) => setState(() => _currencyCode = code),
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
                    color: AppColors.textSecondary,
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

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(selected);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.payments_outlined),
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Text(
          '${currency.code} — ${currency.name}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                'Choose currency',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final c in supportedCurrencies)
              ListTile(
                leading: SizedBox(
                  width: 40,
                  child: Text(
                    c.symbol,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(c.name),
                subtitle: Text(c.code),
                trailing: c.code == selected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged(c.code);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}
