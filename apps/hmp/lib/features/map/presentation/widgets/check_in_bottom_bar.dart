import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture 사용을 위해 추가
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

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
    this.isHomeActive = true,
    this.isMapActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 30, // 화면 하단에서 30px 띄우기
        left: 30, // 좌측 여백 30px
        right: 30, // 우측 여백 30px
      ),
      child: Center(
        child: SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 블러 효과
              child: CustomPaint(
                painter: _GradientBorderPainter(),
                child: Container(
                  height: 72, // 높이 72로 변경
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withOpacity(0.7), // 흰색 70% 불투명도
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0xFF132E41),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 왼쪽: 홈과 숨을곳 버튼
                        Row(
                          children: [
                            // 홈 버튼
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                onTap: onHomeTap,
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Opacity(
                                        opacity: isHomeActive ? 1.0 : 0.4,
                                        child: Image.asset(
                                          'assets/icons/map_bottom_icon_home.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        LocaleKeys.nav_home.tr(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: const Color(0xFF132E41)
                                              .withOpacity(
                                                  isHomeActive ? 1.0 : 0.4),
                                          fontWeight: isHomeActive
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
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
                                    Opacity(
                                      opacity: isMapActive ? 1.0 : 0.4,
                                      child: Image.asset(
                                        'assets/icons/map_bottom_icon_map.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      LocaleKeys.nav_hiding.tr(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: const Color(0xFF132E41)
                                            .withOpacity(
                                                isMapActive ? 1.0 : 0.4),
                                        fontWeight: isMapActive
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        // CHECK-IN 버튼
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: GestureDetector(
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