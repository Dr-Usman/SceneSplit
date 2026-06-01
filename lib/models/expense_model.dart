import '../core/enums/split_type.dart';
import '../database/app_database.dart';
import 'expense_split_model.dart';

class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final String currency;
  final String paidBy;
  final String? groupId;
  final SplitType splitType;
  final DateTime date;
  final List<ExpenseSplitModel> splits;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    this.currency = 'USD',
    required this.paidBy,
    this.groupId,
    this.splitType = SplitType.equal,
    required this.date,
    this.splits = const [],
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ExpenseModel copyWith({
    String? id,
    String? description,
    double? amount,
    String? currency,
    String? paidBy,
    String? groupId,
    SplitType? splitType,
    DateTime? date,
    List<ExpenseSplitModel>? splits,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paidBy: paidBy ?? this.paidBy,
      groupId: groupId ?? this.groupId,
      splitType: splitType ?? this.splitType,
      date: date ?? this.date,
      splits: splits ?? this.splits,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ExpenseModel.fromRow(
    Expense expense, {
    List<ExpenseSplitModel>? splits,
  }) {
    return ExpenseModel(
      id: expense.id,
      description: expense.description,
      amount: expense.amount,
      currency: expense.currency,
      paidBy: expense.paidBy,
      groupId: expense.groupId,
      splitType: SplitType.values.byName(expense.splitType),
      date: expense.date,
      splits: splits ?? [],
      isSynced: expense.isSynced,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'currency': currency,
      'paid_by': paidBy,
      'group_id': groupId,
      'split_type': splitType.name,
      'date': date.toIso8601String(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      paidBy: json['paid_by'] as String,
      groupId: json['group_id'] as String?,
      splitType: SplitType.values.byName(json['split_type'] as String),
      date: DateTime.parse(json['date'] as String),
      splits:
          (json['splits'] as List?)
              ?.map(
                (s) => ExpenseSplitModel.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isSynced: json['is_synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
