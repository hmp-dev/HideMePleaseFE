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
          color: Colors.grey[800]?.withOpacity(0.9),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            // 지도 버튼
            _buildBottomBarButton(
              icon: Icons.map_outlined,
              label: '지도',
              onTap: onMapTap,
            ),
            
            // MY 버튼
            _buildBottomBarButton(
              icon: Icons.person_outline,
              label: 'MY',
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
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[700]?.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInButton() {
    return GestureDetector(
      onTap: onCheckInTap,
      child: Container(
        width: 110,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3F7), // 밝은 파란색
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_check_in_icon.svg', // SVG 파일 경로
              width: 18, // 아이콘 크기
              height: 18,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn), // 아이콘 색상
            ),
            const SizedBox(width: 6),
            const Text(
              'CHECK-IN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}