import 'package:flutter_test/flutter_test.dart';
import 'package:internship_app/core/database/app_database.dart';
import 'package:internship_app/core/repositories/diary_repository.dart';
import 'package:internship_app/core/repositories/user_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<AppDatabase> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final rawDb = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            university TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            created_at TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE diary_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          );
        ''');
      },
    ),
  );

  return AppDatabase.forTesting(rawDb);
}

void main() {
  late AppDatabase db;
  late DiaryRepository repo;
  late int userId;

  setUp(() async {
    db = await _openTestDb();
    repo = DiaryRepository(db);

    // Create a test user so we have a valid userId
    final userRepo = UserRepository(db);
    final user = await userRepo.register(
      name: 'Test User',
      university: 'Test Uni',
      email: 'test@uni.com',
      password: 'pass',
    );
    userId = user.id;
  });

  tearDown(() async {
    final raw = await db.db;
    await raw.close();
  });

  // ─── add + listByUser ─────────────────────────────────────────

  group('DiaryRepository.add + listByUser', () {
    test('adds an entry and retrieves it', () async {
      await repo.add(userId: userId, title: 'Day 1', content: 'Good day');

      final entries = await repo.listByUser(userId);
      expect(entries.length, 1);
      expect(entries.first.title, 'Day 1');
      expect(entries.first.content, 'Good day');
      expect(entries.first.userId, userId);
    });

    test('stores "Untitled" when title is empty', () async {
      await repo.add(userId: userId, title: '', content: 'No title content');

      final entries = await repo.listByUser(userId);
      expect(entries.first.title, 'Untitled');
    });

    test('returns entries in descending order (newest first)', () async {
      await repo.add(userId: userId, title: 'First', content: 'a');
      // small delay to ensure different timestamp
      await Future.delayed(const Duration(milliseconds: 5));
      await repo.add(userId: userId, title: 'Second', content: 'b');

      final entries = await repo.listByUser(userId);
      expect(entries.first.title, 'Second');
      expect(entries.last.title, 'First');
    });

    test('returns empty list for a user with no entries', () async {
      final entries = await repo.listByUser(userId);
      expect(entries, isEmpty);
    });

    test(
      'respects userId isolation — different users see only their entries',
      () async {
        // Create a second user
        final userRepo = UserRepository(db);
        final user2 = await userRepo.register(
          name: 'User 2',
          university: 'Uni 2',
          email: 'user2@test.com',
          password: 'pass',
        );

        await repo.add(userId: userId, title: 'User1 Entry', content: 'x');
        await repo.add(userId: user2.id, title: 'User2 Entry', content: 'y');

        final user1Entries = await repo.listByUser(userId);
        final user2Entries = await repo.listByUser(user2.id);

        expect(user1Entries.length, 1);
        expect(user1Entries.first.title, 'User1 Entry');
        expect(user2Entries.length, 1);
        expect(user2Entries.first.title, 'User2 Entry');
      },
    );
  });

  // ─── delete ───────────────────────────────────────────────────

  group('DiaryRepository.delete', () {
    test('removes the specified entry', () async {
      await repo.add(userId: userId, title: 'Keep', content: 'stays');
      await repo.add(userId: userId, title: 'Delete Me', content: 'goes');

      final before = await repo.listByUser(userId);
      final idToDelete = before.firstWhere((e) => e.title == 'Delete Me').id;

      await repo.delete(idToDelete);

      final after = await repo.listByUser(userId);
      expect(after.length, 1);
      expect(after.first.title, 'Keep');
    });

    test('deleting all entries leaves an empty list', () async {
      await repo.add(userId: userId, title: 'Only', content: 'one');
      final entries = await repo.listByUser(userId);
      await repo.delete(entries.first.id);
      expect(await repo.listByUser(userId), isEmpty);
    });
  });
}
