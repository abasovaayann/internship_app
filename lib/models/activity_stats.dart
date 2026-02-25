/// Represents activity statistics for diary entries analysis.
class ActivityStats {
  /// Entry counts by day of week (0 = Monday, 6 = Sunday)
  final Map<int, int> entriesByDayOfWeek;

  /// Entry counts by hour of day (0-23)
  final Map<int, int> entriesByHour;

  /// Total number of entries analyzed
  final int totalEntries;

  /// Most active day of week (0-6)
  final int? mostActiveDay;

  /// Most active hour (0-23)
  final int? mostActiveHour;

  /// Current writing streak (consecutive days)
  final int currentStreak;

  /// Longest writing streak ever
  final int longestStreak;

  const ActivityStats({
    required this.entriesByDayOfWeek,
    required this.entriesByHour,
    required this.totalEntries,
    this.mostActiveDay,
    this.mostActiveHour,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  /// Returns human-readable day name for a day index
  static String dayName(int dayIndex) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dayIndex % 7];
  }

  /// Returns shortened day name
  static String dayNameShort(int dayIndex) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayIndex % 7];
  }

  /// Returns human-readable time period for an hour
  static String hourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  /// Returns time period description (Morning, Afternoon, Evening, Night)
  static String timePeriod(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  /// Get description of most active day
  String? get mostActiveDayDescription {
    if (mostActiveDay == null) return null;
    final count = entriesByDayOfWeek[mostActiveDay] ?? 0;
    return '${dayName(mostActiveDay!)} ($count entries)';
  }

  /// Get description of most active time
  String? get mostActiveTimeDescription {
    if (mostActiveHour == null) return null;
    final count = entriesByHour[mostActiveHour] ?? 0;
    return '${timePeriod(mostActiveHour!)} - ${hourLabel(mostActiveHour!)} ($count entries)';
  }

  /// Empty stats for when there's no data
  static const empty = ActivityStats(
    entriesByDayOfWeek: {},
    entriesByHour: {},
    totalEntries: 0,
  );
}
