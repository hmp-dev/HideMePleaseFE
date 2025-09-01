import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture 사용을 위해 추가

class CheckInBottomBar extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onMapTap;
  final VoidCallback? onCheckInTap;
  final bool isHomeActive;
  final bool isMapActive;

  const CheckInBottomBar({
    Key? key,
    this.onHomeTap,
    this.onMapTap,
    this.onCheckInTap,
    this.isHomeActive = false,
    this.isMapActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 30, // 화면 하단에서 30px 띄우기
      ),
      child: Center(
        child: SizedBox(
          width: 324, // 고정 너비 324px
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 블러 효과
              child: CustomPaint(
                painter: _GradientBorderPainter(),
                child: Container(
                  height: 72, // 높이 72로 변경
                  decoration: BoxDecoration(
                    color: const Color(0x4D19BAFF), // #19BAFF4D 배경색
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    // 왼쪽: 홈과 숨을곳 버튼
                    Row(
                      children: [
                        // 홈 버튼
                        GestureDetector(
                          onTap: onHomeTap,
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  color: isHomeActive ? Colors.white : Colors.grey[400],
                                  size: 24,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '홈',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isHomeActive ? Colors.white : Colors.grey[400],
                                    fontWeight: isHomeActive ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 숨을곳 버튼
                        GestureDetector(
                          onTap: onMapTap,
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: isMapActive ? Colors.white : Colors.grey[400],
                                  size: 24,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '숨을곳',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isMapActive ? Colors.white : Colors.grey[400],
                                    fontWeight: isMapActive ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                        const SizedBox(width: 20),
                        // CHECK-IN 버튼
                    GestureDetector(
                      onTap: onCheckInTap,
                      child: SizedBox(
                        width: 136,
                        height: 46,
                        child: SvgPicture.asset(
                          'assets/icons/map_bottom_icon_checkin.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

// 그라데이션 테두리를 위한 CustomPainter
class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(36));
    
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFFFFF), // #FFFFFF
          const Color(0xFFC2C2C2), // #C2C2C2
          const Color(0xFFE1E1E1), // #E1E1E1
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
