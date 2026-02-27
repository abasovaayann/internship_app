import '../database/app_database.dart';
import '../models/activity_stats.dart';
import '../models/diary_entry.dart';

class DiaryRepository {
  final AppDatabase _database;
  DiaryRepository(this._database);

  Future<List<DiaryEntry>> listByUser(int userId) async {
    final db = await _database.db;
    final rows = await db.query(
      'diary_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return rows.map((r) {
      return DiaryEntry(
        id: r['id'] as int,
        userId: r['user_id'] as int,
        title: r['title'] as String,
        content: r['content'] as String,
        createdAt: DateTime.parse(r['created_at'] as String),
      );
    }).toList();
  }

  Future<void> add({
    required int userId,
    required String title,
    required String content,
  }) async {
    final db = await _database.db;
    await db.insert('diary_entries', {
      'user_id': userId,
      'title': title.trim().isEmpty ? 'Untitled' : title.trim(),
      'content': content.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> delete(int id) async {
    final db = await _database.db;
    await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update({
    required int id,
    required String title,
    required String content,
  }) async {
    final db = await _database.db;
    await db.update(
      'diary_entries',
      {
        'title': title.trim().isEmpty ? 'Untitled' : title.trim(),
        'content': content.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calculates activity statistics for a user's diary entries.
  Future<ActivityStats> getActivityStats(int userId) async {
    final entries = await listByUser(userId);

    if (entries.isEmpty) {
      return ActivityStats.empty;
    }

    // Count entries by day of week (1=Monday ... 7=Sunday in Dart, convert to 0-6)
    final dayOfWeekCounts = <int, int>{};
    final hourCounts = <int, int>{};

    for (final entry in entries) {
      // weekday: 1=Monday, 7=Sunday -> convert to 0=Monday, 6=Sunday
      final dayIndex = entry.createdAt.weekday - 1;
      dayOfWeekCounts[dayIndex] = (dayOfWeekCounts[dayIndex] ?? 0) + 1;

      final hour = entry.createdAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Find most active day
    int? mostActiveDay;
    int maxDayCount = 0;
    dayOfWeekCounts.forEach((day, count) {
      if (count > maxDayCount) {
        maxDayCount = count;
        mostActiveDay = day;
      }
    });

    // Find most active hour
    int? mostActiveHour;
    int maxHourCount = 0;
    hourCounts.forEach((hour, count) {
      if (count > maxHourCount) {
        maxHourCount = count;
        mostActiveHour = hour;
      }
    });

    // Calculate streaks
    final streaks = _calculateStreaks(entries);

    return ActivityStats(
      entriesByDayOfWeek: dayOfWeekCounts,
      entriesByHour: hourCounts,
      totalEntries: entries.length,
      mostActiveDay: mostActiveDay,
      mostActiveHour: mostActiveHour,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
    );
  }

  /// Helper to calculate current and longest writing streaks.
  ({int current, int longest}) _calculateStreaks(List<DiaryEntry> entries) {
    if (entries.isEmpty) return (current: 0, longest: 0);

    // Get unique dates (normalized to start of day)
    final dates =
        entries
            .map(
              (e) => DateTime(
                e.createdAt.year,
                e.createdAt.month,
                e.createdAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Most recent first

    if (dates.isEmpty) return (current: 0, longest: 0);

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterday = todayNormalized.subtract(const Duration(days: 1));

    // Calculate current streak
    int currentStreak = 0;
    DateTime? expectedDate =
        dates.first == todayNormalized || dates.first == yesterday
        ? dates.first
        : null;

    if (expectedDate != null) {
      for (final date in dates) {
        if (expectedDate != null && date == expectedDate) {
          currentStreak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(expectedDate ?? DateTime.now())) {
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 1;
    int tempStreak = 1;
    final sortedDatesAsc = dates.reversed.toList();

    for (int i = 1; i < sortedDatesAsc.length; i++) {
      final diff = sortedDatesAsc[i].difference(sortedDatesAsc[i - 1]).inDays;
      if (diff == 1) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else if (diff > 1) {
        tempStreak = 1;
      }
    }

    return (current: currentStreak, longest: longestStreak);
  }
}
