class CheckIn {
  final int id;
  final int userId;
  final double moodLevel;
  final double sleepQuality;
  final double energyLevel;
  final DateTime date;

  const CheckIn({
    required this.id,
    required this.userId,
    required this.moodLevel,
    required this.sleepQuality,
    required this.energyLevel,
    required this.date,
  });

  /// Returns the date portion only (no time), for comparison
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  CheckIn copyWith({
    int? id,
    int? userId,
    double? moodLevel,
    double? sleepQuality,
    double? energyLevel,
    DateTime? date,
  }) {
    return CheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodLevel: moodLevel ?? this.moodLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      energyLevel: energyLevel ?? this.energyLevel,
      date: date ?? this.date,
    );
  }
}
