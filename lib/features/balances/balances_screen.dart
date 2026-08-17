import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import '../../database/app_database.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/balances_overview_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import 'pair_balance_screen.dart';
import 'widgets/active_filter_chip.dart';
import 'widgets/balances_empty_debts.dart';
import 'widgets/balances_hero_card.dart';
import 'widgets/pair_debt_card.dart';
import 'widgets/pair_filter_sheet.dart';
import 'widgets/person_picker_sheet.dart';

class BalancesScreen extends ConsumerStatefulWidget {
  const BalancesScreen({super.key});

  @override
  ConsumerState<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends ConsumerState<BalancesScreen> {
  /// Debtor filter; null = anyone.
  String? _whoId;

  /// Creditor filter; null = anyone unless [_defaultWhomToYou] is true.
  String? _whomId;

  /// When true (initial), Whom resolves to the current user until Clear or an
  /// explicit Whom pick/clear.
  bool _defaultWhomToYou = true;

  String? _effectiveWhomId(User? currentUser) {
    if (_defaultWhomToYou) return currentUser?.id;
    return _whomId;
  }

  void _clearFilters() {
    setState(() {
      _whoId = null;
      _whomId = null;
      _defaultWhomToYou = false;
    });
    ref.read(analyticsServiceProvider).trackBalancesFilterCleared();
  }

  bool get _hasActiveFilter =>
      _whoId != null || _whomId != null || _defaultWhomToYou;

  Future<void> _pickPerson({required bool pickingWho}) async {
    final users = ref.read(usersStreamProvider).value ?? [];
    final current = ref.read(currentUserProvider).value;
    final currentWhom = _effectiveWhomId(current);
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) => PersonPickerSheet(
            users: users,
            excludeUserId: pickingWho ? currentWhom : _whoId,
            selectedUserId: pickingWho ? _whoId : currentWhom,
            scrollController: scrollController,
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      if (pickingWho) {
        _whoId = selected.isEmpty ? null : selected;
      } else {
        _defaultWhomToYou = false;
        _whomId = selected.isEmpty ? null : selected;
      }
    });
  }

  Future<void> _openFilterSheet(Map<String, User> users) async {
    final current = ref.read(currentUserProvider).value;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final whomId = _effectiveWhomId(current);
            return PairFilterSheet(
              users: users,
              whoId: _whoId,
              whomId: whomId,
              onPickWho: () async {
                await _pickPerson(pickingWho: true);
                if (context.mounted) setModalState(() {});
              },
              onPickWhom: () async {
                await _pickPerson(pickingWho: false);
                if (context.mounted) setModalState(() {});
              },
              onClearWho: () {
                setState(() => _whoId = null);
                setModalState(() {});
              },
              onClearWhom: () {
                setState(() {
                  _whomId = null;
                  _defaultWhomToYou = false;
                });
                setModalState(() {});
              },
              onClear: () {
                _clearFilters();
                Navigator.of(ctx).pop();
              },
              onShowResults: () {
                final appliedWhom = _effectiveWhomId(current);
                if (_whoId != null || appliedWhom != null) {
                  ref
                      .read(analyticsServiceProvider)
                      .trackBalancesFilterApplied(
                        whoSet: _whoId != null,
                        whomSet: appliedWhom != null,
                        whomIsYou:
                            appliedWhom != null && appliedWhom == current?.id,
                      );
                }
                Navigator.of(ctx).pop();
              },
            );
          },
        );
      },
    );
  }

  void _openPair(PairOpenBalanceSummary pair) {
    final whomId = _effectiveWhomId(ref.read(currentUserProvider).value);
    ref
        .read(analyticsServiceProvider)
        .trackBalancesPairOpened(
          hasWhoFilter: _whoId != null,
          hasWhomFilter: whomId != null,
          currencyCount: pair.currencyTotals.length,
        );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PairBalanceScreen(
          fromUserId: pair.fromUserId,
          toUserId: pair.toUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final overviewAsync = ref.watch(balancesOverviewProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final whomId = _effectiveWhomId(currentUser);
    final fallbackCurrency = ref.watch(currencyCodeProvider).value ?? 'PKR';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.balancesTitle),
        actions: [
          if (_hasActiveFilter)
            TextButton(
              onPressed: _clearFilters,
              child: Text(l10n.balancesClear),
            ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.commonSomethingWentWrong('$e'))),
        data: (data) {
          final filtered = filterOpenDebts(
            data.openDebts,
            fromId: _whoId,
            toId: whomId,
          );
          final pairs = groupDebtsByPair(filtered);
          // Prefer readable name order using user map.
          pairs.sort((a, b) {
            final aFrom =
                data.users[a.fromUserId]?.name.toLowerCase() ?? a.fromUserId;
            final bFrom =
                data.users[b.fromUserId]?.name.toLowerCase() ?? b.fromUserId;
            final byFrom = aFrom.compareTo(bFrom);
            if (byFrom != 0) return byFrom;
            final aTo =
                data.users[a.toUserId]?.name.toLowerCase() ?? a.toUserId;
            final bTo =
                data.users[b.toUserId]?.name.toLowerCase() ?? b.toUserId;
            return aTo.compareTo(bTo);
          });

          final whoUser = _whoId == null ? null : data.users[_whoId!];
          final whomUser = whomId == null ? null : data.users[whomId];
          final heroSubject = whomUser ?? whoUser;
          final showHero = heroSubject != null;
          final heroDebts = scopeDebtsForBalancesHero(
            data.openDebts,
            whoId: _whoId,
            whomId: whomId,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (showHero) ...[
                BalancesHeroCard(
                  person: heroSubject,
                  openDebts: heroDebts,
                  users: data.users,
                  locale: locale,
                  fallbackCurrency: fallbackCurrency,
                  pairOther: whomUser != null && whoUser != null
                      ? whoUser
                      : null,
                ),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                  l10n.balancesSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ActiveFilterChip(
                users: data.users,
                whoId: _whoId,
                whomId: whomId,
                onTap: () => _openFilterSheet(data.users),
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.border,
              ),
              const SizedBox(height: 12),
              if (pairs.isEmpty)
                BalancesEmptyDebts(
                  message: data.openDebts.isEmpty
                      ? l10n.balancesEmpty
                      : l10n.balancesEmptyFiltered,
                )
              else
                for (final pair in pairs) ...[
                  PairDebtCard(
                    summary: pair,
                    users: data.users,
                    locale: locale,
                    currentUserId: currentUser?.id,
                    onTap: () => _openPair(pair),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          );
        },
      ),
    );
  }
}
