import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/split_type.dart';
import '../models/expense_split_model.dart';
import 'database_provider.dart';

part 'add_expense_provider.g.dart';

@riverpod
class AddExpenseForm extends _$AddExpenseForm {
  @override
  AddExpenseFormState build() {
    return AddExpenseFormState();
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
    _recalculateSplits();
  }

  void setPayerId(String userId) {
    state = state.copyWith(payerId: userId);
  }

  void setGroupId(String? groupId) {
    state = state.copyWith(groupId: groupId);
  }

  void setSplitType(SplitType splitType) {
    state = state.copyWith(splitType: splitType);
    _recalculateSplits();
  }

  void toggleParticipant(String userId) {
    final current = List<String>.from(state.selectedParticipantIds);
    if (current.contains(userId)) {
      current.remove(userId);
    } else {
      current.add(userId);
    }
    state = state.copyWith(selectedParticipantIds: current);
    _recalculateSplits();
  }

  void selectAllParticipants(List<String> userIds) {
    state = state.copyWith(selectedParticipantIds: userIds);
    _recalculateSplits();
  }

  void setExactAmount(String userId, double amount) {
    final amounts = Map<String, double>.from(state.exactAmounts);
    amounts[userId] = amount;
    state = state.copyWith(exactAmounts: amounts);
  }

  void setPercentage(String userId, double percentage) {
    final percentages = Map<String, double>.from(state.percentages);
    percentages[userId] = percentage;
    state = state.copyWith(percentages: percentages);
  }

  void _recalculateSplits() {
    if (state.splitType == SplitType.equal &&
        state.selectedParticipantIds.isNotEmpty) {
      final equalAmount = state.amount / state.selectedParticipantIds.length;
      state = state.copyWith(equalAmount: equalAmount);
    }
  }

  bool get isValid {
    return state.description.isNotEmpty &&
        state.amount > 0 &&
        state.payerId != null &&
        state.selectedParticipantIds.isNotEmpty &&
        _validateSplitAmounts();
  }

  bool _validateSplitAmounts() {
    switch (state.splitType) {
      case SplitType.equal:
        return true;
      case SplitType.exact:
        final total = state.exactAmounts.values.fold(0.0, (sum, a) => sum + a);
        return (total - state.amount).abs() < 0.01;
      case SplitType.percentage:
        final total = state.percentages.values.fold(0.0, (sum, p) => sum + p);
        return (total - 100).abs() < 0.01;
    }
  }

  List<ExpenseSplitModel> buildSplits(String expenseId) {
    final splitEngine = ref.read(splitEngineServiceProvider);
    return splitEngine.calculateSplits(
      expenseId: expenseId,
      totalAmount: state.amount,
      splitType: state.splitType,
      participantIds: state.selectedParticipantIds,
      exactAmounts: state.splitType == SplitType.exact
          ? state.exactAmounts
          : null,
      percentages: state.splitType == SplitType.percentage
          ? state.percentages
          : null,
    );
  }

  void reset() {
    state = AddExpenseFormState();
  }
}

class AddExpenseFormState {
  final String description;
  final double amount;
  final String? payerId;
  final String? groupId;
  final SplitType splitType;
  final List<String> selectedParticipantIds;
  final Map<String, double> exactAmounts;
  final Map<String, double> percentages;
  final double equalAmount;

  const AddExpenseFormState({
    this.description = '',
    this.amount = 0.0,
    this.payerId,
    this.groupId,
    this.splitType = SplitType.equal,
    this.selectedParticipantIds = const [],
    this.exactAmounts = const {},
    this.percentages = const {},
    this.equalAmount = 0.0,
  });

  AddExpenseFormState copyWith({
    String? description,
    double? amount,
    String? payerId,
    String? groupId,
    SplitType? splitType,
    List<String>? selectedParticipantIds,
    Map<String, double>? exactAmounts,
    Map<String, double>? percentages,
    double? equalAmount,
  }) {
    return AddExpenseFormState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      payerId: payerId ?? this.payerId,
      groupId: groupId ?? this.groupId,
      splitType: splitType ?? this.splitType,
      selectedParticipantIds:
          selectedParticipantIds ?? this.selectedParticipantIds,
      exactAmounts: exactAmounts ?? this.exactAmounts,
      percentages: percentages ?? this.percentages,
      equalAmount: equalAmount ?? this.equalAmount,
    );
  }

  String get equalSplitDisplay {
    if (selectedParticipantIds.isEmpty) return '\$0.00';
    return '\${(amount / selectedParticipantIds.length).toStringAsFixed(2)}';
  }

  bool get isValid {
    return description.isNotEmpty &&
        amount > 0 &&
        payerId != null &&
        selectedParticipantIds.isNotEmpty;
  }
}
