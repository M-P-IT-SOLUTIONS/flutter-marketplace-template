enum Gender { female, male, other, noAnswer }

enum AgeGroup { age_0_18, age_19_25, age_26_40, age_41Plus }

/// Domain user profile model (public.users), separated from Supabase Auth User.
class AppUser {
  final String id;
  final String email;
  final String nickname;
  final Gender gender;
  final AgeGroup ageGroup;
  final List<String> friends;
  final String? avatarPath; // path in Supabase Storage
  final String? avatarUrl; // public URL (optional cache)
  final bool isPremium; // premium account status
  final DateTime? createdAt; // record creation date (users.created_at)

  const AppUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.gender,
    required this.ageGroup,
    required this.friends,
    this.avatarPath,
    this.avatarUrl,
    this.isPremium = false,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: (json['nickname'] ?? '') as String,
      gender: _genderFromString(json['gender'] as String?),
      ageGroup: _ageGroupFromString(json['age_group'] as String?),
      friends: (json['friends'] as List<dynamic>? ?? []).cast<String>(),
      avatarPath: json['avatar_path'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isPremium: (json['is_premium'] as bool?) ?? false,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'gender': gender.name,
      'age_group': ageGroup.name,
      'friends': friends,
      'avatar_path': avatarPath,
      'avatar_url': avatarUrl,
      'is_premium': isPremium,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? nickname,
    Gender? gender,
    AgeGroup? ageGroup,
    List<String>? friends,
    String? avatarPath,
    String? avatarUrl,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      friends: friends ?? this.friends,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Gender _genderFromString(String? value) {
    switch (value) {
      case 'female':
        return Gender.female;
      case 'male':
        return Gender.male;
      case 'other':
        return Gender.other;
      default:
        return Gender.noAnswer;
    }
  }

  static AgeGroup _ageGroupFromString(String? value) {
    switch (value) {
      case 'age_0_18':
        return AgeGroup.age_0_18;
      case 'age_19_25':
        return AgeGroup.age_19_25;
      case 'age_26_40':
        return AgeGroup.age_26_40;
      default:
        return AgeGroup.age_41Plus;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
