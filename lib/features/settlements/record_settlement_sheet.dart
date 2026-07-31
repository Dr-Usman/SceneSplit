import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/currencies.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/settlement_repository.dart';
import '../../services/balance_service.dart';

Future<void> showRecordSettlementSheet(
  BuildContext context, {
  required String groupId,
  required String currencyCode,
  required List<GroupMemberInfo> members,
  PairwiseDebt? prefill,
  Settlement? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RecordSettlementSheet(
      groupId: groupId,
      currencyCode: currencyCode,
      members: members,
      prefill: prefill,
      existing: existing,
    ),
  );
}

class _RecordSettlementSheet extends ConsumerStatefulWidget {
  const _RecordSettlementSheet({
    required this.groupId,
    required this.currencyCode,
    required this.members,
    this.prefill,
    this.existing,
  });

  final String groupId;
  final String currencyCode;
  final List<GroupMemberInfo> members;
  final PairwiseDebt? prefill;
  final Settlement? existing;

  @override
  ConsumerState<_RecordSettlementSheet> createState() =>
      _RecordSettlementSheetState();
}

class _RecordSettlementSheetState
    extends ConsumerState<_RecordSettlementSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _fromUserId;
  late String _toUserId;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _fromUserId = existing.fromUserId;
      _toUserId = existing.toUserId;
      _amountController.text = (existing.amountCents / 100).toStringAsFixed(
        existing.amountCents % 100 == 0 ? 0 : 2,
      );
      if (existing.note != null) {
        _noteController.text = existing.note!;
      }
    } else if (widget.prefill != null) {
      _fromUserId = widget.prefill!.fromUserId;
      _toUserId = widget.prefill!.toUserId;
      _amountController.text = (widget.prefill!.amountCents / 100)
          .toStringAsFixed(widget.prefill!.amountCents % 100 == 0 ? 0 : 2);
    } else {
      _fromUserId = widget.members.first.user.id;
      _toUserId = widget.members.length > 1
          ? widget.members[1].user.id
          : widget.members.first.user.id;
    }
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave {
    final cents = parseAmountToCents(_amountController.text);
    return cents != null && cents > 0 && _fromUserId != _toUserId && !_saving;
  }

  Future<void> _save() async {
    final cents = parseAmountToCents(_amountController.text);
    if (cents == null) return;

    setState(() => _saving = true);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final db = ref.read(databaseProvider);

    if (_isEditing) {
      await updateSettlement(
        db,
        settlementId: widget.existing!.id,
        fromUserId: _fromUserId,
        toUserId: _toUserId,
        amountCents: cents,
        note: note,
      );
    } else {
      await createSettlement(
        db,
        groupId: widget.groupId,
        fromUserId: _fromUserId,
        toUserId: _toUserId,
        amountCents: cents,
        note: note,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final symbol = currencyByCode(widget.currencyCode).symbol;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing
                    ? l10n.settlementsEditTitle
                    : l10n.settlementsRecordTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _label(l10n.settlementsFromPays),
              const SizedBox(height: 8),
              _userDropdown(
                value: _fromUserId,
                excludeId: _toUserId,
                onChanged: (v) => setState(() => _fromUserId = v!),
              ),
              const SizedBox(height: 16),
              _label(l10n.settlementsToReceives),
              const SizedBox(height: 8),
              _userDropdown(
                value: _toUserId,
                excludeId: _fromUserId,
                onChanged: (v) => setState(() => _toUserId = v!),
              ),
              const SizedBox(height: 16),
              _label(l10n.settlementsAmount),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: InputDecoration(prefixText: '$symbol '),
              ),
              const SizedBox(height: 16),
              _label(l10n.settlementsNoteOptional),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(hintText: l10n.settlementsNoteHint),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _canSave ? _save : null,
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
                        _isEditing
                            ? l10n.settlementsSaveChanges
                            : l10n.settlementsRecordPayment,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _userDropdown({
    required String value,
    required String excludeId,
    required ValueChanged<String?> onChanged,
  }) {
    final items = widget.members
        .where((m) => m.user.id != excludeId)
        .map(
          (m) => DropdownMenuItem(value: m.user.id, child: Text(m.user.name)),
        )
        .toList();

    return DropdownButtonFormField<String>(
      initialValue: items.any((i) => i.value == value)
          ? value
          : items.first.value,
      items: items,
      onChanged: onChanged,
      decoration: const InputDecoration(),
    );
  }
}
