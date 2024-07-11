import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(
        painter: DashedLinePainter(
          dashWidth: 7.0,
          dashSpace: 7.0,
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Paint _paint;

  DashedLinePainter({
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    Color color = fore4,
  }) : _paint = Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final double endX = size.width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        _paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
