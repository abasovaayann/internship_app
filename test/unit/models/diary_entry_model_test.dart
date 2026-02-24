import 'package:flutter_test/flutter_test.dart';
import 'package:internship_app/core/models/diary_entry_model.dart';

void main() {
  group('DiaryEntryModel', () {
    final now = DateTime(2025, 6, 1, 12, 30);

    test('stores all fields correctly', () {
      final entry = DiaryEntryModel(
        id: 42,
        userId: 7,
        title: 'Test Entry',
        content: 'Some content',
        createdAt: now,
      );

      expect(entry.id, 42);
      expect(entry.userId, 7);
      expect(entry.title, 'Test Entry');
      expect(entry.content, 'Some content');
      expect(entry.createdAt, now);
    });

    test('createdAt preserves the exact DateTime', () {
      final dt = DateTime(2024, 1, 15, 8, 0, 0);
      final entry = DiaryEntryModel(
        id: 1,
        userId: 1,
        title: 'x',
        content: 'y',
        createdAt: dt,
      );
      expect(entry.createdAt.year, 2024);
      expect(entry.createdAt.month, 1);
      expect(entry.createdAt.day, 15);
    });
  });
}
