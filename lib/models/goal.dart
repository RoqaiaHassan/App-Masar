import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';

enum GoalCategory { work, study, sports, health, finance, personal, general }

extension GoalCategoryX on GoalCategory {
  Color get color =>
      AppColors.dark ? Color.lerp(_baseColor, Colors.white, .3)! : _baseColor;

  Color get tint => AppColors.dark ? alpha(_baseColor, .22) : _lightTint;

  String get label {
    switch (this) {
      case GoalCategory.work:
        return 'عمل';
      case GoalCategory.study:
        return 'دراسة';
      case GoalCategory.sports:
        return 'رياضة';
      case GoalCategory.health:
        return 'صحة';
      case GoalCategory.finance:
        return 'مالي';
      case GoalCategory.personal:
        return 'شخصي';
      case GoalCategory.general:
        return 'عام';
    }
  }

  IconData get icon {
    switch (this) {
      case GoalCategory.work:
        return Icons.work_outline_rounded;
      case GoalCategory.study:
        return Icons.menu_book_rounded;
      case GoalCategory.sports:
        return Icons.fitness_center_rounded;
      case GoalCategory.health:
        return Icons.favorite_border_rounded;
      case GoalCategory.finance:
        return Icons.account_balance_wallet_outlined;
      case GoalCategory.personal:
        return Icons.person_outline_rounded;
      case GoalCategory.general:
        return Icons.layers_outlined;
    }
  }

  Color get _baseColor {
    switch (this) {
      case GoalCategory.work:
        return const Color(0xFF6B5B7E);
      case GoalCategory.study:
        return const Color(0xFF3F6B80);
      case GoalCategory.sports:
        return const Color(0xFFB5563B);
      case GoalCategory.health:
        return const Color(0xFF4A7C59);
      case GoalCategory.finance:
        return const Color(0xFFB07D2E);
      case GoalCategory.personal:
        return const Color(0xFFA64D65);
      case GoalCategory.general:
        return const Color(0xFF8A857A);
    }
  }

  Color get _lightTint {
    switch (this) {
      case GoalCategory.work:
        return const Color(0xFFEDEAF1);
      case GoalCategory.study:
        return const Color(0xFFE2EBEF);
      case GoalCategory.sports:
        return const Color(0xFFF5E6E0);
      case GoalCategory.health:
        return const Color(0xFFE3EDE6);
      case GoalCategory.finance:
        return const Color(0xFFF5EBDD);
      case GoalCategory.personal:
        return const Color(0xFFF3E3E8);
      case GoalCategory.general:
        return const Color(0xFFECEAE5);
    }
  }
}

class GoalStep {
  GoalStep({required this.title, this.done = false});

  String title;
  bool done;
}

class Goal {
  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.start,
    required this.end,
    required this.steps,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  final String id;
  final int createdAt;
  String title;
  GoalCategory category;
  DateTime start;
  DateTime end;
  List<GoalStep> steps;

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  int get totalSteps => steps.length;
  int get doneSteps => steps.where((s) => s.done).length;
  int get remainingSteps => totalSteps - doneSteps;
  double get progress => totalSteps == 0 ? 0 : doneSteps / totalSteps;
  bool get isCompleted => totalSteps > 0 && doneSteps == totalSteps;

  /// الأيام المتبقية (قد تكون سالبة إذا انتهت المدة).
  int get daysLeft => daysBetween(DateTime.now(), end);
  int get durationDays => daysBetween(start, end) + 1;
}
