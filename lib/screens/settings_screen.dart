import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/confirm_dialog.dart';
import 'developer_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearAll(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'مسح كافة البيانات',
      message: 'هل أنت متأكد من رغبتك في حذف جميع الأهداف نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
    );
    if (!ok || !context.mounted) return;
    AppScope.read(context).clearAll();
  }

  void _logout(BuildContext context) {
    AppScope.read(context).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final divider = Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.divider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'الإعدادات'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  const _Label('الحساب الشخصي'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.person_outline_rounded,
                          title: 'اسمك',
                          subtitle: state.displayName,
                          trailing: Icon(Icons.edit_outlined, color: AppColors.navy, size: 22),
                          onTap: () => showEditNameSheet(context),
                        ),
                        divider,
                        _Row(
                          icon: Icons.logout_rounded,
                          title: 'تسجيل الخروج',
                          subtitle: 'العودة إلى شاشة تسجيل الدخول',
                          trailing: const AppChevron(),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                  const _Label('التفضيلات'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                    _Row(
                      icon: Icons.notifications_none_rounded,
                      title: 'التذكيرات اليومية',
                      subtitle: 'تنبيه دوري لمتابعة الأهداف الجارية (${AppConstants.reminderTime})',
                      trailing: Switch(
                        value: state.remindersOn,
                        onChanged: state.setReminders,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.navy,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.switchOff,
                      ),
                      onTap: () => state.setReminders(!state.remindersOn),
                    ),
                    divider,
                    _Row(
                      icon: Icons.dark_mode_outlined,
                      title: 'الوضع الليلي',
                      subtitle: 'تفعيل المظهر الداكن للتطبيق',
                      trailing: Switch(
                        value: state.darkMode,
                        onChanged: state.setDarkMode,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.navy,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.switchOff,
                      ),
                      onTap: () => state.setDarkMode(!state.darkMode),
                    ),
                      ],
                    ),
                  ),
                  const _Label('البيانات والتخزين'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.outlined_flag_rounded,
                          title: 'إجمالي الأهداف',
                          trailing: Text(
                            '${state.totalGoals}',
                            style: AppText.body(size: 20, weight: FontWeight.w800, color: AppColors.navy),
                          ),
                        ),
                        divider,
                        _Row(
                          icon: Icons.task_alt_rounded,
                          iconColor: AppColors.green,
                          iconBg: AppColors.greenTint,
                          title: 'الأهداف المكتملة',
                          trailing: Text(
                            '${state.completedGoals}',
                            style: AppText.body(size: 20, weight: FontWeight.w800, color: AppColors.green),
                          ),
                        ),
                        divider,
                        _Row(
                          icon: Icons.delete_sweep_outlined,
                          iconColor: AppColors.red,
                          iconBg: AppColors.redTint,
                          title: 'مسح كافة الأهداف',
                          titleColor: AppColors.red,
                          subtitle: 'حذف جميع الأهداف والخطوات نهائياً',
                          trailing: const AppChevron(),
                          onTap: () => _clearAll(context),
                        ),
                      ],
                    ),
                  ),
                  const _Label('حول التطبيق'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.info_outline_rounded,
                          title: 'عن تطبيق ${AppConstants.appName}',
                          subtitle: AppConstants.appDescription,
                        ),
                        divider,
                        _Row(
                          icon: Icons.code_rounded,
                          title: 'المطور',
                          subtitle: AppConstants.developerName,
                          trailing: const AppChevron(),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const DeveloperScreen()),
                          ),
                        ),
                        divider,
                        _Row(
                          icon: Icons.verified_outlined,
                          title: 'الإصدار',
                          trailing: Text(
                            'v${AppConstants.version}',
                            textDirection: TextDirection.ltr,
                            style: AppText.body(size: 16, weight: FontWeight.w800, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
        child: Text(text, style: AppText.body(size: 16, weight: FontWeight.w700, color: AppColors.muted)),
      );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBg,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBg;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
        child: Row(
          children: [
            IconBox(icon: icon, color: iconColor ?? AppColors.navy, background: iconBg ?? AppColors.softBlue, size: 36, iconSize: 18, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body(size: 16, weight: FontWeight.w700, color: titleColor ?? AppColors.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: AppText.body(size: 13.5, color: AppColors.muted, height: 1.5)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// نافذة "تعديل الاسم الشخصي".
Future<void> showEditNameSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
    ),
    builder: (_) => _EditNameSheet(parentContext: context),
  );
}

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final TextEditingController _ctrl =
      TextEditingController(text: AppScope.read(widget.parentContext).userName);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    AppScope.read(context).updateName(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const IconBox(icon: Icons.person_rounded, size: 48, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تعديل الاسم الشخصي', style: AppText.heading(size: 22)),
                    Text(
                      'يظهر هذا الاسم في رسائل التحية ولوحة التحكم',
                      style: AppText.body(size: 13.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: AppText.body(size: 16),
            onSubmitted: (_) => _save(),
            decoration: AppInput.decoration('اسمك'),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded, size: 22),
                    label: Text(
                      'حفظ التغييرات',
                      style: AppText.body(size: 16, weight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: BorderSide(color: AppColors.border, width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('إلغاء', style: AppText.body(size: 16, weight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
