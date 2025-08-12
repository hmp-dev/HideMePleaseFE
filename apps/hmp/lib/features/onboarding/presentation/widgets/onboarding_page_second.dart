import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class OnboardingPageSecond extends StatelessWidget {
  const OnboardingPageSecond({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF87CEEB), // Sky blue background
      child: Column(
          children: [
            const SizedBox(height: 10),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    '하미플 세계에 온 걸',
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '환영해!',
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                '여긴 하이더들이 살아가는 작은 세계야.\n복잡한 리뷰도, 쿠폰도 필요 없어. 하이더들은 그냥\n방문만 해도 다양한 보상을 받을 수 있어 :)',
                style: TextStyle(
                  fontFamily: 'LINESeedKR',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // Main illustration
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    'assets/images/onboarding10.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}