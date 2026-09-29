import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/goal_card.dart';
import '../widgets/hero_card.dart';
import '../widgets/top_toast.dart';
import 'goal_details_screen.dart';
import 'goal_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showDone = false;
  GoalCategory? _filter;

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _delete(Goal g) async {
    final ok = await showConfirmDialog(
      context,
      title: 'تأكيد الحذف',
      message: 'هل أنت متأكد من حذف هدف "${g.title}"؟',
    );
    if (!ok || !mounted) return;
    AppScope.read(context).deleteGoal(g.id);
    showTopToast(context, 'تم حذف الهدف');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final goals = state.visibleGoals(completed: _showDone, category: _filter);

    IconData emptyIcon = Icons.flag_outlined;
    String emptyTitle;
    String emptySubtitle;
    if (_showDone) {
      emptyIcon = Icons.check_circle_outline_rounded;
      emptyTitle = _filter == null
          ? 'لا توجد أهداف منجزة حتى الآن'
          : 'لا توجد أهداف منجزة في تصنيف "${_filter!.label}"';
      emptySubtitle = 'أنجز مهام أهدافك الجارية لتراها هنا!';
    } else if (state.totalGoals == 0) {
      emptyTitle = 'لا توجد أهداف مضافة حتى الآن';
      emptySubtitle = 'اضغط على زر "إضافة هدف" لتبدأ رحلتك!';
    } else {
      emptyTitle = _filter == null
          ? 'لا توجد أهداف قيد التنفيذ'
          : 'لا توجد أهداف قيد التنفيذ في تصنيف "${_filter!.label}"';
      emptySubtitle = 'رائع! أنجزت كافة أهدافك الحالية بنجاح.';
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const GoalFormScreen()),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'إضافة هدف',
          style: AppText.body(size: 16.5, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            _Header(
              name: state.displayName,
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(height: 24),
            HeroCard(state: state),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Tabs(
                    showDone: _showDone,
                    inProgress: state.inProgressGoals,
                    done: state.completedGoals,
                    onChanged: (v) => setState(() => _showDone = v),
                  ),
                ),
                const SizedBox(width: 12),
                _FilterButton(
                  selected: _filter,
                  onSelected: (c) => setState(() => _filter = c),
                ),
              ],
            ),
            const SizedBox(height: 17),
            if (goals.isEmpty)
              _Empty(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle)
            else
              for (final g in goals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GoalCard(
                    goal: g,
                    onTap: () => _open(GoalDetailsScreen(goalId: g.id)),
                    onEdit: () => _open(GoalFormScreen(goal: g)),
                    onDelete: () => _delete(g),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.onMenu});

  final String name;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final menuShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          shape: menuShape.copyWith(side: BorderSide(color: AppColors.border, width: 1.2)),
          child: InkWell(
            customBorder: menuShape,
            onTap: onMenu,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(Icons.menu_rounded, color: AppColors.navy, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greeting()}، يا $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(size: 13.5, color: AppColors.muted),
              ),
              Text('مستعد لإنجازات اليوم؟', style: AppText.heading(size: 23)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
              const SizedBox(width: 8),
              Text(
                fullDate(DateTime.now()),
                style: AppText.body(size: 13, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.showDone,
    required this.inProgress,
    required this.done,
    required this.onChanged,
  });

  final bool showDone;
  final int inProgress;
  final int done;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: 'قيد التنفيذ',
              count: inProgress,
              selected: !showDone,
              activeColor: AppColors.navy,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _Tab(
              label: 'المنجزة',
              count: done,
              selected: showDone,
              activeColor: AppColors.green,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? alpha(Colors.white, .22) : AppColors.field,
              ),
              child: Text(
                '$count',
                style: AppText.body(
                  size: 12.5,
                  weight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.selected, required this.onSelected});

  final GoalCategory? selected;
  final ValueChanged<GoalCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final sel = selected;
    if (sel != null) {
      // شريحة التصنيف المختار: بلون التصنيف، والضغط عليها يلغي الفلتر.
      return GestureDetector(
        onTap: () => onSelected(null),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: sel.tint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: alpha(sel.color, .4), width: 1.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(sel.icon, size: 18, color: sel.color),
              const SizedBox(width: 8),
              Text(sel.label, style: AppText.body(size: 14.5, weight: FontWeight.w700, color: sel.color)),
              const SizedBox(width: 8),
              Icon(Icons.close_rounded, size: 17, color: sel.color),
            ],
          ),
        ),
      );
    }

    return PopupMenuButton<int>(
      tooltip: '',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 3),
      color: AppColors.surface,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      onSelected: (v) => onSelected(v < 0 ? null : GoalCategory.values[v]),
      itemBuilder: (_) => [
        _item(-1, 'الكل', Icons.grid_view_rounded, AppColors.navy, AppColors.softBlue),
        for (final c in GoalCategory.values) _item(c.index, c.label, c.icon, c.color, c.tint),
      ],
      child: Container(
        width: 44,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Icon(Icons.tune_rounded, color: AppColors.navy, size: 21),
      ),
    );
  }

  PopupMenuItem<int> _item(int value, String label, IconData icon, Color color, Color tint) {
    final isSelected = value < 0 ? selected == null : selected?.index == value;
    return PopupMenuItem<int>(
      value: value,
      height: 44,
      padding: EdgeInsets.zero,
      child: Container(
        width: 112,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        color: isSelected ? AppColors.menuSelected : Colors.transparent,
        child: Row(
          children: [
            IconBox(icon: icon, color: color, background: tint, size: 26, iconSize: 15, radius: 8),
            const SizedBox(width: 10),
            Text(label, style: AppText.body(size: 15.5, weight: FontWeight.w700)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_rounded, size: 18, color: AppColors.navy),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 30,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.emptyIcon),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.body(size: 16.5, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppText.body(size: 14.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
