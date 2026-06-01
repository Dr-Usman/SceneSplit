class BalanceModel {
  final String userId;
  final String otherUserId;
  final double amount;
  final String? groupId;

  const BalanceModel({
    required this.userId,
    required this.otherUserId,
    required this.amount,
    this.groupId,
  });

  /// Positive = user is owed money, Negative = user owes money
  bool get isOwed => amount > 0;
  bool get isOwing => amount < 0;
  double get absoluteAmount => amount.abs();

  BalanceModel copyWith({
    String? userId,
    String? otherUserId,
    double? amount,
    String? groupId,
  }) {
    return BalanceModel(
      userId: userId ?? this.userId,
      otherUserId: otherUserId ?? this.otherUserId,
      amount: amount ?? this.amount,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  String toString() {
    return 'BalanceModel(userId: $userId, otherUserId: $otherUserId, amount: $amount)';
  }
}
