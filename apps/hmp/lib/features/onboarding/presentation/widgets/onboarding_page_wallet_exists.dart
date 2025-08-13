import 'package:flutter/material.dart';

/// Widget shown when user already has a Wepin wallet
class OnboardingPageWalletExists extends StatelessWidget {
  const OnboardingPageWalletExists({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF87CEEB),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  '오, 너는 이미',
                  style: TextStyle(
                    fontFamily: 'LINESeedKR',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '위핀지갑을 가지고 있네!',
                  style: TextStyle(
                    fontFamily: 'LINESeedKR',
                    fontSize: 32,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              '하미플 세계에선 지갑이 출입증이야.\n숨은 혜택을 확인하고 사용하기 위해서 꼭 필요하거든.\n이미 지갑이 있다니 멋진데!',
              style: TextStyle(
                fontFamily: 'LINESeedKR',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.5,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          // Main illustration - same as OnboardingPageFirst
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