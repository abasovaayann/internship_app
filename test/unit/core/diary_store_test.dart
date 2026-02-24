import 'package:flutter_test/flutter_test.dart';
import 'package:internship_app/core/diary/diary_store.dart';

void main() {
  setUp(() {
    // Reset the in-memory store before every test
    DiaryStore.clear();
  });

  group('DiaryStore.addEntry', () {
    test('adds an entry with the given title and content', () {
      DiaryStore.addEntry(title: 'My Day', content: 'Felt great!');

      expect(DiaryStore.entries.value.length, 1);
      final entry = DiaryStore.entries.value.first;
      expect(entry.title, 'My Day');
      expect(entry.content, 'Felt great!');
    });

    test('uses "Untitled" when title is empty', () {
      DiaryStore.addEntry(title: '', content: 'Just venting.');

      final entry = DiaryStore.entries.value.first;
      expect(entry.title, 'Untitled');
    });

    test('uses "Untitled" when title is whitespace only', () {
      DiaryStore.addEntry(title: '   ', content: 'Hello');

      final entry = DiaryStore.entries.value.first;
      expect(entry.title, 'Untitled');
    });

    test('prepends — newest entry is first', () {
      DiaryStore.addEntry(title: 'First', content: 'a');
      DiaryStore.addEntry(title: 'Second', content: 'b');

      expect(DiaryStore.entries.value.first.title, 'Second');
      expect(DiaryStore.entries.value.last.title, 'First');
    });

    test('generates a unique id per entry', () async {
      DiaryStore.addEntry(title: 'A', content: 'x');
      // Small delay so microsecondsSinceEpoch differs between the two entries
      await Future.delayed(const Duration(milliseconds: 1));
      DiaryStore.addEntry(title: 'B', content: 'y');

      final ids = DiaryStore.entries.value.map((e) => e.id).toList();
      expect(ids.toSet().length, 2); // all unique
    });
  });

  group('DiaryStore.deleteEntry', () {
    test('removes the entry with the given id', () async {
      DiaryStore.addEntry(title: 'Keep', content: 'stays');
      await Future.delayed(const Duration(milliseconds: 1));
      DiaryStore.addEntry(title: 'Remove', content: 'goes');

      final idToRemove = DiaryStore.entries.value
          .firstWhere((e) => e.title == 'Remove')
          .id;

      DiaryStore.deleteEntry(idToRemove);

      expect(DiaryStore.entries.value.length, 1);
      expect(DiaryStore.entries.value.first.title, 'Keep');
    });

    test('does nothing for a non-existent id', () {
      DiaryStore.addEntry(title: 'Entry', content: 'content');
      DiaryStore.deleteEntry('nonexistent-id');
      expect(DiaryStore.entries.value.length, 1);
    });
  });

  group('DiaryStore.clear', () {
    test('empties all entries', () {
      DiaryStore.addEntry(title: 'A', content: 'a');
      DiaryStore.addEntry(title: 'B', content: 'b');
      DiaryStore.clear();
      expect(DiaryStore.entries.value, isEmpty);
    });

    test('calling clear on an already-empty store is safe', () {
      DiaryStore.clear();
      expect(DiaryStore.entries.value, isEmpty);
    });
  });
}
