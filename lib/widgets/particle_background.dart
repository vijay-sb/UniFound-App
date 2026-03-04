import 'dart:math';
import 'package:flutter/material.dart';

/// Reusable animated particle background with green grid lines.
/// Extracted from BlindFeedScreen for shared use across screens.
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> particles = List.generate(65, (index) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: _GridPainter(particles, _controller.value));
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _GridPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF9CFF00).withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    const double step = 50;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    for (var p in particles) {
      final double movingY =
          (p.y * size.height - (progress * size.height * p.speed)) %
              size.height;
      final double movingX =
          (p.x * size.width + (sin(progress * 10 * p.speed) * 20)) % size.width;

      final opacity = (sin(progress * 6.28 + p.randomSeed) + 1) / 2;
      final particlePaint = Paint()
        ..color = const Color(0xFF9CFF00).withValues(alpha: opacity * 0.4);

      canvas.drawCircle(Offset(movingX, movingY), p.size, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 4 + 1.5;
  double speed = Random().nextDouble() * 0.4 + 0.2;
  double randomSeed = Random().nextDouble() * 100;
}
