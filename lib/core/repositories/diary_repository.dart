import '../database/app_database.dart';
import '../models/diary_entry_model.dart';

class DiaryRepository {
  final AppDatabase _database;
  DiaryRepository(this._database);

  Future<List<DiaryEntryModel>> listByUser(int userId) async {
    final db = await _database.db;
    final rows = await db.query(
      'diary_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return rows.map((r) {
      return DiaryEntryModel(
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
}
