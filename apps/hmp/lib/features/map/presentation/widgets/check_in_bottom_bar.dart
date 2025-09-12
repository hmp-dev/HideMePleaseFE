import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture 사용을 위해 추가
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class CheckInBottomBar extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onMapTap;
  final Future<void> Function()? onCheckInTap;
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
  State<CheckInBottomBar> createState() => _CheckInBottomBarState();
}

class _CheckInBottomBarState extends State<CheckInBottomBar> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 30, // 화면 하단에서 30px 띄우기
      ),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 40, // 컨텐츠와 동일한 너비 (좌우 20px 마진)
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 블러 효과
              child: CustomPaint(
                painter: _GradientBorderPainter(),
                child: Container(
                  height: 72, // 높이 72로 변경
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12), // 흰색 12% 불투명도
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Color(0xFF132E41),
                      width: 1,
                    ),
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
                          onTap: widget.onHomeTap,
                          child: SizedBox(
                            width: 48,
                            height: 63,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: widget.isHomeActive ? 1.0 : 0.4,
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
                                    fontSize: 13,
                                    color: Color(0xFF132E41).withOpacity(widget.isHomeActive ? 1.0 : 0.4),
                                    fontWeight: widget.isHomeActive ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 숨을곳 버튼
                        GestureDetector(
                          onTap: widget.onMapTap,
                          child: SizedBox(
                            width: 48,
                            height: 63,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: widget.isMapActive ? 1.0 : 0.4,
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
                                    fontSize: 13,
                                    color: Color(0xFF132E41).withOpacity(widget.isMapActive ? 1.0 : 0.4),
                                    fontWeight: widget.isMapActive ? FontWeight.w600 : FontWeight.normal,
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
                      onTap: _isProcessing 
                          ? null 
                          : () async {
                              if (widget.onCheckInTap != null) {
                                setState(() {
                                  _isProcessing = true;
                                });
                                try {
                                  await widget.onCheckInTap!();
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                  }
                                }
                              }
                            },
                      child: AnimatedOpacity(
                        opacity: _isProcessing ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: 136,
                          height: 46,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/map_bottom_icon_checkin.svg',
                                fit: BoxFit.contain,
                              ),
                              if (_isProcessing)
                                Container(
                                  width: 136,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF132E41)),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
