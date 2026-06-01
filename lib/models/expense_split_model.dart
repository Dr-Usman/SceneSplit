import '../database/app_database.dart';

class ExpenseSplitModel {
  final String id;
  final String expenseId;
  final String userId;
  final double amount;
  final double? percentage;
  final bool isSynced;
  final DateTime createdAt;

  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amount,
    this.percentage,
    this.isSynced = false,
    required this.createdAt,
  });

  ExpenseSplitModel copyWith({
    String? id,
    String? expenseId,
    String? userId,
    double? amount,
    double? percentage,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return ExpenseSplitModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ExpenseSplitModel.fromRow(ExpenseSplit split) {
    return ExpenseSplitModel(
      id: split.id,
      expenseId: split.expenseId,
      userId: split.userId,
      amount: split.amount,
      percentage: split.percentage,
      isSynced: split.isSynced,
      createdAt: split.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'amount': amount,
      'percentage': percentage,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      isSynced: json['is_synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
