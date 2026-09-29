import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/goal.dart';

/// قاعدة بيانات SQLite: جدول الأهداف + جدول الخطوات + جدول الإعدادات (الحساب).
class DatabaseService {
  DatabaseService._(this._db);

  final Database _db;

  static Future<DatabaseService> open() async {
    // الحصول على مسار التخزين الدائم الخاص بالتطبيق على الجهاز
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'masar.db');

    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE steps(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id TEXT NOT NULL,
            position INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_done INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            name TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
    return DatabaseService._(db);
  }

  // ---------------- الإعدادات ----------------

  Future<String?> getSetting(String name) async {
    final rows = await _db.query('settings', where: 'name = ?', whereArgs: [name], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String name, String value) async {
    await _db.insert(
      'settings',
      {'name': name, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------- الأهداف ----------------

  Future<List<Goal>> loadGoals() async {
    final goalRows = await _db.query('goals', orderBy: 'rowid DESC');
    final stepRows = await _db.query('steps', orderBy: 'goal_id, position');

    final byGoal = <String, List<GoalStep>>{};
    for (final r in stepRows) {
      byGoal.putIfAbsent(r['goal_id'] as String, () => []).add(
            GoalStep(title: r['title'] as String, done: (r['is_done'] as int) == 1),
          );
    }

    return goalRows.map((r) {
      final id = r['id'] as String;
      final catName = r['category'] as String;
      return Goal(
        id: id,
        title: r['title'] as String,
        category: GoalCategory.values.firstWhere(
          (c) => c.name == catName,
          orElse: () => GoalCategory.general,
        ),
        start: DateTime.parse(r['start_date'] as String),
        end: DateTime.parse(r['end_date'] as String),
        steps: byGoal[id] ?? [],
      );
    }).toList();
  }

  Map<String, Object?> _goalRow(Goal g) => {
        'id': g.id,
        'title': g.title,
        'category': g.category.name,
        'start_date': g.start.toIso8601String(),
        'end_date': g.end.toIso8601String(),
      };

  Future<void> _insertSteps(DatabaseExecutor exec, Goal g) async {
    final batch = exec.batch();
    for (var i = 0; i < g.steps.length; i++) {
      batch.insert('steps', {
        'goal_id': g.id,
        'position': i,
        'title': g.steps[i].title,
        'is_done': g.steps[i].done ? 1 : 0,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertGoal(Goal g) async {
    await _db.transaction((txn) async {
      await txn.insert('goals', _goalRow(g));
      await _insertSteps(txn, g);
    });
  }

  Future<void> replaceGoal(Goal g) async {
    await _db.transaction((txn) async {
      await txn.update('goals', _goalRow(g), where: 'id = ?', whereArgs: [g.id]);
      await txn.delete('steps', where: 'goal_id = ?', whereArgs: [g.id]);
      await _insertSteps(txn, g);
    });
  }

  Future<void> setStepDone(String goalId, int position, bool done) async {
    await _db.update(
      'steps',
      {'is_done': done ? 1 : 0},
      where: 'goal_id = ? AND position = ?',
      whereArgs: [goalId, position],
    );
  }

  Future<void> deleteGoal(String id) async {
    await _db.transaction((txn) async {
      await txn.delete('steps', where: 'goal_id = ?', whereArgs: [id]);
      await txn.delete('goals', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> clearGoals() async {
    await _db.transaction((txn) async {
      await txn.delete('steps');
      await txn.delete('goals');
    });
  }
}
