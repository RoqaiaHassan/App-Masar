import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/goal.dart';
import '../services/database_service.dart';

/// يوصل الحالة لكل الشاشات بدون مكتبات إضافية.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({Key? key, required AppState state, required Widget child})
      : super(key: key, notifier: state, child: child);

  /// يستمع للتغييرات (يعيد بناء الويدجت).
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// بدون استماع (للأزرار والأحداث).
  static AppState read(BuildContext context) {
    final el = context.getElementForInheritedWidgetOfExactType<AppScope>();
    return (el!.widget as AppScope).notifier!;
  }
}

/// الحالة في الذاكرة + حفظ كل تغيير في SQLite (بترتيب متسلسل).
class AppState extends ChangeNotifier {
  AppState._(this._db);

  static Future<AppState> load() async {
    final state = AppState._(await DatabaseService.open());
    await state._init();
    return state;
  }

  static const _kName = 'user_name';
  static const _kPass = 'user_pass';
  static const _kLogged = 'logged_in';
  static const _kReminders = 'reminders_on';
  static const _kDark = 'dark_mode';

  final DatabaseService _db;
  Future<void> _queue = Future<void>.value();

  String userName = '';
  String? _passHash;
  bool loggedIn = false;
  bool remindersOn = true;
  bool darkMode = false;
  List<Goal> goals = [];

  Future<void> _init() async {
    userName = await _db.getSetting(_kName) ?? '';
    _passHash = await _db.getSetting(_kPass);
    loggedIn = (await _db.getSetting(_kLogged)) == '1';
    remindersOn = (await _db.getSetting(_kReminders)) != '0';
    darkMode = (await _db.getSetting(_kDark)) == '1';
    AppColors.dark = darkMode;
    goals = await _db.loadGoals();
  }

  void _enqueue(Future<void> Function() job) {
    _queue = _queue.then((_) => job()).catchError((Object e) {
      debugPrint('Database error: $e');
    });
  }

  // ---------------- الحساب ----------------

  bool get hasAccount => _passHash != null;
  String get displayName => userName.isEmpty ? AppConstants.defaultName : userName;

  String _hash(String pass) => sha256.convert(utf8.encode(pass)).toString();

  Future<void> register(String name, String pass) async {
    userName = name;
    _passHash = _hash(pass);
    loggedIn = true;
    _enqueue(() => _db.setSetting(_kName, userName));
    _enqueue(() => _db.setSetting(_kPass, _passHash!));
    _enqueue(() => _db.setSetting(_kLogged, '1'));
    notifyListeners();
    await _queue;
  }

  bool login(String name, String pass) {
    if (name.trim() != userName || _hash(pass) != _passHash) return false;
    loggedIn = true;
    _enqueue(() => _db.setSetting(_kLogged, '1'));
    notifyListeners();
    return true;
  }

  void logout() {
    loggedIn = false;
    _enqueue(() => _db.setSetting(_kLogged, '0'));
    notifyListeners();
  }

  void updateName(String name) {
    userName = name.trim();
    final value = userName;
    _enqueue(() => _db.setSetting(_kName, value));
    notifyListeners();
  }

  void setReminders(bool value) {
    remindersOn = value;
    _enqueue(() => _db.setSetting(_kReminders, value ? '1' : '0'));
    notifyListeners();
  }

  void setDarkMode(bool value) {
    darkMode = value;
    AppColors.dark = value; // قبل الإشعار حتى تُبنى الشاشات بالألوان الجديدة
    _enqueue(() => _db.setSetting(_kDark, value ? '1' : '0'));
    notifyListeners();
  }

  // ---------------- الأهداف ----------------

  int get totalGoals => goals.length;
  int get completedGoals => goals.where((g) => g.isCompleted).length;
  int get inProgressGoals => totalGoals - completedGoals;
  double get overallProgress => totalGoals == 0 ? 0 : completedGoals / totalGoals;

  Goal? goalById(String id) {
    for (final g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  List<Goal> visibleGoals({required bool completed, GoalCategory? category}) => goals
      .where((g) => g.isCompleted == completed && (category == null || g.category == category))
      .toList();

  void addGoal(Goal goal) {
    goals.insert(0, goal);
    _enqueue(() => _db.insertGoal(goal));
    notifyListeners();
  }

  void updateGoal(Goal updated) {
    final i = goals.indexWhere((g) => g.id == updated.id);
    if (i == -1) return;
    goals[i] = updated;
    _enqueue(() => _db.replaceGoal(updated));
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    _enqueue(() => _db.deleteGoal(id));
    notifyListeners();
  }

  void toggleStep(String goalId, int index) {
    final g = goalById(goalId);
    if (g == null || index < 0 || index >= g.steps.length) return;
    final step = g.steps[index];
    step.done = !step.done;
    final done = step.done;
    _enqueue(() => _db.setStepDone(goalId, index, done));
    notifyListeners();
  }

  void clearAll() {
    goals = [];
    _enqueue(() => _db.clearGoals());
    notifyListeners();
  }
}
