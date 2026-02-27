import '../database/app_database.dart';
import '../models/check_in.dart';

class CheckInRepository {
  final AppDatabase _database;
  CheckInRepository(this._database);

  /// Gets the check-in for a specific date, or null if none exists.
  Future<CheckIn?> getByDate(int userId, DateTime date) async {
    final db = await _database.db;
    final dateStr = _dateToString(date);

    final rows = await db.query(
      'check_ins',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return _rowToCheckIn(rows.first);
  }

  /// Gets today's check-in for the user, or null if none exists.
  Future<CheckIn?> getToday(int userId) async {
    return getByDate(userId, DateTime.now());
  }

  /// Saves a check-in. If one exists for the same date, it updates it.
  /// Otherwise, it creates a new one.
  Future<CheckIn> save({
    required int userId,
    required double moodLevel,
    required double sleepQuality,
    required double energyLevel,
    DateTime? date,
  }) async {
    final db = await _database.db;
    final checkInDate = date ?? DateTime.now();
    final dateStr = _dateToString(checkInDate);

    // Check if entry exists for this date
    final existing = await getByDate(userId, checkInDate);

    if (existing != null) {
      // Update existing
      await db.update(
        'check_ins',
        {
          'mood_level': moodLevel,
          'sleep_quality': sleepQuality,
          'energy_level': energyLevel,
        },
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return existing.copyWith(
        moodLevel: moodLevel,
        sleepQuality: sleepQuality,
        energyLevel: energyLevel,
      );
    } else {
      // Insert new
      final id = await db.insert('check_ins', {
        'user_id': userId,
        'mood_level': moodLevel,
        'sleep_quality': sleepQuality,
        'energy_level': energyLevel,
        'date': dateStr,
      });
      return CheckIn(
        id: id,
        userId: userId,
        moodLevel: moodLevel,
        sleepQuality: sleepQuality,
        energyLevel: energyLevel,
        date: checkInDate,
      );
    }
  }

  /// Gets the last N check-ins for a user (for trends).
  Future<List<CheckIn>> getRecent(int userId, {int limit = 7}) async {
    final db = await _database.db;
    final rows = await db.query(
      'check_ins',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );

    return rows.map(_rowToCheckIn).toList();
  }

  /// Gets check-ins for the last 7 days (for weekly trends).
  /// Returns a map of weekday (1=Monday to 7=Sunday) to mood level.
  Future<Map<int, double>> getWeeklyMoodTrend(int userId) async {
    final db = await _database.db;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final weekAgoStr = _dateToString(weekAgo);

    final rows = await db.query(
      'check_ins',
      where: 'user_id = ? AND date >= ?',
      whereArgs: [userId, weekAgoStr],
      orderBy: 'date ASC',
    );

    final trend = <int, double>{};
    for (final row in rows) {
      final date = DateTime.parse(row['date'] as String);
      trend[date.weekday] = row['mood_level'] as double;
    }
    return trend;
  }

  CheckIn _rowToCheckIn(Map<String, Object?> row) {
    return CheckIn(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      moodLevel: row['mood_level'] as double,
      sleepQuality: row['sleep_quality'] as double,
      energyLevel: row['energy_level'] as double,
      date: DateTime.parse(row['date'] as String),
    );
  }

  String _dateToString(DateTime date) {
    // Store only date part (YYYY-MM-DD)
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
