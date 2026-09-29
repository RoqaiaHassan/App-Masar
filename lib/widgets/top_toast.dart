import 'package:flutter/material.dart';

import '../core/theme.dart';

/// إشعار علوي يظهر ثم يختفي تلقائياً ("تم بنجاح").
void showTopToast(
  BuildContext context,
  String message, {
  String title = 'تم بنجاح',
  bool isError = false,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopToast(
      title: title,
      message: message,
      isError: isError,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  const _TopToast({
    required this.title,
    required this.message,
    required this.isError,
    required this.onDone,
  });

  final String title;
  final String message;
  final bool isError;
  final VoidCallback onDone;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 320));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 2400), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.isError ? AppColors.red : AppColors.green;
    final bg = widget.isError ? AppColors.redTint : AppColors.greenTint;
    final top = MediaQuery.of(context).padding.top + 10;
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _c,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
              .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: alpha(fg, .18)),
                boxShadow: [
                  BoxShadow(
                    color: alpha(Colors.black, .08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppText.heading(size: 22, color: fg)),
                  Text(widget.message, style: AppText.body(size: 15, color: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
