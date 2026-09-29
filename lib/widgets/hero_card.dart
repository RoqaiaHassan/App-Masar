import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../state/app_state.dart';
import 'common.dart';

/// البطاقة الزرقاء العلوية (لوحة الإنجاز العام).
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final progress = state.overallProgress;
    final percent = (progress * 100).round();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: alpha(AppColors.heroBg, .25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DecorPainter())),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Chip(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.show_chart_rounded, size: 17, color: AppColors.gold),
                            const SizedBox(width: 6),
                            Text(
                              'لوحة الإنجاز العام',
                              style: AppText.body(size: 13, weight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _Chip(
                        outlined: true,
                        child: Text(
                          '$percent%',
                          style: AppText.body(size: 14.5, weight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    heroMessage(
                      total: state.totalGoals,
                      completed: state.completedGoals,
                      progress: progress,
                    ),
                    style: AppText.body(size: 18, weight: FontWeight.w700, color: Colors.white, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ProgressBar(
                    value: progress,
                    color: AppColors.gold,
                    track: alpha(Colors.white, .15),
                    height: 7,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: alpha(Colors.white, .12)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _Stat(
                            icon: Icons.pending_actions_rounded,
                            iconColor: AppColors.gold,
                            label: 'قيد التنفيذ',
                            value: state.inProgressGoals,
                          ),
                          _divider(),
                          _Stat(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF6FA283),
                            label: 'المكتملة',
                            value: state.completedGoals,
                          ),
                          _divider(),
                          _Stat(
                            icon: Icons.format_list_bulleted_rounded,
                            iconColor: alpha(Colors.white, .6),
                            label: 'الإجمالي',
                            value: state.totalGoals,
                          ),
                        ],
                      ),
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

  Widget _divider() => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: alpha(Colors.white, .12),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.child, this.outlined = false});

  final Widget child;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: alpha(Colors.white, outlined ? .08 : .10),
        borderRadius: BorderRadius.circular(16),
        border: outlined ? Border.all(color: alpha(Colors.white, .25), width: 1.2) : null,
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 5),
              Text(label, style: AppText.body(size: 12.5, color: alpha(Colors.white, .7))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: AppText.body(size: 26, weight: FontWeight.w800, color: Colors.white, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _DecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = alpha(Colors.white, .05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = alpha(Colors.white, .05);

    final p0 = Offset(0, size.height * .42);
    final p1 = Offset(size.width * .17, size.height * .30);
    final p2 = Offset(size.width * .28, size.height * .16);
    canvas.drawPath(
      Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy),
      line,
    );
    canvas.drawCircle(p1, 22, fill);
    canvas.drawCircle(p2, 22, fill);
    canvas.drawCircle(
      Offset(size.width * .96, size.height * .92),
      90,
      Paint()..color = alpha(Colors.white, .04),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
