import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  double rotation;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
    required this.rotation,
  });
}

class ConfettiBurstOverlay extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final VoidCallback? onFinished;

  const ConfettiBurstOverlay({
    super.key,
    required this.child,
    required this.trigger,
    this.onFinished,
  });

  @override
  State<ConfettiBurstOverlay> createState() => _ConfettiBurstOverlayState();
}

class _ConfettiBurstOverlayState extends State<ConfettiBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  final List<Color> _palette = const [
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFF8B5CF6),
    Color(0xFFF43F5E),
    Color(0xFF34D399),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        _updateParticles();
        setState(() {});
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
      }
    });

    if (widget.trigger) {
      _spawnParticles();
    }
  }

  @override
  void didUpdateWidget(ConfettiBurstOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _spawnParticles();
    }
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 45; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 3.0 + _random.nextDouble() * 7.0;
      _particles.add(
        ConfettiParticle(
          x: 0.0,
          y: 0.0,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 2.0,
          size: 4.0 + _random.nextDouble() * 6.0,
          color: _palette[_random.nextInt(_palette.length)],
          opacity: 1.0,
          rotation: _random.nextDouble() * pi * 2,
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  void _updateParticles() {
    final progress = _controller.value;
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy + 0.3; // Gravity effect
      p.opacity = (1.0 - progress).clamp(0.0, 1.0);
      p.rotation += 0.1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx + p.x, center.dy + p.y);
      canvas.rotate(p.rotation);

      if (p.size > 7.0) {
        // Draw star particle
        final rect = Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
      } else {
        // Draw circle particle
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
