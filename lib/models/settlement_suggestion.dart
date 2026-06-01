class SettlementSuggestion {
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String? groupId;

  const SettlementSuggestion({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.groupId,
  });

  SettlementSuggestion copyWith({
    String? fromUserId,
    String? toUserId,
    double? amount,
    String? groupId,
  }) {
    return SettlementSuggestion(
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      amount: amount ?? this.amount,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  String toString() {
    return 'SettlementSuggestion(from: $fromUserId, to: $toUserId, amount: $amount)';
  }
}
