import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/top_toast.dart';

/// شاشة "خطة هدف جديدة" — وتُستخدم أيضاً لتعديل هدف موجود.
class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, this.goal});

  final Goal? goal;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _titleCtrl = TextEditingController();
  final List<TextEditingController> _stepCtrls = [];
  final List<bool> _stepDone = [];
  GoalCategory _category = GoalCategory.work;
  late DateTime _start;
  late DateTime _end;

  bool get _editing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _titleCtrl.text = g.title;
      _category = g.category;
      _start = g.start;
      _end = g.end;
      for (final s in g.steps) {
        _stepCtrls.add(TextEditingController(text: s.title));
        _stepDone.add(s.done);
      }
    } else {
      final today = dateOnly(DateTime.now());
      _start = today;
      _end = DateTime(today.year, today.month, today.day + 14);
    }
    while (_stepCtrls.length < 2) {
      _stepCtrls.add(TextEditingController());
      _stepDone.add(false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final c in _stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() => setState(() {
        _stepCtrls.add(TextEditingController());
        _stepDone.add(false);
      });

  void _removeStep(int i) => setState(() {
        _stepCtrls.removeAt(i).dispose();
        _stepDone.removeAt(i);
      });

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(math.min(now.year - 1, _start.year)),
      lastDate: DateTime(math.max(now.year + 10, _end.year)),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.navy,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  void _warn(String message) => showTopToast(context, message, title: 'تنبيه', isError: true);

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _warn('اكتب الهدف الرئيسي أولاً');
      return;
    }
    final steps = <GoalStep>[];
    for (var i = 0; i < _stepCtrls.length; i++) {
      final t = _stepCtrls[i].text.trim();
      if (t.isNotEmpty) steps.add(GoalStep(title: t, done: _stepDone[i]));
    }
    if (steps.isEmpty) {
      _warn('أضف خطوة فرعية واحدة على الأقل');
      return;
    }

    final state = AppScope.read(context);
    if (_editing) {
      state.updateGoal(Goal(
        id: widget.goal!.id,
        title: title,
        category: _category,
        start: _start,
        end: _end,
        steps: steps,
      ));
      showTopToast(context, 'تم تحديث خطة الهدف');
    } else {
      state.addGoal(Goal(
        id: Goal.newId(),
        title: title,
        category: _category,
        start: _start,
        end: _end,
        steps: steps,
      ));
      showTopToast(context, 'تمت إضافة الهدف');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final days = daysBetween(_start, _end) + 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: _editing ? 'تعديل خطة الهدف' : 'خطة هدف جديدة'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  FormSection(
                    icon: Icons.flag_rounded,
                    title: 'الهدف الرئيسي',
                    child: TextField(
                      controller: _titleCtrl,
                      textInputAction: TextInputAction.next,
                      style: AppText.body(size: 16),
                      decoration: AppInput.decoration('ما الذي ترغب في تحقيقه؟'),
                    ),
                  ),
                  FormSection(
                    icon: Icons.grid_view_rounded,
                    title: 'مجال الهدف',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in GoalCategory.values)
                          _CategoryChip(
                            category: c,
                            selected: c == _category,
                            onTap: () => setState(() => _category = c),
                          ),
                      ],
                    ),
                  ),
                  FormSection(
                    icon: Icons.calendar_today_outlined,
                    title: 'الفترة الزمنية',
                    badge: '$days يوم',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _pickRange,
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('من', style: AppText.body(size: 15, color: AppColors.muted, weight: FontWeight.w600)),
                            Text(
                              slashDate(_start),
                              textDirection: TextDirection.ltr,
                              style: AppText.body(size: 16.5, weight: FontWeight.w800),
                            ),
                            Text('إلى', style: AppText.body(size: 15, color: AppColors.muted, weight: FontWeight.w600)),
                            Text(
                              slashDate(_end),
                              textDirection: TextDirection.ltr,
                              style: AppText.body(size: 16.5, weight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FormSection(
                    icon: Icons.checklist_rtl_rounded,
                    title: 'الخطوات الفرعية',
                    badge: '${_stepCtrls.length} خطوات',
                    child: Column(
                      children: [
                        for (var i = 0; i < _stepCtrls.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.softBlue,
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: AppText.body(size: 16, weight: FontWeight.w800, color: AppColors.navy),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _stepCtrls[i],
                                    style: AppText.body(size: 16),
                                    decoration: AppInput.decoration('اكتب الخطوة هنا...'),
                                  ),
                                ),
                                if (_stepCtrls.length > 2)
                                  IconButton(
                                    onPressed: () => _removeStep(i),
                                    icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.red),
                                  ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _addStep,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                            label: Text('إضافة خطوة', style: AppText.body(size: 15, weight: FontWeight.w700, color: AppColors.navy)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 24),
                  label: Text(
                    'حفظ خطة الهدف',
                    style: AppText.body(size: 17, weight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.selected, required this.onTap});

  final GoalCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.text;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? category.color : AppColors.chipIdle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? category.color : AppColors.border, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 20, color: fg),
            const SizedBox(width: 8),
            Text(category.label, style: AppText.body(size: 15, weight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}
