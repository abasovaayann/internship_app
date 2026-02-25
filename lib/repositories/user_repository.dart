import '../database/app_database.dart';
import '../models/app_user.dart';

class UserRepository {
  final AppDatabase _database;
  UserRepository(this._database);

  Future<bool> emailExists(String email) async {
    final db = await _database.db;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'LOWER(email) = LOWER(?)',
      whereArgs: [email.trim()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<AppUser?> login(String email, String password) async {
    final db = await _database.db;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = LOWER(?) AND password = ?',
      whereArgs: [email.trim(), password],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final r = rows.first;
    return AppUser(
      id: r['id'] as int,
      name: r['name'] as String,
      university: r['university'] as String,
      email: r['email'] as String,
    );
  }

  Future<AppUser> register({
    required String name,
    required String university,
    required String email,
    required String password,
  }) async {
    final db = await _database.db;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert('users', {
      'name': name.trim(),
      'university': university.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'created_at': now,
    });

    return AppUser(
      id: id,
      name: name.trim(),
      university: university.trim(),
      email: email.trim().toLowerCase(),
    );
  }

  Future<bool> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await _database.db;

    // verify current password
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'id = ? AND password = ?',
      whereArgs: [userId, currentPassword],
      limit: 1,
    );

    if (rows.isEmpty) return false;

    // update
    final count = await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return count == 1;
  }

  Future<bool> updateProfile({
    required int userId,
    required String name,
    required String email,
    required String university,
  }) async {
    final db = await _database.db;

    // if email changes, ensure it's not taken by another user
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'LOWER(email) = LOWER(?) AND id != ?',
      whereArgs: [email.trim(), userId],
      limit: 1,
    );
    if (rows.isNotEmpty) return false;

    final count = await db.update(
      'users',
      {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'university': university.trim(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    return count == 1;
  }
}
