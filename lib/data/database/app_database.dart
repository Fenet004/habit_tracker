import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if(_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'habit_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_repeat_days (
        habit_id INTEGER NOT NULL,
        weekday INTEGER NOT NULL,
        PRIMARY KEY (habit_id, weekday),
        FOREIGN KEY (habit_id)
          REFERENCES habits(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_completions (
        habit_id INTEGER NOT NULL,
        completed_date TEXT NOT NULL,
        PRIMARY KEY (habit_id, completed_date),
        FOREIGN KEY (habit_id)
          REFERENCES habits(id)
          ON DELETE CASCADE
      )
    ''');
  }
}