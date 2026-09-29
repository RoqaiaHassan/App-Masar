import 'package:flutter/material.dart';

import '../core/theme.dart';

/// بطاقة بحواف دائرية (تدعم تأثير اللمس داخلها).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? AppColors.border, width: 1.2),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = 46,
    this.iconSize = 22,
    this.radius = 16,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? AppColors.softBlue,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: color ?? AppColors.navy, size: iconSize),
    );
  }
}

/// سهم ">" ثابت الاتجاه كما في التصميم الأصلي.
class AppChevron extends StatelessWidget {
  const AppChevron({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(Icons.chevron_right_rounded, color: color ?? AppColors.muted, size: 26),
    );
  }
}

class SquareBackButton extends StatelessWidget {
  const SquareBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return Material(
      color: AppColors.surface,
      shape: shape.copyWith(side: BorderSide(color: AppColors.border, width: 1.2)),
      child: InkWell(
        customBorder: shape,
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: 38,
          height: 40,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Icon(Icons.chevron_right_rounded, color: AppColors.navy, size: 28),
          ),
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
      child: Row(
        children: [
          const SquareBackButton(),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.heading(size: 22),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.body(size: 13, weight: FontWeight.w600, color: foreground),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.track,
    this.height = 7,
  });

  final double value;
  final Color color;
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: track ?? AppColors.track,
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0).toDouble(),
          child: Container(color: color),
        ),
      ),
    );
  }
}

/// قسم داخل شاشة إضافة/تعديل الهدف.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.badge,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.navy, size: 22),
                const SizedBox(width: 10),
                Text(title, style: AppText.heading(size: 18)),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge!,
                      style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.navy),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class AppInput {
  AppInput._();

  static InputDecoration decoration(String hint, {Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.body(size: 15, color: AppColors.hint),
      filled: true,
      fillColor: AppColors.field,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.navy, width: 1.4),
    );
  }

  static OutlineInputBorder _border(Color c, {double width = 1.2}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: c, width: width),
      );
}
