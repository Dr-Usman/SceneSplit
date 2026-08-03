import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/currencies.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../services/split_engine_service.dart';
import '../../shared/widgets/member_select_tile.dart';
import '../../shared/widgets/user_avatar.dart';

enum SplitType { equal, exact, percentage }

enum PaidByMode { single, multiple }

enum PayerAmountMode { equal, exact }

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.groupId,
    required this.currencyCode,
    this.existing,
  });

  final String groupId;
  final String currencyCode;
  final ExpenseWithSplits? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  SplitType _splitType = SplitType.equal;
  PaidByMode _paidByMode = PaidByMode.single;
  PayerAmountMode _payerAmountMode = PayerAmountMode.exact;
  String? _paidById;
  final _payerIds = <String>{};
  final _payerExactControllers = <String, TextEditingController>{};
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _initialized = false;

  /// Equal split: which members participate.
  final _participants = <String>{};

  /// Exact / percentage per-member values (as text).
  final _exactControllers = <String, TextEditingController>{};
  final _percentControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    for (final c in _exactControllers.values) {
      c.dispose();
    }
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    for (final c in _payerExactControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initMembers(List<GroupMemberInfo> members) {
    if (_initialized) return;
    _initialized = true;

    for (final m in members) {
      _exactControllers[m.user.id] = TextEditingController();
      _percentControllers[m.user.id] = TextEditingController();
      _payerExactControllers[m.user.id] = TextEditingController();
    }

    final existing = widget.existing;
    if (existing != null) {
      final e = existing.expense;
      _amountController.text = e.amountCents % 100 == 0
          ? (e.amountCents ~/ 100).toString()
          : (e.amountCents / 100).toStringAsFixed(2);
      _titleController.text = e.title;
      _noteController.text = e.note ?? '';
      _date = e.date;
      _splitType = SplitType.values.firstWhere(
        (t) => t.name == e.splitType,
        orElse: () => SplitType.equal,
      );
      _participants.addAll(existing.splits.map((s) => s.userId));

      for (final s in existing.splits) {
        _exactControllers[s.userId]?.text = s.amountCents % 100 == 0
            ? (s.amountCents ~/ 100).toString()
            : (s.amountCents / 100).toStringAsFixed(2);
        final pct = e.amountCents > 0
            ? (s.amountCents / e.amountCents * 100).toStringAsFixed(1)
            : '';
        _percentControllers[s.userId]?.text = pct;
      }

      final payers = existing.payers;
      if (payers.length <= 1) {
        _paidByMode = PaidByMode.single;
        _paidById = payers.isNotEmpty
            ? payers.first.userId
            : members.first.user.id;
        _payerIds.add(_paidById!);
      } else {
        _paidByMode = PaidByMode.multiple;
        _payerAmountMode = PayerAmountMode.exact;
        for (final p in payers) {
          _payerIds.add(p.userId);
          _payerExactControllers[p.userId]?.text = p.amountCents % 100 == 0
              ? (p.amountCents ~/ 100).toString()
              : (p.amountCents / 100).toStringAsFixed(2);
        }
        _paidById = payers.first.userId;
      }
      return;
    }

    final me = ref.read(currentUserProvider).value;
    _paidById = me != null && members.any((m) => m.user.id == me.id)
        ? me.id
        : members.first.user.id;
    _payerIds.add(_paidById!);
    _participants.addAll(members.map((m) => m.user.id));
    for (final m in members) {
      _percentControllers[m.user.id]?.text = members.length == 1 ? '100' : '';
    }
  }

  int? get _amountCents => parseAmountToCents(_amountController.text);

  bool get _payersValid {
    final payers = _buildPayers();
    if (payers == null || payers.isEmpty || _amountCents == null) return false;
    return SplitEngineService.exactSplitsValid(_amountCents!, payers);
  }

  bool get _isValid {
    if (_amountCents == null || _amountCents! <= 0) return false;
    if (_titleController.text.trim().isEmpty) return false;
    if (!_payersValid) return false;
    if (_saving) return false;

    switch (_splitType) {
      case SplitType.equal:
        return _participants.isNotEmpty;
      case SplitType.exact:
        final amounts = _parseExact();
        return amounts != null &&
            SplitEngineService.exactSplitsValid(_amountCents!, amounts);
      case SplitType.percentage:
        final pcts = _parsePercentages();
        return pcts != null &&
            SplitEngineService.percentageSplitsWithinLimits(pcts) &&
            SplitEngineService.percentageSplitsValid(pcts);
    }
  }

  Map<String, int>? _parseExact() {
    final total = _amountCents;
    final result = <String, int>{};
    for (final e in _exactControllers.entries) {
      final cents = parseAmountToCents(e.value.text);
      if (cents == null || cents <= 0) continue;
      if (total != null && cents > total) return null;
      result[e.key] = cents;
    }
    return result.isEmpty ? null : result;
  }

  Map<String, int>? _parsePayerExact() {
    final total = _amountCents;
    final result = <String, int>{};
    for (final id in _payerIds) {
      final cents = parseAmountToCents(_payerExactControllers[id]?.text ?? '');
      if (cents == null || cents <= 0) continue;
      if (total != null && cents > total) return null;
      result[id] = cents;
    }
    return result.isEmpty ? null : result;
  }

  Map<String, double>? _parsePercentages() {
    final result = <String, double>{};
    for (final e in _percentControllers.entries) {
      final text = e.value.text.trim();
      if (text.isEmpty) continue;
      final val = double.tryParse(text);
      if (val == null || val <= 0 || val > 100) continue;
      result[e.key] = val;
    }
    return result.isEmpty ? null : result;
  }

  bool _hasExactFieldOverTotal() {
    final total = _amountCents;
    if (total == null) return false;
    for (final c in _exactControllers.values) {
      final cents = parseAmountToCents(c.text);
      if (cents != null && cents > total) return true;
    }
    return false;
  }

  bool _hasPayerExactFieldOverTotal() {
    final total = _amountCents;
    if (total == null) return false;
    for (final id in _payerIds) {
      final cents = parseAmountToCents(_payerExactControllers[id]?.text ?? '');
      if (cents != null && cents > total) return true;
    }
    return false;
  }

  bool _hasPercentFieldOver100() {
    for (final c in _percentControllers.values) {
      final text = c.text.trim();
      if (text.isEmpty) continue;
      final val = double.tryParse(text);
      if (val != null && val > 100) return true;
    }
    return false;
  }

  Map<String, int>? _buildSplits() {
    final total = _amountCents;
    if (total == null) return null;

    switch (_splitType) {
      case SplitType.equal:
        return SplitEngineService.equalSplit(total, _participants.toList());
      case SplitType.exact:
        final amounts = _parseExact();
        if (amounts == null) return null;
        return SplitEngineService.exactSplit(amounts);
      case SplitType.percentage:
        final pcts = _parsePercentages();
        if (pcts == null) return null;
        return SplitEngineService.percentageSplit(total, pcts);
    }
  }

  Map<String, int>? _buildPayers() {
    final total = _amountCents;
    if (total == null) return null;

    if (_paidByMode == PaidByMode.single) {
      if (_paidById == null) return null;
      return {_paidById!: total};
    }

    if (_payerIds.isEmpty) return null;

    switch (_payerAmountMode) {
      case PayerAmountMode.equal:
        return SplitEngineService.equalSplit(total, _payerIds.toList());
      case PayerAmountMode.exact:
        final amounts = _parsePayerExact();
        if (amounts == null) return null;
        return SplitEngineService.exactSplit(amounts);
    }
  }

  Future<void> _save() async {
    final splits = _buildSplits();
    final payers = _buildPayers();
    if (splits == null || payers == null) return;

    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (widget.isEditing) {
      await updateExpense(
        db,
        expenseId: widget.existing!.expense.id,
        title: _titleController.text.trim(),
        amountCents: _amountCents!,
        payersCents: payers,
        splitType: _splitType.name,
        splitsCents: splits,
        note: note,
        date: _date,
      );
    } else {
      await createExpense(
        db,
        groupId: widget.groupId,
        title: _titleController.text.trim(),
        amountCents: _amountCents!,
        payersCents: payers,
        splitType: _splitType.name,
        splitsCents: splits,
        note: note,
        date: _date,
      );
      final groupName =
          ref.read(groupDetailProvider(widget.groupId)).value?.group.name ?? '';
      await ref
          .read(analyticsServiceProvider)
          .trackExpenseCreated(
            groupId: widget.groupId,
            groupName: groupName,
            splitType: _splitType.name,
            paidByMode: _paidByMode.name,
            amountCents: _amountCents!,
            memberCount: splits.length,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _setPaidByMode(PaidByMode mode) {
    setState(() {
      _paidByMode = mode;
      if (mode == PaidByMode.single) {
        _paidById ??= _payerIds.isNotEmpty ? _payerIds.first : null;
        if (_paidById != null) {
          _payerIds
            ..clear()
            ..add(_paidById!);
        }
      } else {
        _payerAmountMode = PayerAmountMode.exact;
        if (_payerIds.isEmpty && _paidById != null) {
          _payerIds.add(_paidById!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(groupDetailProvider(widget.groupId));
    final symbol = currencyByCode(widget.currencyCode).symbol;

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.commonErrorWithDetail('$e'))),
      ),
      data: (data) {
        _initMembers(data.members);
        final members = data.members;
        final l10n = context.l10n;
        final locale = Localizations.localeOf(context).toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditing ? l10n.expensesEditTitle : l10n.expensesAddTitle,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel(
                l10n.expensesAmount,
                subtitle: l10n.expensesAmountSubtitle,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                decoration: InputDecoration(
                  prefixText: '$symbol ',
                  prefixStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                  hintText: '0',
                ),
                autofocus: !widget.isEditing,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _sectionLabel(l10n.expensesDescription),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.expensesDescriptionHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _sectionLabel(l10n.expensesDate),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat.yMMMd(locale).format(_date)),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel(
                l10n.expensesPaidBy,
                subtitle: l10n.expensesPaidBySubtitle,
              ),
              const SizedBox(height: 8),
              SegmentedButton<PaidByMode>(
                segments: [
                  ButtonSegment(
                    value: PaidByMode.single,
                    label: Text(l10n.expensesPayerSingle),
                  ),
                  ButtonSegment(
                    value: PaidByMode.multiple,
                    label: Text(l10n.expensesPayerMultiple),
                  ),
                ],
                selected: {_paidByMode},
                onSelectionChanged: (s) => _setPaidByMode(s.first),
              ),
              const SizedBox(height: 12),
              ..._buildPaidBySection(
                members,
                widget.currencyCode,
                Localizations.localeOf(context).toString(),
                context.l10n,
              ),
              const SizedBox(height: 20),
              _sectionLabel(
                l10n.expensesSplit,
                subtitle: l10n.expensesSplitSubtitle,
              ),
              const SizedBox(height: 8),
              SegmentedButton<SplitType>(
                segments: [
                  ButtonSegment(
                    value: SplitType.equal,
                    label: Text(l10n.expensesSplitEqual),
                  ),
                  ButtonSegment(
                    value: SplitType.exact,
                    label: Text(l10n.expensesSplitExact),
                  ),
                  ButtonSegment(
                    value: SplitType.percentage,
                    label: Text(l10n.expensesSplitPercent),
                  ),
                ],
                selected: {_splitType},
                onSelectionChanged: (s) => setState(() => _splitType = s.first),
              ),
              const SizedBox(height: 16),
              ..._buildSplitSection(members, widget.currencyCode, locale, l10n),
              const SizedBox(height: 20),
              _sectionLabel(l10n.expensesNote),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l10n.expensesNoteHint),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isValid ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? l10n.expensesSaveChanges
                            : l10n.expensesSaveExpense,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPaidBySection(
    List<GroupMemberInfo> members,
    String currencyCode,
    String locale,
    AppLocalizations l10n,
  ) {
    if (_paidByMode == PaidByMode.single) {
      return [
        for (final m in members)
          MemberSelectTile(
            user: m.user,
            selected: _paidById == m.user.id,
            onTap: () => setState(() {
              _paidById = m.user.id;
              _payerIds
                ..clear()
                ..add(m.user.id);
            }),
          ),
      ];
    }

    return [
      for (final m in members)
        MemberSelectTile(
          user: m.user,
          selected: _payerIds.contains(m.user.id),
          multiSelect: true,
          onTap: () => setState(() {
            if (_payerIds.contains(m.user.id)) {
              _payerIds.remove(m.user.id);
            } else {
              _payerIds.add(m.user.id);
            }
          }),
        ),
      if (_payerIds.isNotEmpty) ...[
        const SizedBox(height: 8),
        SegmentedButton<PayerAmountMode>(
          segments: [
            ButtonSegment(
              value: PayerAmountMode.equal,
              label: Text(context.l10n.expensesSplitEqual),
            ),
            ButtonSegment(
              value: PayerAmountMode.exact,
              label: Text(context.l10n.expensesSplitExact),
            ),
          ],
          selected: {_payerAmountMode},
          onSelectionChanged: (s) => setState(() => _payerAmountMode = s.first),
        ),
        const SizedBox(height: 12),
        ..._buildPayerAmountSection(
          members,
          widget.currencyCode,
          Localizations.localeOf(context).toString(),
          context.l10n,
        ),
      ],
    ];
  }

  List<Widget> _buildPayerAmountSection(
    List<GroupMemberInfo> members,
    String currencyCode,
    String locale,
    AppLocalizations l10n,
  ) {
    final symbol = currencyByCode(currencyCode).symbol;
    final selected = members.where((m) => _payerIds.contains(m.user.id));

    switch (_payerAmountMode) {
      case PayerAmountMode.equal:
        final total = _amountCents;
        final amounts = total == null
            ? null
            : SplitEngineService.equalSplit(total, _payerIds.toList());
        return [
          for (final m in selected) ...[
            Row(
              children: [
                UserAvatar(
                  name: m.user.name,
                  colorIndex: m.user.colorIndex,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  amounts == null
                      ? '—'
                      : formatCents(
                          amounts[m.user.id]!,
                          currencyCode,
                          locale: locale,
                        ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ];

      case PayerAmountMode.exact:
        return [
          for (final m in selected) ...[
            Row(
              children: [
                UserAvatar(
                  name: m.user.name,
                  colorIndex: m.user.colorIndex,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _payerExactControllers[m.user.id],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    decoration: InputDecoration(
                      prefixText: '$symbol ',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_amountCents != null)
            _payerExactSummary(currencyCode, locale, l10n, _amountCents!),
        ];
    }
  }

  Widget _payerExactSummary(
    String currencyCode,
    String locale,
    AppLocalizations l10n,
    int amountCents,
  ) {
    if (_hasPayerExactFieldOverTotal()) {
      return _splitStatusMessage(
        l10n.expensesPaymentExceeds(
          formatCents(amountCents, currencyCode, locale: locale),
        ),
        isError: true,
      );
    }

    final amounts = _parsePayerExact();
    if (amounts == null) {
      return _splitStatusMessage(
        l10n.expensesEnterValidPayments,
        isError: true,
      );
    }

    final assigned = SplitEngineService.exactSplitAssignedCents(amounts);
    if (assigned > amountCents) {
      final over = assigned - amountCents;
      return _splitStatusMessage(
        l10n.expensesOverBy(formatCents(over, currencyCode, locale: locale)),
        isError: true,
      );
    }
    if (assigned < amountCents) {
      final remaining = amountCents - assigned;
      return _splitStatusMessage(
        l10n.expensesAmountRemaining(
          formatCents(remaining, currencyCode, locale: locale),
        ),
        isWarning: true,
      );
    }

    return _splitStatusMessage(
      l10n.expensesPaymentsTotal(
        formatCents(amountCents, currencyCode, locale: locale),
      ),
    );
  }

  List<Widget> _buildSplitSection(
    List<GroupMemberInfo> members,
    String currencyCode,
    String locale,
    AppLocalizations l10n,
  ) {
    final symbol = currencyByCode(currencyCode).symbol;
    switch (_splitType) {
      case SplitType.equal:
        return [
          for (final m in members)
            MemberSelectTile(
              user: m.user,
              selected: _participants.contains(m.user.id),
              multiSelect: true,
              onTap: () => setState(() {
                if (_participants.contains(m.user.id)) {
                  _participants.remove(m.user.id);
                } else {
                  _participants.add(m.user.id);
                }
              }),
            ),
        ];

      case SplitType.exact:
        return [
          for (final m in members) ...[
            Row(
              children: [
                UserAvatar(
                  name: m.user.name,
                  colorIndex: m.user.colorIndex,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _exactControllers[m.user.id],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    decoration: InputDecoration(
                      prefixText: '$symbol ',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_amountCents != null) _splitSummary(currencyCode, locale, l10n),
        ];

      case SplitType.percentage:
        return [
          for (final m in members) ...[
            Row(
              children: [
                UserAvatar(
                  name: m.user.name,
                  colorIndex: m.user.colorIndex,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _percentControllers[m.user.id],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      suffixText: '%',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_amountCents != null) _splitSummary(currencyCode, locale, l10n),
        ];
    }
  }

  Widget _splitSummary(
    String currencyCode,
    String locale,
    AppLocalizations l10n,
  ) {
    final amountCents = _amountCents;
    if (amountCents == null) return const SizedBox.shrink();

    switch (_splitType) {
      case SplitType.equal:
        return const SizedBox.shrink();
      case SplitType.exact:
        return _exactSplitSummary(currencyCode, locale, l10n, amountCents);
      case SplitType.percentage:
        return _percentageSplitSummary(currencyCode, locale, l10n, amountCents);
    }
  }

  Widget _exactSplitSummary(
    String currencyCode,
    String locale,
    AppLocalizations l10n,
    int amountCents,
  ) {
    if (_hasExactFieldOverTotal()) {
      return _splitStatusMessage(
        l10n.expensesShareExceeds(
          formatCents(amountCents, currencyCode, locale: locale),
        ),
        isError: true,
      );
    }

    final amounts = _parseExact();
    if (amounts == null) {
      return _splitStatusMessage(l10n.expensesEnterValidSplits, isError: true);
    }

    final assigned = SplitEngineService.exactSplitAssignedCents(amounts);
    if (assigned > amountCents) {
      final over = assigned - amountCents;
      return _splitStatusMessage(
        l10n.expensesOverBy(formatCents(over, currencyCode, locale: locale)),
        isError: true,
      );
    }
    if (assigned < amountCents) {
      final remaining = amountCents - assigned;
      return _splitStatusMessage(
        l10n.expensesAmountRemaining(
          formatCents(remaining, currencyCode, locale: locale),
        ),
        isWarning: true,
      );
    }

    return _splitBreakdown(
      currencyCode,
      locale,
      l10n,
      SplitEngineService.exactSplit(amounts),
    );
  }

  Widget _percentageSplitSummary(
    String currencyCode,
    String locale,
    AppLocalizations l10n,
    int amountCents,
  ) {
    if (_hasPercentFieldOver100()) {
      return _splitStatusMessage(l10n.expensesPercentOver100, isError: true);
    }

    final pcts = _parsePercentages();
    if (pcts == null) {
      return _splitStatusMessage(
        l10n.expensesEnterValidPercents,
        isError: true,
      );
    }

    final total = SplitEngineService.percentageSplitTotal(pcts);
    if (total > 100.01) {
      final over = total - 100;
      return _splitStatusMessage(
        l10n.expensesPercentReduce(
          total.toStringAsFixed(1),
          over.toStringAsFixed(1),
        ),
        isError: true,
      );
    }
    if (total < 99.99) {
      final remaining = 100 - total;
      return _splitStatusMessage(
        l10n.expensesPercentRemaining(
          total.toStringAsFixed(1),
          remaining.toStringAsFixed(1),
        ),
        isWarning: true,
      );
    }

    return _splitBreakdown(
      currencyCode,
      locale,
      l10n,
      SplitEngineService.percentageSplit(amountCents, pcts),
    );
  }

  Widget _splitStatusMessage(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    final color = isError
        ? AppColors.negative
        : isWarning
        ? AppColors.textSecondary
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _splitBreakdown(
    String currencyCode,
    String locale,
    AppLocalizations l10n,
    Map<String, int> splits,
  ) {
    final total = splits.values.fold(0, (a, b) => a + b);
    final members =
        ref.read(groupDetailProvider(widget.groupId)).value?.members ?? [];
    final userMap = {for (final m in members) m.user.id: m.user.name};

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in splits.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                l10n.expensesPayerLine(
                  userMap[e.key] ?? '?',
                  formatCents(e.value, currencyCode, locale: locale),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          Divider(height: 16, color: Theme.of(context).dividerTheme.color),
          Text(
            l10n.expensesPreviewTotal(
              formatCents(total, currencyCode, locale: locale),
            ),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {String? subtitle}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
