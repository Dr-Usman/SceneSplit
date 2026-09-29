import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/core/utils/share_expenses.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/features/expenses/expense_detail_screen.dart';
import 'package:scene_split/features/groups/widgets/share_expenses_sheet.dart';
import 'package:scene_split/features/settlements/record_settlement_sheet.dart';
import 'package:scene_split/providers/analytics_provider.dart';
import 'package:scene_split/providers/data_providers.dart';
import 'package:scene_split/providers/database_provider.dart';
import 'package:scene_split/providers/group_detail_provider.dart';
import 'package:scene_split/services/balance_service.dart';
import 'package:scene_split/shared/widgets/app_card.dart';
import 'package:scene_split/shared/widgets/open_debt_tile.dart';
import 'package:scene_split/shared/widgets/section_header.dart';

import 'widgets/compact_expense_tile.dart';
import 'widgets/compact_settlement_tile.dart';
import 'widgets/date_range_dialog.dart';
import 'widgets/group_report_share_card.dart';
import 'widgets/report_filter_buttons.dart';
import 'widgets/report_hero_totals_card.dart';
import 'widgets/report_member_summary_card.dart';

/// Full in-app reporting screen with search, date & member filtering, totals,
/// who-owes-whom, member breakdown, and separate compact itemized expenses & settlements.
class GroupReportScreen extends ConsumerStatefulWidget {
  const GroupReportScreen({
    super.key,
    required this.groupId,
    this.initialPreset = ExpenseShareRangePreset.all,
    this.source = 'group_detail',
  });

  final String groupId;
  final ExpenseShareRangePreset initialPreset;
  final String source;

  @override
  ConsumerState<GroupReportScreen> createState() => _GroupReportScreenState();
}

class _GroupReportScreenState extends ConsumerState<GroupReportScreen> {
  static const int _kInitialItemLimit = 10;
  static const int _kItemLimitStep = 15;

  late ExpenseShareRangePreset _preset;
  DateTimeRange? _customRange;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMemberId;
  ReportSortOrder _sortOrder = ReportSortOrder.dateDesc;
  int _expenseLimit = _kInitialItemLimit;
  int _settlementLimit = _kInitialItemLimit;
  bool _hasTrackedOpen = false;

  @override
  void initState() {
    super.initState();
    _preset = widget.initialPreset;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSelectDatePreset(
    ExpenseShareRangePreset preset, {
    required String groupName,
  }) async {
    bool applied = false;
    if (preset == ExpenseShareRangePreset.singleDay) {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: _customRange?.start ?? now,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null && mounted) {
        final day = dateOnly(picked);
        setState(() {
          _customRange = DateTimeRange(start: day, end: day);
          _preset = ExpenseShareRangePreset.singleDay;
        });
        applied = true;
      }
    } else if (preset == ExpenseShareRangePreset.custom) {
      final picked = await showDateRangeDialog(
        context: context,
        initialRange: _customRange,
      );
      if (picked != null && mounted) {
        setState(() {
          _customRange = picked;
          _preset = ExpenseShareRangePreset.custom;
        });
        applied = true;
      }
    } else {
      setState(() {
        _preset = preset;
      });
      applied = true;
    }

    if (applied && mounted) {
      ref
          .read(analyticsServiceProvider)
          .trackReportFilterApplied(
            groupId: widget.groupId,
            groupName: groupName,
            filterType: 'date',
            filterValue: preset.name,
          );
    }
  }

