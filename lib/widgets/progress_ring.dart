import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// حلقة التقدم: كحلية أثناء التنفيذ، وخضراء عند الاكتمال.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 92});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = progress >= 1 ? AppColors.green : AppColors.navy;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: _RingPainter(progress, color)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: AppText.body(size: 24, weight: FontWeight.w800, height: 1.2),
              ),
              Text('إنجاز', style: AppText.body(size: 12, color: AppColors.muted, height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.ringTrack;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress.clamp(0.0, 1.0).toDouble(), false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.color != color;
}
