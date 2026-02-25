import '../database/app_database.dart';
import '../models/login_history.dart';

class LoginHistoryRepository {
  final AppDatabase _database;
  LoginHistoryRepository(this._database);

  /// Records a new login event for a user.
  Future<void> recordLogin({
    required int userId,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    final db = await _database.db;
    await db.insert('login_history', {
      'user_id': userId,
      'login_time': DateTime.now().toIso8601String(),
      'device_info': deviceInfo,
      'ip_address': ipAddress,
    });
  }

  /// Returns the login history for a user, ordered by most recent first.
  /// Optionally limit the number of results.
  Future<List<LoginHistory>> getHistory(int userId, {int? limit}) async {
    final db = await _database.db;
    final rows = await db.query(
      'login_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'login_time DESC',
      limit: limit,
    );

    return rows.map((r) {
      return LoginHistory(
        id: r['id'] as int,
        userId: r['user_id'] as int,
        loginTime: DateTime.parse(r['login_time'] as String),
        deviceInfo: r['device_info'] as String?,
        ipAddress: r['ip_address'] as String?,
      );
    }).toList();
  }

  /// Returns the total login count for a user.
  Future<int> getTotalLoginCount(int userId) async {
    final db = await _database.db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM login_history WHERE user_id = ?',
      [userId],
    );
    return result.first['count'] as int;
  }

  /// Returns the last login time for a user (excluding current session).
  Future<DateTime?> getLastLoginTime(int userId) async {
    final db = await _database.db;
    final rows = await db.query(
      'login_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'login_time DESC',
      limit: 2, // Get 2 to skip current session
    );

    if (rows.length < 2) return null;
    return DateTime.parse(rows[1]['login_time'] as String);
  }

  /// Clears all login history for a user.
  Future<void> clearHistory(int userId) async {
    final db = await _database.db;
    await db.delete('login_history', where: 'user_id = ?', whereArgs: [userId]);
  }
}
