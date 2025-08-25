import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class OnboardingPageFirst extends StatelessWidget {
  const OnboardingPageFirst({super.key});

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
                    '이 세계를 즐기려면,',
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
                    '출입증이 하나 필요해!',
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
                '그건 바로 지갑이야.\n숨은 혜택을 확인하고 사용하기 위해서 꼭 필요하거든.\n개인 정보 제공 없이, 로그인만 하면 바로 만들 수 있어!',
                style: TextStyle(
                  fontFamily: 'LINESeedKR',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                  letterSpacing: -0.35,
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
                    'assets/images/onboarding20.png',
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