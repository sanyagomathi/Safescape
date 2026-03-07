import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class GradientHeader extends StatefulWidget {
  final String title;
  final String subtitle;

  const GradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<GradientHeader> createState() => _GradientHeaderState();
}

class _GradientHeaderState extends State<GradientHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 6),
        )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 155,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlueDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Stack(
                children: [
                  Positioned(
                    top: 25 + sin(_controller.value * 2 * pi) * 10,
                    left: -35,
                    child: _circle(
                      110,
                      Colors.white.withOpacity(0.06),
                    ),
                  ),
                  Positioned(
                    top: 55 + cos(_controller.value * 2 * pi) * 10,
                    right: -45,
                    child: _circle(
                      130,
                      Colors.white.withOpacity(0.06),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 90 + sin(_controller.value * 2 * pi) * 8,
                    child: _circle(
                      90,
                      Colors.white.withOpacity(0.05),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}