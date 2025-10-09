import 'package:hive/hive.dart';
part 'profile.g.dart';
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

  @HiveField(10)
  final int postCount;

  @HiveField(11)
  final int followersCount;

  @HiveField(12)
  final int followingCount;

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
    required this.postCount,
    required this.followersCount,
    required this.followingCount,
  });

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
          displayNameChangedAt == other.displayNameChangedAt &&
          postCount == other.postCount &&
          followersCount == other.followersCount &&
          followingCount == other.followingCount);

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
      displayNameChangedAt.hashCode ^
      postCount.hashCode ^
      followersCount.hashCode ^
      followingCount.hashCode;

  @override
  String toString() {
    return 'Profile{' +
        ' id: $id,' +
        ' username: $username,' +
        ' displayName: $displayName,' +
        ' avatarUrl: $avatarUrl,' +
        ' bio: $bio,' +
        ' isPublic: $isPublic,' +
        ' createdAt: $createdAt,' +
        ' updatedAt: $updatedAt,' +
        ' usernameChangedAt: $usernameChangedAt,' +
        ' displayNameChangedAt: $displayNameChangedAt,' +
        ' postCount: $postCount,' +
        ' followersCount: $followersCount,' +
        ' followingCount: $followingCount,' +
        '}';
  }

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
    int? postCount,
    int? followersCount,
    int? followingCount,
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
      postCount: postCount ?? this.postCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'username_changed_at': usernameChangedAt?.toIso8601String(),
      'displayname_changed_at': displayNameChangedAt?.toIso8601String(),
      'posts_count': postCount,
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.parse(v);
      return null;
    }

    return Profile(
      id: map['id'] as String,
      username: map['username'] as String,
      displayName: map['display_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      isPublic: (map['is_public'] is bool) ? map['is_public'] as bool : (map['is_public'] == 1),
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updated_at']) ?? DateTime.now(),
      usernameChangedAt: _parseDate(map['username_changed_at']),
      displayNameChangedAt: _parseDate(map['displayname_changed_at']),
      postCount: (map['posts_count'] as num?)?.toInt() ?? 0,
      followersCount: (map['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (map['following_count'] as num?)?.toInt() ?? 0,
    );
  }


  //</editor-fold>
}