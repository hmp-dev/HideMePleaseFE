import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

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
                    LocaleKeys.onboarding_new_title2_line1.tr(),
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
                    LocaleKeys.onboarding_new_title2_line2.tr(),
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
                LocaleKeys.onboarding_new_desc2.tr(),
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