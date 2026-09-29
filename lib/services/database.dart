import 'package:sqflite/sqflite.dart';

import '../models/goal.dart';

/// قاعدة بيانات SQLite: جداول goals و steps و settings.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  static Future<AppDatabase> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      '$dir/masar.db',
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE steps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id TEXT NOT NULL,
            position INTEGER NOT NULL,
            title TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX idx_steps_goal ON steps (goal_id, position)');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
    return AppDatabase._(db);
  }

  // ---------------- الإعدادات ----------------

  Future<Map<String, String>> loadSettings() async {
    final rows = await _db.query('settings');
    return {
      for (final r in rows) r['key'] as String: (r['value'] as String?) ?? '',
    };
  }

  Future<void> setSetting(String key, String value) async {
    await _db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------- الأهداف ----------------

  Future<List<Goal>> loadGoals() async {
    final goalRows = await _db.query('goals', orderBy: 'created_at DESC');
    final stepRows = await _db.query('steps', orderBy: 'goal_id, position');

    final byGoal = <String, List<GoalStep>>{};
    for (final r in stepRows) {
      byGoal.putIfAbsent(r['goal_id'] as String, () => []).add(
            GoalStep(title: r['title'] as String, done: (r['done'] as int) == 1),
          );
    }

    return goalRows.map((r) {
      final catName = r['category'] as String?;
      return Goal(
        id: r['id'] as String,
        title: r['title'] as String,
        category: GoalCategory.values.firstWhere(
          (c) => c.name == catName,
          orElse: () => GoalCategory.general,
        ),
        start: DateTime.parse(r['start_date'] as String),
        end: DateTime.parse(r['end_date'] as String),
        steps: byGoal[r['id'] as String] ?? [],
        createdAt: r['created_at'] as int,
      );
    }).toList();
  }

  Map<String, Object?> _goalRow(Goal g) => {
        'id': g.id,
        'title': g.title,
        'category': g.category.name,
        'start_date': g.start.toIso8601String(),
        'end_date': g.end.toIso8601String(),
        'created_at': g.createdAt,
      };

  Future<void> _insertSteps(DatabaseExecutor txn, Goal g) async {
    for (var i = 0; i < g.steps.length; i++) {
      await txn.insert('steps', {
        'goal_id': g.id,
        'position': i,
        'title': g.steps[i].title,
        'done': g.steps[i].done ? 1 : 0,
      });
    }
  }

  Future<void> insertGoal(Goal g) => _db.transaction((txn) async {
        await txn.insert('goals', _goalRow(g));
        await _insertSteps(txn, g);
      });

  Future<void> updateGoal(Goal g) => _db.transaction((txn) async {
        await txn.update('goals', _goalRow(g), where: 'id = ?', whereArgs: [g.id]);
        await txn.delete('steps', where: 'goal_id = ?', whereArgs: [g.id]);
        await _insertSteps(txn, g);
      });

  Future<void> deleteGoal(String id) => _db.transaction((txn) async {
        await txn.delete('steps', where: 'goal_id = ?', whereArgs: [id]);
        await txn.delete('goals', where: 'id = ?', whereArgs: [id]);
      });

  Future<void> setStepDone(String goalId, int position, bool done) async {
    await _db.update(
      'steps',
      {'done': done ? 1 : 0},
      where: 'goal_id = ? AND position = ?',
      whereArgs: [goalId, position],
    );
  }

  Future<void> clearGoals() => _db.transaction((txn) async {
        await txn.delete('steps');
        await txn.delete('goals');
      });
}
