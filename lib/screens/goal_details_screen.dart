import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/progress_ring.dart';

/// شاشة "تفاصيل الهدف".
class GoalDetailsScreen extends StatelessWidget {
  const GoalDetailsScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final goal = state.goalById(goalId);
    if (goal == null) return const Scaffold();

    final done = goal.isCompleted;
    final overdue = !done && goal.daysLeft < 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'تفاصيل الهدف'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  AppCard(
                    radius: 32,
                    color: AppColors.warmCard,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Pill(
                              label: goal.category.label,
                              icon: goal.category.icon,
                              background: goal.category.tint,
                              foreground: goal.category.color,
                            ),
                            const Spacer(),
                            if (done)
                              Pill(
                                label: 'مكتمل',
                                icon: Icons.check_circle_rounded,
                                background: AppColors.greenTint,
                                foreground: AppColors.green,
                              )
                            else
                              Pill(
                                label: remainingLabel(goal.daysLeft),
                                icon: Icons.schedule_rounded,
                                background: overdue ? AppColors.redTint : AppColors.chip,
                                foreground: overdue ? AppColors.red : AppColors.navy,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          goal.title,
                          textAlign: TextAlign.center,
                          style: AppText.heading(size: 30),
                        ),
                        const SizedBox(height: 11),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border, width: 1.2),
                              ),
                              child: Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.navy),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              shortDate(goal.start),
                              style: AppText.body(size: 14.5, weight: FontWeight.w600, color: AppColors.muted),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.west, size: 15, color: AppColors.muted),
                            const SizedBox(width: 8),
                            Text(
                              shortDate(goal.end),
                              style: AppText.body(size: 14.5, weight: FontWeight.w600, color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.border, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              ProgressRing(progress: goal.progress),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          done ? Icons.stars_rounded : Icons.show_chart_rounded,
                                          size: 19,
                                          color: done ? AppColors.green : AppColors.navy,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'مستوى التقدم',
                                          style: AppText.body(size: 14.5, weight: FontWeight.w700, color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      progressMessage(
                                        progress: goal.progress,
                                        seed: '${goal.id}|${goal.doneSteps}',
                                      ),
                                      style: AppText.body(size: 14, color: AppColors.muted, height: 1.6),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 19),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border, width: 1.2),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                _Stat(
                                  icon: Icons.format_list_bulleted_rounded,
                                  iconColor: AppColors.navy,
                                  iconBg: AppColors.softBlue,
                                  label: 'الإجمالي',
                                  value: goal.totalSteps,
                                  valueColor: AppColors.navy,
                                ),
                                _divider(),
                                _Stat(
                                  icon: Icons.check_rounded,
                                  iconColor: Colors.white,
                                  iconBg: AppColors.green,
                                  label: 'المنجز',
                                  value: goal.doneSteps,
                                  valueColor: AppColors.green,
                                ),
                                _divider(),
                                _Stat(
                                  icon: Icons.pending_actions_rounded,
                                  iconColor: done ? AppColors.green : AppColors.gold,
                                  iconBg: done ? AppColors.greenTint : AppColors.goldTint,
                                  label: 'المتبقي',
                                  value: goal.remainingSteps,
                                  valueColor: done ? AppColors.green : AppColors.gold,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text('الخطوات والمهام التنفيذية', style: AppText.heading(size: 22)),
                  const SizedBox(height: 12),
                  for (var i = 0; i < goal.steps.length; i++)
                    _StepTile(
                      step: goal.steps[i],
                      onTap: () => AppScope.read(context).toggleStep(goal.id, i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: AppColors.border,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final int value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
                child: Icon(icon, size: 13, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(label, style: AppText.body(size: 12.5, weight: FontWeight.w600, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: AppText.body(size: 28, weight: FontWeight.w800, color: valueColor, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.onTap});

  final GoalStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = step.done;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: done ? AppColors.greenBorder : AppColors.border, width: 1.3),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: done ? AppColors.stepDone : AppColors.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: done ? AppColors.green : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: done ? AppColors.green : AppColors.checkBorder,
                      width: 1.6,
                    ),
                  ),
                  child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    step.title,
                    style: AppText.body(
                      size: 17,
                      weight: FontWeight.w600,
                      color: done ? AppColors.doneText : AppColors.text,
                    ).copyWith(decoration: done ? TextDecoration.lineThrough : null),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
