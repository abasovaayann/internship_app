import 'package:flutter_test/flutter_test.dart';
import 'package:internship_app/core/models/user_model.dart';

void main() {
  group('AppUser', () {
    const user = AppUser(
      id: 1,
      name: 'Alice',
      email: 'alice@test.com',
      university: 'MIT',
    );

    test('copyWith — no changes returns identical values', () {
      final copy = user.copyWith();
      expect(copy.id, 1);
      expect(copy.name, 'Alice');
      expect(copy.email, 'alice@test.com');
      expect(copy.university, 'MIT');
    });

    test('copyWith — overrides only specified fields', () {
      final copy = user.copyWith(name: 'Bob', email: 'bob@test.com');
      expect(copy.name, 'Bob');
      expect(copy.email, 'bob@test.com');
      expect(copy.id, 1); // unchanged
      expect(copy.university, 'MIT'); // unchanged
    });

    test('copyWith — full override', () {
      final copy = user.copyWith(
        id: 99,
        name: 'Charlie',
        email: 'charlie@example.com',
        university: 'Stanford',
      );
      expect(copy.id, 99);
      expect(copy.name, 'Charlie');
      expect(copy.email, 'charlie@example.com');
      expect(copy.university, 'Stanford');
    });
  });
}
