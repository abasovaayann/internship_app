import 'package:flutter_test/flutter_test.dart';
import 'package:internship_app/database/app_database.dart';
import 'package:internship_app/repositories/user_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens a fresh in-memory SQLite DB with the same schema as [AppDatabase].
Future<AppDatabase> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // We create our own DB with an identical schema
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

  // Inject the raw DB into a new AppDatabase wrapper via the test helper
  final appDb = AppDatabase.forTesting(rawDb);
  return appDb;
}

void main() {
  late AppDatabase db;
  late UserRepository repo;

  setUp(() async {
    db = await _openTestDb();
    repo = UserRepository(db);
  });

  tearDown(() async {
    final raw = await db.db;
    await raw.close();
  });

  // ─── emailExists ─────────────────────────────────────────────

  group('UserRepository.emailExists', () {
    test('returns false for a new email', () async {
      expect(await repo.emailExists('new@test.com'), isFalse);
    });

    test('returns true after a user is registered', () async {
      await repo.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass',
      );
      expect(await repo.emailExists('alice@test.com'), isTrue);
    });

    test('is case-insensitive', () async {
      await repo.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass',
      );
      expect(await repo.emailExists('ALICE@TEST.COM'), isTrue);
    });
  });

  // ─── register ────────────────────────────────────────────────

  group('UserRepository.register', () {
    test('returns an AppUser with the correct fields', () async {
      final user = await repo.register(
        name: '  Alice  ',
        university: '  MIT  ',
        email: 'Alice@Test.COM',
        password: 'secret',
      );

      expect(user.id, greaterThan(0));
      expect(user.name, 'Alice');
      expect(user.university, 'MIT');
      expect(user.email, 'alice@test.com'); // trimmed + lowercased
    });
  });

  // ─── login ───────────────────────────────────────────────────

  group('UserRepository.login', () {
    setUp(() async {
      await repo.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass123',
      );
    });

    test('returns AppUser for correct credentials', () async {
      final user = await repo.login('alice@test.com', 'pass123');
      expect(user, isNotNull);
      expect(user!.name, 'Alice');
    });

    test('returns null for wrong password', () async {
      final user = await repo.login('alice@test.com', 'wrongpass');
      expect(user, isNull);
    });

    test('returns null for unknown email', () async {
      final user = await repo.login('nobody@test.com', 'pass123');
      expect(user, isNull);
    });

    test('is case-insensitive on email', () async {
      final user = await repo.login('ALICE@TEST.COM', 'pass123');
      expect(user, isNotNull);
    });
  });

  // ─── changePassword ──────────────────────────────────────────

  group('UserRepository.changePassword', () {
    late int userId;

    setUp(() async {
      final user = await repo.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'oldpass',
      );
      userId = user.id;
    });

    test('succeeds with correct current password', () async {
      final ok = await repo.changePassword(
        userId: userId,
        currentPassword: 'oldpass',
        newPassword: 'newpass',
      );
      expect(ok, isTrue);
      // Verify new password works for login
      final user = await repo.login('alice@test.com', 'newpass');
      expect(user, isNotNull);
    });

    test('fails with wrong current password', () async {
      final ok = await repo.changePassword(
        userId: userId,
        currentPassword: 'wrongpass',
        newPassword: 'newpass',
      );
      expect(ok, isFalse);
    });
  });

  // ─── updateProfile ───────────────────────────────────────────

  group('UserRepository.updateProfile', () {
    late int userId;

    setUp(() async {
      final user = await repo.register(
        name: 'Alice',
        university: 'MIT',
        email: 'alice@test.com',
        password: 'pass',
      );
      userId = user.id;
    });

    test('updates name, email, and university', () async {
      final ok = await repo.updateProfile(
        userId: userId,
        name: 'Alice Updated',
        email: 'newalice@test.com',
        university: 'Stanford',
      );
      expect(ok, isTrue);

      // New email should be found
      expect(await repo.emailExists('newalice@test.com'), isTrue);
    });

    test('fails if the new email is already taken by another user', () async {
      // register a second user
      await repo.register(
        name: 'Bob',
        university: 'Harvard',
        email: 'bob@test.com',
        password: 'pass',
      );

      // Alice tries to steal Bob's email
      final ok = await repo.updateProfile(
        userId: userId,
        name: 'Alice',
        email: 'bob@test.com',
        university: 'MIT',
      );
      expect(ok, isFalse);
    });

    test('allows keeping the same email (no conflict with self)', () async {
      final ok = await repo.updateProfile(
        userId: userId,
        name: 'Alice Renamed',
        email: 'alice@test.com', // same email, same user
        university: 'MIT',
      );
      expect(ok, isTrue);
    });
  });
}
