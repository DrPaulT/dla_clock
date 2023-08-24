import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// I don't know if the shader uses filter parameters.
// Ideally we would disable any bilinear filtering or mipmapping.
final _paint = Paint()
  ..isAntiAlias = false
  ..filterQuality = FilterQuality.none;

class DlaPainter extends CustomPainter {
  DlaPainter({required this.shader, required this.angle, required this.scale});

  final ui.FragmentShader shader;
  final double angle;
  final double scale;
  Rect? _rect;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.shader = shader;
    _rect ??= Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale / 2);
    canvas.rotate(angle);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRect(_rect!, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
