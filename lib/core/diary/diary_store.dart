import 'package:flutter/foundation.dart';

class DiaryEntry {
  final String id;
  final DateTime createdAt;
  final String title;
  final String content;

  const DiaryEntry({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.content,
  });
}

class DiaryStore {
  // in-memory store (mock)
  static final ValueNotifier<List<DiaryEntry>> entries =
  ValueNotifier<List<DiaryEntry>>([]);

  static void addEntry({
    required String title,
    required String content,
  }) {
    final now = DateTime.now();
    final entry = DiaryEntry(
      id: '${now.microsecondsSinceEpoch}',
      createdAt: now,
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      content: content.trim(),
    );

    entries.value = [entry, ...entries.value];
  }

  static void deleteEntry(String id) {
    entries.value = entries.value.where((e) => e.id != id).toList();
  }

  static void clear() {
    entries.value = [];
  }
}
