import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/goal.dart';
import 'common.dart';

/// بطاقة الهدف في القائمة الرئيسية.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = goal.isCompleted;
    final accent = done ? AppColors.green : AppColors.navy;
    final pct = (goal.progress * 100).round();
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: BorderSide(color: done ? AppColors.greenBorderSoft : AppColors.border, width: 1.2),
    );

    return Material(
      color: AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pill(
                    label: goal.category.label,
                    icon: goal.category.icon,
                    background: goal.category.tint,
                    foreground: goal.category.color,
                  ),
                  const SizedBox(width: 8),
                  _statusPill(),
                  const Spacer(),
                  _action(Icons.edit_outlined, AppColors.navy, onEdit),
                  _action(Icons.delete_outline_rounded, AppColors.red, onDelete),
                ],
              ),
              const SizedBox(height: 11),
              Text(goal.title, style: AppText.heading(size: 22)),
              const SizedBox(height: 12),
              ProgressBar(value: goal.progress, color: accent),
              const SizedBox(height: 9),
              Row(
                children: [
                  Text(
                    '$pct%',
                    style: AppText.body(size: 16, weight: FontWeight.w800, color: accent),
                  ),
                  const Spacer(),
                  Text(
                    '${goal.doneSteps} من ${goal.totalSteps} خطوات منجزة',
                    style: AppText.body(size: 14, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 17, color: AppColors.navy),
                    const SizedBox(width: 8),
                    Text(
                      shortDate(goal.start),
                      style: AppText.body(size: 14, weight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.west, size: 15, color: AppColors.muted),
                    const SizedBox(width: 8),
                    Text(
                      shortDate(goal.end),
                      style: AppText.body(size: 14, weight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text('الفترة الزمنية', style: AppText.body(size: 13, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill() {
    if (goal.isCompleted) {
      return Pill(
        label: 'مكتمل',
        icon: Icons.check_circle_rounded,
        background: AppColors.greenTint,
        foreground: AppColors.green,
      );
    }
    final overdue = goal.daysLeft < 0;
    return Pill(
      label: remainingLabel(goal.daysLeft),
      icon: Icons.schedule_rounded,
      background: overdue ? AppColors.redTint : AppColors.chip,
      foreground: overdue ? AppColors.red : AppColors.navy,
    );
  }

  Widget _action(IconData icon, Color color, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      );
}
