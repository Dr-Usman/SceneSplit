import '../database/app_database.dart';

class SettlementModel {
  final String id;
  final String fromUser;
  final String toUser;
  final double amount;
  final String? groupId;
  final String? expenseId;
  final String? note;
  final DateTime date;
  final bool isSynced;
  final DateTime createdAt;

  const SettlementModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    this.groupId,
    this.expenseId,
    this.note,
    required this.date,
    this.isSynced = false,
    required this.createdAt,
  });

  SettlementModel copyWith({
    String? id,
    String? fromUser,
    String? toUser,
    double? amount,
    String? groupId,
    String? expenseId,
    String? note,
    DateTime? date,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return SettlementModel(
      id: id ?? this.id,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      amount: amount ?? this.amount,
      groupId: groupId ?? this.groupId,
      expenseId: expenseId ?? this.expenseId,
      note: note ?? this.note,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SettlementModel.fromRow(Settlement settlement) {
    return SettlementModel(
      id: settlement.id,
      fromUser: settlement.fromUser,
      toUser: settlement.toUser,
      amount: settlement.amount,
      groupId: settlement.groupId,
      expenseId: settlement.expenseId,
      note: settlement.note,
      date: settlement.date,
      isSynced: settlement.isSynced,
      createdAt: settlement.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user': fromUser,
      'to_user': toUser,
      'amount': amount,
      'group_id': groupId,
      'expense_id': expenseId,
      'note': note,
      'date': date.toIso8601String(),
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'] as String,
      fromUser: json['from_user'] as String,
      toUser: json['to_user'] as String,
      amount: (json['amount'] as num).toDouble(),
      groupId: json['group_id'] as String?,
      expenseId: json['expense_id'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
