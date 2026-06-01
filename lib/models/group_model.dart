import '../core/enums/group_type.dart';
import '../database/app_database.dart';
import 'user_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final GroupType type;
  final String? avatarUrl;
  final List<UserModel> members;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.type = GroupType.custom,
    this.avatarUrl,
    this.members = const [],
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    GroupType? type,
    String? avatarUrl,
    List<UserModel>? members,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      members: members ?? this.members,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GroupModel.fromRow(Group group, {List<UserModel>? members}) {
    return GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      type: GroupType.values.byName(group.type),
      avatarUrl: group.avatarUrl,
      members: members ?? [],
      isSynced: group.isSynced,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'avatar_url': avatarUrl,
      'members': members.map((m) => m.toJson()).toList(),
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: GroupType.values.byName(json['type'] as String),
      avatarUrl: json['avatar_url'] as String?,
      members:
          (json['members'] as List?)
              ?.map((m) => UserModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      isSynced: json['is_synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  int get memberCount => members.length;
}
