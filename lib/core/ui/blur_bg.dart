import 'dart:ui';
import 'package:flutter/material.dart';

class BlurBackground extends StatelessWidget {
  final Widget child;
  const BlurBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0B0B10),
                const Color(0xFF121225),
                cs.primary.withOpacity(0.18),
              ],
            ),
          ),
        ),
        // soft glow blobs
        Positioned(
          top: -120,
          left: -80,
          child: _Blob(color: cs.primary.withOpacity(0.25), size: 260),
        ),
        Positioned(
          bottom: -140,
          right: -100,
          child: _Blob(color: cs.secondary.withOpacity(0.18), size: 320),
        ),
        // blur layer
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(color: Colors.transparent),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
