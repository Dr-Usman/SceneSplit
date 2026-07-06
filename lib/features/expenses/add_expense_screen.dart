import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/currencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../services/split_engine_service.dart';
import '../../shared/widgets/user_avatar.dart';

enum SplitType { equal, exact, percentage }

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
  String? _paidById;
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
    super.dispose();
  }

  void _initMembers(List<GroupMemberInfo> members) {
    if (_initialized) return;
    _initialized = true;

    for (final m in members) {
      _exactControllers[m.user.id] = TextEditingController();
      _percentControllers[m.user.id] = TextEditingController();
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
      _paidById = e.paidById;
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
      return;
    }

    final me = ref.read(currentUserProvider).value;
    _paidById = me != null && members.any((m) => m.user.id == me.id)
        ? me.id
        : members.first.user.id;
    _participants.addAll(members.map((m) => m.user.id));
    for (final m in members) {
      _percentControllers[m.user.id]?.text = members.length == 1 ? '100' : '';
    }
  }

  int? get _amountCents => parseAmountToCents(_amountController.text);

  bool get _isValid {
    if (_amountCents == null || _amountCents! <= 0) return false;
    if (_titleController.text.trim().isEmpty) return false;
    if (_paidById == null) return false;
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
        return pcts != null && SplitEngineService.percentageSplitsValid(pcts);
    }
  }

  Map<String, int>? _parseExact() {
    final result = <String, int>{};
    for (final e in _exactControllers.entries) {
      final cents = parseAmountToCents(e.value.text);
      if (cents == null || cents <= 0) continue;
      result[e.key] = cents;
    }
    return result.isEmpty ? null : result;
  }

  Map<String, double>? _parsePercentages() {
    final result = <String, double>{};
    for (final e in _percentControllers.entries) {
      final text = e.value.text.trim();
      if (text.isEmpty) continue;
      final val = double.tryParse(text);
      if (val == null || val <= 0) continue;
      result[e.key] = val;
    }
    return result.isEmpty ? null : result;
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

  Future<void> _save() async {
    final splits = _buildSplits();
    if (splits == null || _paidById == null) return;

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
        paidById: _paidById!,
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
        paidById: _paidById!,
        splitType: _splitType.name,
        splitsCents: splits,
        note: note,
        date: _date,
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

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(groupDetailProvider(widget.groupId));
    final symbol = currencyByCode(widget.currencyCode).symbol;

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (data) {
        _initMembers(data.members);
        final members = data.members;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isEditing ? 'Edit expense' : 'Add expense'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel('AMOUNT'),
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
              _sectionLabel('DESCRIPTION'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Dinner, Groceries, Taxi',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _sectionLabel('DATE'),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat.yMMMd().format(_date)),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('PAID BY'),
              const SizedBox(height: 8),
              ...members.map(
                (m) => _PaidByTile(
                  user: m.user,
                  selected: _paidById == m.user.id,
                  onTap: () => setState(() => _paidById = m.user.id),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('SPLIT'),
              const SizedBox(height: 8),
              SegmentedButton<SplitType>(
                segments: const [
                  ButtonSegment(value: SplitType.equal, label: Text('Equal')),
                  ButtonSegment(value: SplitType.exact, label: Text('Exact')),
                  ButtonSegment(value: SplitType.percentage, label: Text('%')),
                ],
                selected: {_splitType},
                onSelectionChanged: (s) => setState(() => _splitType = s.first),
              ),
              const SizedBox(height: 16),
              ..._buildSplitSection(members, symbol),
              const SizedBox(height: 20),
              _sectionLabel('NOTE (OPTIONAL)'),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Add a note'),
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
                    : Text(widget.isEditing ? 'Save changes' : 'Save expense'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSplitSection(
    List<GroupMemberInfo> members,
    String symbol,
  ) {
    switch (_splitType) {
      case SplitType.equal:
        return members
            .map(
              (m) => CheckboxListTile(
                value: _participants.contains(m.user.id),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _participants.add(m.user.id);
                  } else {
                    _participants.remove(m.user.id);
                  }
                }),
                title: Text(m.user.name),
                secondary: UserAvatar(
                  name: m.user.name,
                  colorIndex: m.user.colorIndex,
                  size: 36,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList();

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
          if (_amountCents != null) _splitSummary(symbol),
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
          if (_amountCents != null) _splitSummary(symbol),
        ];
    }
  }

  Widget _splitSummary(String symbol) {
    final splits = _buildSplits();
    if (splits == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Enter valid split amounts',
          style: TextStyle(color: AppColors.negative, fontSize: 13),
        ),
      );
    }
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
                '${userMap[e.key] ?? '?'}: $symbol ${(e.value / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          Divider(height: 16, color: Theme.of(context).dividerTheme.color),
          Text(
            'Total: $symbol ${(total / 100).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PaidByTile extends StatelessWidget {
  const _PaidByTile({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  final User user;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              UserAvatar(
                name: user.name,
                colorIndex: user.colorIndex,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
