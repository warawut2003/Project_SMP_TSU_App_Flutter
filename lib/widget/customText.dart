import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TextWithBorderPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double borderWidth;
  final Color borderColor;

  TextWithBorderPainter({
    required this.text,
    required this.style,
    this.borderWidth = 2.0,
    this.borderColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset.zero;
    textPainter.paint(canvas, offset);

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final textRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      textPainter.width,
      textPainter.height,
    );

    canvas.drawRect(textRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
