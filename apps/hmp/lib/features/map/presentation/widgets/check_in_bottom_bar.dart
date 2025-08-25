import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture 사용을 위해 추가

class CheckInBottomBar extends StatelessWidget {
  final VoidCallback? onMapTap;
  final VoidCallback? onMyTap;
  final VoidCallback? onCheckInTap;

  const CheckInBottomBar({
    Key? key,
    this.onMapTap,
    this.onMyTap,
    this.onCheckInTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF19BAFF).withOpacity(0.3),
              const Color(0xFF19BAFF).withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF19BAFF).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            // 지도 버튼
            _buildBottomBarButton(
              svgPath: 'assets/icons/map_bottom_icon_map.svg',
              onTap: onMapTap,
            ),
            
            // MY 버튼
            _buildBottomBarButton(
              svgPath: 'assets/icons/map_bottom_icon_my.svg',
              onTap: onMyTap,
              iconColor: Colors.grey[400],
            ),
            
            // CHECK-IN 버튼
            _buildCheckInButton(),
          ],
        ),
      ),
    ), // 이 괄호가 Container 위젯의 닫는 괄호입니다.
  );
}

  Widget _buildBottomBarButton({
    required String svgPath,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        colorFilter: iconColor != null ? ColorFilter.mode(iconColor, BlendMode.srcIn) : null,
        width: 48,
        height: 48,
      ),
    );
  }

  Widget _buildCheckInButton() {
    return GestureDetector(
      onTap: onCheckInTap,
      child: SvgPicture.asset(
        'assets/icons/map_bottom_icon_checkin.svg', // SVG 파일 경로
        width: 48, // 아이콘 크기
        height: 48,
      ),
    );
  }
}
