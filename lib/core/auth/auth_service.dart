import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  static bool isLoggedIn = false;
  static AppUser? currentUser;

  static UserRepository _users = UserRepository(AppDatabase.instance);

  /// Allows tests to inject a mock [UserRepository] instead of the real DB one.
  @visibleForTesting
  static set usersRepositoryForTesting(UserRepository repo) => _users = repo;

  static Future<bool> register({
    required String name,
    required String university,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (password != confirmPassword) return false;
    if (name.trim().isEmpty || university.trim().isEmpty) return false;

    // no duplicates
    if (await _users.emailExists(cleanEmail)) return false;

    final user = await _users.register(
      name: name,
      university: university,
      email: cleanEmail,
      password: password,
    );

    currentUser = user;
    isLoggedIn = true;
    return true;
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    final user = await _users.login(cleanEmail, password);
    if (user == null) return false;

    currentUser = user;
    isLoggedIn = true;
    return true;
  }

  static Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final u = currentUser;
    if (u == null) return 'You are not logged in';

    if (newPassword.length < 4) return 'Minimum 4 characters';
    if (newPassword != confirmNewPassword) return 'Passwords do not match';

    final ok = await _users.changePassword(
      userId: u.id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (!ok) return 'Current password is incorrect';
    return null;
  }

  static Future<bool> updateProfile({
    required String name,
    required String email,
    required String university,
  }) async {
    if (currentUser == null) return false;

    final ok = await _users.updateProfile(
      userId: currentUser!.id,
      name: name,
      email: email,
      university: university,
    );

    if (!ok) return false;

    currentUser = currentUser!.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      university: university.trim(),
    );
    return true;
  }

  static void logout() {
    isLoggedIn = false;
    currentUser = null;
  }
}
