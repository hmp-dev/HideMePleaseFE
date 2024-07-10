import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

enum BorderSideVal { left, right }

class CircleDotWidget extends StatelessWidget {
  const CircleDotWidget({
    super.key,
    required this.side,
  });

  final BorderSideVal side;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: CustomPaint(
        size: const Size(20.0, 20.0),
        painter: HalfBorderPainter(side: side),
      ),
    );
  }
}

class HalfBorderPainter extends CustomPainter {
  final BorderSideVal side;

  HalfBorderPainter({required this.side});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = scaffoldBg
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = fore4
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Draw the half border
    Path path = Path();
    if (side == BorderSideVal.left) {
      path.arcTo(
          Rect.fromLTWH(0, 0, size.width, size.height), -3.14 / 2, 3.14, false);
    } else {
      path.arcTo(
          Rect.fromLTWH(0, 0, size.width, size.height), 3.14 / 2, 3.14, false);
    }
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
