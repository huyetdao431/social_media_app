import 'package:hive/hive.dart';
part 'profiles.g.dart';
@HiveType(typeId: 0)
class Profile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final String? bio;

  @HiveField(5)
  final bool isPublic;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final DateTime? usernameChangedAt;

  @HiveField(9)
  final DateTime? displayNameChangedAt;

  //<editor-fold desc="Data Methods">
  const Profile({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.usernameChangedAt,
    this.displayNameChangedAt,
  });

  Profile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? usernameChangedAt,
    DateTime? displayNameChangedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usernameChangedAt: usernameChangedAt ?? this.usernameChangedAt,
      displayNameChangedAt: displayNameChangedAt ?? this.displayNameChangedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_public': isPublic,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'username_changed_at': usernameChangedAt?.toUtc().toIso8601String(),
      'displayname_changed_at': displayNameChangedAt?.toUtc().toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    DateTime _parse(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      return DateTime.parse(v as String).toLocal();
    }

    DateTime? _parseNullable(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.parse(v as String).toLocal();
    }

    return Profile(
      id: map['id'] as String,
      username: map['username'] as String? ?? '',
      displayName: map['display_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      isPublic: map['is_public'] as bool? ?? true,
      createdAt: _parse(map['created_at']),
      updatedAt: _parse(map['updated_at']),
      usernameChangedAt: _parseNullable(map['username_changed_at']),
      displayNameChangedAt: _parseNullable(map['displayname_changed_at']),
    );
  }

  @override
  String toString() {
    return 'Profile{id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt, usernameChangedAt: $usernameChangedAt, displayNameChangedAt: $displayNameChangedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Profile &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              username == other.username &&
              displayName == other.displayName &&
              avatarUrl == other.avatarUrl &&
              bio == other.bio &&
              isPublic == other.isPublic &&
              createdAt == other.createdAt &&
              updatedAt == other.updatedAt &&
              usernameChangedAt == other.usernameChangedAt &&
              displayNameChangedAt == other.displayNameChangedAt);

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      displayName.hashCode ^
      avatarUrl.hashCode ^
      bio.hashCode ^
      isPublic.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      usernameChangedAt.hashCode ^
      displayNameChangedAt.hashCode;
  //</editor-fold>
}