  Future<void> _shareReport({
    required GroupDetailData data,
    required GroupPeriodReportData report,
    required List<ExpenseWithSplits> filteredExpenses,
    required List<Settlement> filteredSettlements,
    required List<OpenDebt> displayedDebts,
    required DateTimeRange? range,
    required String rangeLabel,
    required String locale,
    required int totalSettledCents,
    required int openDebtCents,
    required int memberNetCents,
    required int memberPaidCents,
    required int memberReceivedCents,
    required String? selectedMemberName,
    required bool isCurrentUser,
  }) async {
    final l10n = context.l10n;
    if (filteredExpenses.isEmpty && filteredSettlements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupsShareExpensesEmptyRange)),
      );
      return;
    }

    final format = await showExpenseShareFormatSheet(context);
    if (format == null || !mounted) return;

    final users = ref.read(userByIdProvider);
    final userNames = {
      for (final entry in users.entries) entry.key: entry.value.name,
    };
    final groupName = data.group.name;
    final currencyCode = data.group.currencyCode;
    final isSingleMember = _selectedMemberId != null;

    final memberSummaries = isSingleMember
        ? report.memberSummaries
              .where((s) => s.userId == _selectedMemberId)
              .toList()
        : report.memberSummaries;

    final bool ok;
    switch (format) {
      case ExpenseShareFormat.image:
        final card = GroupReportShareCard(
          groupEmoji: data.group.emoji,
          groupName: groupName,
          rangeLabel: rangeLabel,
          expenseCount: filteredExpenses.length,
          settlementCount: filteredSettlements.length,
          currencyCode: currencyCode,
          locale: locale,
          showDecimals: data.group.showDecimals,
          selectedMemberId: _selectedMemberId,
          selectedMemberName: selectedMemberName,
          isCurrentUser: isCurrentUser,
          totalSpendCents: report.totalSpendCents,
          totalSettledCents: totalSettledCents,
          openDebtCents: openDebtCents,
          memberNetCents: memberNetCents,
          memberPaidCents: memberPaidCents,
          memberReceivedCents: memberReceivedCents,
          debts: displayedDebts,
          users: users,
          memberSummaries: memberSummaries,
        );
        ok = await shareExpenseImage(
          context,
          groupName: groupName,
          caption: expenseShareCaption(
            l10n: l10n,
            groupName: groupName,
            rangeLabel: rangeLabel,
            isAllDates: range == null,
          ),
          card: card,
        );
      case ExpenseShareFormat.text:
        final body = buildGroupReportShareText(
          groupEmoji: data.group.emoji,
          groupName: groupName,
          rangeLabel: rangeLabel,
          totalSpendCents: report.totalSpendCents,
          totalSettledCents: totalSettledCents,
          openDebtCents: openDebtCents,
          debts: displayedDebts,
          memberSummaries: memberSummaries,
          expenses: filteredExpenses,
          settlements: filteredSettlements,
          userNames: userNames,
          l10n: l10n,
          currencyCode: currencyCode,
          locale: locale,
          showDecimals: data.group.showDecimals,
          selectedMemberId: _selectedMemberId,
          selectedMemberName: selectedMemberName,
          isCurrentUser: isCurrentUser,
          memberNetCents: memberNetCents,
          memberPaidCents: memberPaidCents,
          memberReceivedCents: memberReceivedCents,
        );
        ok = await shareExpenseText(context, groupName: groupName, body: body);
    }

    if (!mounted) return;
    if (ok) {
      await ref
          .read(analyticsServiceProvider)
          .trackReportShared(
            groupId: widget.groupId,
            groupName: groupName,
            format: format.name,
            rangePreset: _preset.name,
            isSingleMember: isSingleMember,
            selectedMemberName: selectedMemberName,
            expenseCount: filteredExpenses.length,
            settlementCount: filteredSettlements.length,
          );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupsCouldNotShareExpenses)));
    }
  }

  bool _matchesExpenseSearch(
    String query,
    ExpenseWithSplits item, {
    required String currencyCode,
    required String locale,
    bool showDecimals = true,
  }) {
    if (query.isEmpty) return true;
    final title = item.expense.title.toLowerCase();
    if (title.contains(query)) return true;
    final note = item.expense.note?.toLowerCase();
    if (note != null && note.contains(query)) return true;

    // Numeric and formatted amount matching
    final amountCents = item.expense.amountCents;
    if (amountCents.toString().contains(query)) return true;
    final plainAmount = (amountCents / 100.0).toString();
    if (plainAmount.contains(query)) return true;
    final plainFixed = (amountCents / 100.0).toStringAsFixed(2);
    if (plainFixed.contains(query)) return true;
    final formatted = formatCents(
      amountCents,
      currencyCode,
      locale: locale,
      showDecimals: showDecimals,
    ).toLowerCase();
    if (formatted.contains(query)) return true;

    return false;
  }

  bool _matchesSettlementSearch(
    String query,
    Settlement settlement, {
    required String currencyCode,
    required String locale,
    bool showDecimals = true,
  }) {
    if (query.isEmpty) return true;
    final note = settlement.note?.toLowerCase();
    if (note != null && note.contains(query)) return true;

    // Numeric and formatted amount matching
    final amountCents = settlement.amountCents;
    if (amountCents.toString().contains(query)) return true;
    final plainAmount = (amountCents / 100.0).toString();
    if (plainAmount.contains(query)) return true;
    final plainFixed = (amountCents / 100.0).toStringAsFixed(2);
    if (plainFixed.contains(query)) return true;
    final formatted = formatCents(
      amountCents,
      currencyCode,
      locale: locale,
      showDecimals: showDecimals,
    ).toLowerCase();
    if (formatted.contains(query)) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final detailAsync = ref.watch(groupDetailProvider(widget.groupId));
    final users = ref.watch(userByIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.groupsReport)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.groupsReport)),
        body: Center(child: Text('$e')),
      ),
      data: (data) {
        if (!_hasTrackedOpen) {
          _hasTrackedOpen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref
                  .read(analyticsServiceProvider)
                  .trackReportOpened(
                    groupId: widget.groupId,
                    groupName: data.group.name,
                    source: widget.source,
                    defaultPreset: _preset.name,
                    expenseCount: data.expenses.length,
                    settlementCount: data.settlements.length,
                  );
            }
          });
        }

        final range = resolveExpenseShareRange(
          _preset,
          now: DateTime.now(),
          custom: _customRange,
        );

        final report = buildGroupPeriodReport(
          allExpenses: data.expenses,
          allSettlements: data.settlements,
          members: data.members,
          users: users,
          range: range,
          currentUserId: currentUser?.id,
        );

        final rangeLabel = formatExpenseShareRangeLabel(
          range,
          l10n: l10n,
          locale: locale,
        );

        // Apply member filter
        final memberFilteredExpenses = report.filteredExpenses.where((item) {
          if (_selectedMemberId == null) return true;
          final isPayer = item.payers.any((p) => p.userId == _selectedMemberId);
          final isSplitter = item.splits.any(
            (s) => s.userId == _selectedMemberId && s.amountCents > 0,
          );
          return isPayer || isSplitter;
        }).toList();

        final memberFilteredSettlements = report.filteredSettlements.where((
          settlement,
        ) {
          if (_selectedMemberId == null) return true;
          return settlement.fromUserId == _selectedMemberId ||
              settlement.toUserId == _selectedMemberId;
        }).toList();

        // Apply real-time search filter and date sort
        final displayedExpenses =
            memberFilteredExpenses.where((item) {
              return _matchesExpenseSearch(
                _searchQuery,
                item,
                currencyCode: data.group.currencyCode,
                locale: locale,
                showDecimals: data.group.showDecimals,
              );
            }).toList()..sort((a, b) {
              final cmp = a.expense.date.compareTo(b.expense.date);
              return _sortOrder == ReportSortOrder.dateAsc ? cmp : -cmp;
            });

        final displayedSettlements =
            memberFilteredSettlements.where((settlement) {
              return _matchesSettlementSearch(
                _searchQuery,
                settlement,
                currencyCode: data.group.currencyCode,
                locale: locale,
                showDecimals: data.group.showDecimals,
              );
            }).toList()..sort((a, b) {
              final cmp = a.date.compareTo(b.date);
              return _sortOrder == ReportSortOrder.dateAsc ? cmp : -cmp;
            });

        final isSingleMember = _selectedMemberId != null;
        final selectedMemberUser = isSingleMember
            ? users[_selectedMemberId]
            : null;
        final isCurrentUser =
            isSingleMember && _selectedMemberId == currentUser?.id;
        final selectedMemberName = selectedMemberUser?.name;

        final totalSettledCents = report.filteredSettlements.fold<int>(
          0,
          (sum, s) => sum + s.amountCents,
        );
        final openDebtCents = report.periodDebts.fold<int>(
          0,
          (sum, d) => sum + d.amountCents,
        );

        final memberSummary = isSingleMember
            ? report.memberSummaries.firstWhereOrNull(
                (s) => s.userId == _selectedMemberId,
              )
            : null;
        final memberNetCents = memberSummary?.netCents ?? 0;
        final settlementsSentCents = isSingleMember
            ? report.filteredSettlements
                  .where((s) => s.fromUserId == _selectedMemberId)
                  .fold<int>(0, (sum, s) => sum + s.amountCents)
            : 0;
        final settlementsReceivedCents = isSingleMember
            ? report.filteredSettlements
                  .where((s) => s.toUserId == _selectedMemberId)
                  .fold<int>(0, (sum, s) => sum + s.amountCents)
            : 0;
        final memberPaidCents =
            (memberSummary?.paidCents ?? 0) + settlementsSentCents;
        final memberReceivedCents = settlementsReceivedCents;

        final displayedDebts = isSingleMember
            ? report.periodDebts
                  .where(
                    (d) =>
                        d.fromUserId == _selectedMemberId ||
                        d.toUserId == _selectedMemberId,
                  )
                  .toList()
            : report.periodDebts;

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.groupsReportTitle(data.group.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                tooltip: l10n.groupsShareExpenses,
                onPressed: () => _shareReport(
                  data: data,
                  report: report,
                  filteredExpenses: displayedExpenses,
                  filteredSettlements: displayedSettlements,
                  displayedDebts: displayedDebts,
                  range: range,
                  rangeLabel: rangeLabel,
                  locale: locale,
                  totalSettledCents: totalSettledCents,
                  openDebtCents: openDebtCents,
                  memberNetCents: memberNetCents,
                  memberPaidCents: memberPaidCents,
                  memberReceivedCents: memberReceivedCents,
                  selectedMemberName: selectedMemberName,
                  isCurrentUser: isCurrentUser,
                ),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // Search text field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.groupsReportSearchPlaceholder,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
              ),
              const SizedBox(height: 10),

              // Filter Dropdowns Row: Date filter & Member filter
              Row(
                children: [
                  Expanded(
                    child: DateFilterMenuButton(
                      activePreset: _preset,
                      customRange: _customRange,
                      locale: locale,
                      onSelect: (preset) => _onSelectDatePreset(
                        preset,
                        groupName: data.group.name,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MemberFilterMenuButton(
                      members: data.members,
                      users: users,
                      selectedMemberId: _selectedMemberId,
                      onSelect: (memberId) {
                        setState(() => _selectedMemberId = memberId);
                        final memberName = memberId != null
                            ? (users[memberId]?.name ?? memberId)
                            : 'all';
                        ref
                            .read(analyticsServiceProvider)
                            .trackReportFilterApplied(
                              groupId: widget.groupId,
                              groupName: data.group.name,
                              filterType: 'member',
                              filterValue: memberName,
                            );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Active date range subtitle & sort button
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rangeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SortMenuButton(
                    sortOrder: _sortOrder,
                    onSelect: (order) {
                      setState(() => _sortOrder = order);
                      ref
                          .read(analyticsServiceProvider)
                          .trackReportSortChanged(
                            groupId: widget.groupId,
                            groupName: data.group.name,
                            sortOrder: order.name,
                          );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // KPI Hero Card
              ReportHeroTotalsCard(
                selectedMemberId: _selectedMemberId,
                selectedMemberName: selectedMemberName,
                isCurrentUser: isCurrentUser,
                totalSpendCents: report.totalSpendCents,
                expenseCount: isSingleMember
                    ? memberFilteredExpenses.length
                    : report.expenseCount,
                totalSettledCents: totalSettledCents,
                settlementCount: report.filteredSettlements.length,
                openDebtCents: openDebtCents,
                memberNetCents: memberNetCents,
                memberPaidCents: memberPaidCents,
                memberReceivedCents: memberReceivedCents,
                currencyCode: data.group.currencyCode,
                locale: locale,
                showDecimals: data.group.showDecimals,
              ),

              // Who owes whom
              const SizedBox(height: 24),
              SectionHeader(l10n.groupsReportWhoOwesWhom),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: displayedDebts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              l10n.groupsReportSettled,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.positive,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatCents(
                                0,
                                data.group.currencyCode,
                                locale: locale,
                                showDecimals: false,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < displayedDebts.length; i++) ...[
                            OpenDebtTile(
                              debt: displayedDebts[i],
                              users: users,
                              currencyCode: data.group.currencyCode,
                              locale: locale,
                              showDecimals: data.group.showDecimals,
                              showAvatars: true,
                            ),
                            if (i < displayedDebts.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
              ),

              // Member Breakdown
              if (report.memberSummaries.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(l10n.groupsReportMemberSummary),
                const SizedBox(height: 10),
                ReportMemberSummaryCard(
                  summaries: report.memberSummaries,
                  users: users,
                  currencyCode: data.group.currencyCode,
                  locale: locale,
                  showDecimals: data.group.showDecimals,
                ),
              ],

              // Expenses Section
              const SizedBox(height: 24),
              SectionHeader(
                l10n.groupsReportItemizedExpenses(displayedExpenses.length),
              ),
              const SizedBox(height: 10),
              if (displayedExpenses.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 36,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.groupsShareExpensesEmptyRange,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                () {
                  final visibleExpenses = displayedExpenses
                      .take(_expenseLimit)
                      .toList();
                  final remainingExpenses =
                      displayedExpenses.length - visibleExpenses.length;

                  return AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < visibleExpenses.length; i++) ...[
                          CompactExpenseTile(
                            item: visibleExpenses[i],
                            users: users,
                            currencyCode: data.group.currencyCode,
                            locale: locale,
                            showDecimals: data.group.showDecimals,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ExpenseDetailScreen(
                                    groupId: widget.groupId,
                                    expenseId: visibleExpenses[i].expense.id,
                                    currencyCode: data.group.currencyCode,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (i < visibleExpenses.length - 1 ||
                              remainingExpenses > 0)
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                        ],
                        if (remainingExpenses > 0)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expenseLimit += _kItemLimitStep;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.groupsReportShowMore(
                                      remainingExpenses,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }(),

              // Itemized Compact Settlements Section (cleanly hidden if 0 exist)
              if (displayedSettlements.isNotEmpty)
                () {
                  final visibleSettlements = displayedSettlements
                      .take(_settlementLimit)
                      .toList();
                  final remainingSettlements =
                      displayedSettlements.length - visibleSettlements.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      SectionHeader(
                        '${l10n.groupsSettlementsTitle} (${displayedSettlements.length})',
                      ),
                      const SizedBox(height: 10),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < visibleSettlements.length;
                              i++
                            ) ...[
                              CompactSettlementTile(
                                settlement: visibleSettlements[i],
                                users: users,
                                currencyCode: data.group.currencyCode,
                                locale: locale,
                                showDecimals: data.group.showDecimals,
                                onTap: () => showRecordSettlementSheet(
                                  context,
                                  groupId: widget.groupId,
                                  groupName: data.group.name,
                                  currencyCode: data.group.currencyCode,
                                  members: data.members,
                                  existing: visibleSettlements[i],
                                  analyticsSource: 'group_report',
                                ),
                              ),
                              if (i < visibleSettlements.length - 1 ||
                                  remainingSettlements > 0)
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                            ],
                            if (remainingSettlements > 0)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _settlementLimit += _kItemLimitStep;
                                  });
                                },
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.expand_more_rounded,
                                        size: 18,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.groupsReportShowMore(
                                          remainingSettlements,
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }(),
            ],
          ),
        );
      },
    );
  }
}
