import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../screens/developer_screen.dart';
import '../screens/settings_screen.dart';
import '../state/app_state.dart';
import 'common.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final width = MediaQuery.of(context).size.width * 0.74;
    final topInset = MediaQuery.of(context).padding.top;

    return Drawer(
      width: width,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(36)),
      ),
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(20, topInset + 22, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.avatarBorder, width: 1.5),
                      ),
                      child: Icon(Icons.person_rounded, color: AppColors.navy, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.heading(size: 24),
                          ),
                          Text(
                            'لوحة تتبع الأهداف اليومية',
                            style: AppText.body(size: 13.5, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 22),
                      const SizedBox(width: 8),
                      Text('الأهداف المنجزة', style: AppText.body(size: 14.5, color: AppColors.muted)),
                      const Spacer(),
                      Text(
                        '${state.completedGoals} من ${state.totalGoals}',
                        style: AppText.body(size: 15, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 22),
          _Item(
            icon: Icons.home_rounded,
            label: 'الرئيسية',
            onTap: () => Navigator.of(context).pop(),
          ),
          _Item(
            icon: Icons.settings_outlined,
            label: 'الإعدادات',
            onTap: () => _go(context, const SettingsScreen()),
          ),
          _Item(
            icon: Icons.info_outline_rounded,
            label: 'عن التطبيق',
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              showAboutAppDialog(nav.context);
            },
          ),
          _Item(
            icon: Icons.person_pin_circle_outlined,
            label: 'عن المطور',
            onTap: () => _go(context, const DeveloperScreen()),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'تطبيق ${AppConstants.appName} • الإصدار ${AppConstants.version}',
              style: AppText.body(size: 13.5, color: AppColors.faint),
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, Widget page) {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => page));
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            IconBox(icon: icon, background: AppColors.chip, size: 36, iconSize: 18, radius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppText.body(size: 17, weight: FontWeight.w700)),
            ),
            const AppChevron(),
          ],
        ),
      ),
    );
  }
}

/// نافذة "عن التطبيق".
Future<void> showAboutAppDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 14),
            Text(AppConstants.appName, style: AppText.heading(size: 32, color: AppColors.navy)),
            Text(
              AppConstants.tagline,
              textAlign: TextAlign.center,
              style: AppText.heading(size: 16, color: AppColors.muted, weight: FontWeight.w400),
            ),
            const SizedBox(height: 14),
            Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: AppText.body(size: 15, color: AppColors.muted, height: 1.7),
            ),
            const SizedBox(height: 10),
            Text(
              'الإصدار ${AppConstants.version}',
              style: AppText.body(size: 13.5, color: AppColors.faint),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'حسناً',
                  style: AppText.body(size: 16, weight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
