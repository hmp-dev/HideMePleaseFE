import 'package:flutter/material.dart';

// 간단한 테스트 위젯 - 모든 onboarding 페이지를 이것으로 교체해서 테스트
class TestOnboardingWidget extends StatelessWidget {
  final String title;
  
  const TestOnboardingWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF87CEEB),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}