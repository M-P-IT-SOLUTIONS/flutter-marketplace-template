import 'package:flutter_test/flutter_test.dart';
import 'package:randki/models/app_user.dart';

void main() {
  group('AppUser', () {
    test('creates a user from JSON with fallback defaults', () {
      final user = AppUser.fromJson({
        'id': 'user-1',
        'email': 'alice@example.com',
        'nickname': 'Alice',
        'gender': 'female',
        'age_group': 'age_19_25',
        'friends': ['friend-1', 'friend-2'],
        'avatar_path': 'avatars/alice.png',
        'avatar_url': 'https://example.com/alice.png',
        'is_premium': true,
        'created_at': '2025-05-28T10:15:30.000Z',
      });

      expect(user.id, 'user-1');
      expect(user.email, 'alice@example.com');
      expect(user.nickname, 'Alice');
      expect(user.gender, Gender.female);
      expect(user.ageGroup, AgeGroup.age_19_25);
      expect(user.friends, ['friend-1', 'friend-2']);
      expect(user.avatarPath, 'avatars/alice.png');
      expect(user.avatarUrl, 'https://example.com/alice.png');
      expect(user.isPremium, isTrue);
      expect(
        user.createdAt,
        DateTime.parse('2025-05-28T10:15:30.000Z').toLocal(),
      );
    });

    test('falls back to safe defaults for unknown enum values', () {
      final user = AppUser.fromJson({
        'id': 'user-2',
        'email': 'bob@example.com',
        'gender': 'unknown',
        'age_group': 'unknown',
      });

      expect(user.gender, Gender.noAnswer);
      expect(user.ageGroup, AgeGroup.age_41Plus);
      expect(user.nickname, '');
      expect(user.friends, isEmpty);
      expect(user.isPremium, isFalse);
      expect(user.createdAt, isNull);
    });

    test('serializes to JSON using enum names and ISO timestamps', () {
      final createdAt = DateTime.parse('2025-01-01T09:30:00.000Z');
      final user = AppUser(
        id: 'user-3',
        email: 'carol@example.com',
        nickname: 'Carol',
        gender: Gender.other,
        ageGroup: AgeGroup.age_26_40,
        friends: const ['friend-1'],
        avatarPath: 'avatars/carol.png',
        avatarUrl: 'https://example.com/carol.png',
        isPremium: true,
        createdAt: createdAt,
      );

      expect(user.toJson(), {
        'id': 'user-3',
        'email': 'carol@example.com',
        'nickname': 'Carol',
        'gender': 'other',
        'age_group': 'age_26_40',
        'friends': ['friend-1'],
        'avatar_path': 'avatars/carol.png',
        'avatar_url': 'https://example.com/carol.png',
        'is_premium': true,
        'created_at': createdAt.toIso8601String(),
      });
    });

    test('copyWith updates selected fields only', () {
      const user = AppUser(
        id: 'user-4',
        email: 'dave@example.com',
        nickname: 'Dave',
        gender: Gender.male,
        ageGroup: AgeGroup.age_0_18,
        friends: ['friend-1'],
      );

      final updated = user.copyWith(nickname: 'David', isPremium: true);

      expect(updated.id, 'user-4');
      expect(updated.email, 'dave@example.com');
      expect(updated.nickname, 'David');
      expect(updated.gender, Gender.male);
      expect(updated.ageGroup, AgeGroup.age_0_18);
      expect(updated.friends, ['friend-1']);
      expect(updated.isPremium, isTrue);
    });
  });
}
