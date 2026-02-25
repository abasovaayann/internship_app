import 'package:flutter_test/flutter_test.dart';
import 'package:internship_app/services/auth_service.dart';
import 'package:internship_app/models/app_user.dart';
import 'package:internship_app/repositories/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockRepo;

  const fakeUser = AppUser(
    id: 1,
    name: 'Alice',
    email: 'alice@test.com',
    university: 'MIT',
  );

  setUp(() {
    mockRepo = MockUserRepository();
    // Inject mock into AuthService
    AuthService.usersRepositoryForTesting = mockRepo;
    // Reset state between tests
    AuthService.logout();
  });

  // ─── register ───────────────────────────────────────────────

  group('AuthService.register', () {
    test('returns false when passwords do not match', () async {
      final result = await AuthService.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass1',
        confirmPassword: 'pass2',
      );
      expect(result, isFalse);
      verifyZeroInteractions(mockRepo);
    });

    test('returns false when name is empty', () async {
      final result = await AuthService.register(
        name: '',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass1',
        confirmPassword: 'pass1',
      );
      expect(result, isFalse);
      verifyZeroInteractions(mockRepo);
    });

    test('returns false when university is empty', () async {
      final result = await AuthService.register(
        name: 'Alice',
        university: '   ',
        email: 'alice@test.com',
        password: 'pass1',
        confirmPassword: 'pass1',
      );
      expect(result, isFalse);
      verifyZeroInteractions(mockRepo);
    });

    test('returns false when email already exists', () async {
      when(mockRepo.emailExists(any)).thenAnswer((_) async => true);

      final result = await AuthService.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass1',
        confirmPassword: 'pass1',
      );
      expect(result, isFalse);
    });

    test('returns true and sets currentUser on success', () async {
      when(mockRepo.emailExists(any)).thenAnswer((_) async => false);
      when(
        mockRepo.register(
          name: anyNamed('name'),
          university: anyNamed('university'),
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => fakeUser);

      final result = await AuthService.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass1',
        confirmPassword: 'pass1',
      );

      expect(result, isTrue);
      expect(AuthService.isLoggedIn, isTrue);
      expect(AuthService.currentUser, equals(fakeUser));
    });
  });

  // ─── login ──────────────────────────────────────────────────

  group('AuthService.login', () {
    test('sets isLoggedIn and currentUser on success', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async => fakeUser);

      final result = await AuthService.login(
        email: 'alice@test.com',
        password: 'pass1',
      );

      expect(result, isTrue);
      expect(AuthService.isLoggedIn, isTrue);
      expect(AuthService.currentUser?.name, 'Alice');
    });

    test('returns false for invalid credentials', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async => null);

      final result = await AuthService.login(
        email: 'wrong@test.com',
        password: 'wrongpass',
      );

      expect(result, isFalse);
      expect(AuthService.isLoggedIn, isFalse);
    });
  });

  // ─── logout ─────────────────────────────────────────────────

  group('AuthService.logout', () {
    test('clears isLoggedIn and currentUser', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async => fakeUser);
      await AuthService.login(email: 'alice@test.com', password: 'pass1');
      expect(AuthService.isLoggedIn, isTrue);

      AuthService.logout();

      expect(AuthService.isLoggedIn, isFalse);
      expect(AuthService.currentUser, isNull);
    });
  });

  // ─── changePassword ─────────────────────────────────────────

  group('AuthService.changePassword', () {
    test('returns error message when not logged in', () async {
      AuthService.logout();
      final err = await AuthService.changePassword(
        currentPassword: 'old',
        newPassword: 'newpass',
        confirmNewPassword: 'newpass',
      );
      expect(err, isNotNull);
      expect(err, contains('not logged in'));
    });

    test('returns error when new password is too short', () async {
      // Simulate logged-in state
      when(mockRepo.login(any, any)).thenAnswer((_) async => fakeUser);
      await AuthService.login(email: 'alice@test.com', password: 'pass1');

      final err = await AuthService.changePassword(
        currentPassword: 'pass1',
        newPassword: 'ab',
        confirmNewPassword: 'ab',
      );
      expect(err, isNotNull);
      expect(err, contains('4'));
    });

    test('returns error when new passwords do not match', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async => fakeUser);
      await AuthService.login(email: 'alice@test.com', password: 'pass1');

      final err = await AuthService.changePassword(
        currentPassword: 'pass1',
        newPassword: 'newpass',
        confirmNewPassword: 'different',
      );
      expect(err, isNotNull);
      expect(err, contains('match'));
    });

    test('returns null on success', () async {
      when(mockRepo.login(any, any)).thenAnswer((_) async => fakeUser);
      await AuthService.login(email: 'alice@test.com', password: 'pass1');

      when(
        mockRepo.changePassword(
          userId: anyNamed('userId'),
          currentPassword: anyNamed('currentPassword'),
          newPassword: anyNamed('newPassword'),
        ),
      ).thenAnswer((_) async => true);

      final err = await AuthService.changePassword(
        currentPassword: 'pass1',
        newPassword: 'newpass',
        confirmNewPassword: 'newpass',
      );
      expect(err, isNull);
    });
  });
}
