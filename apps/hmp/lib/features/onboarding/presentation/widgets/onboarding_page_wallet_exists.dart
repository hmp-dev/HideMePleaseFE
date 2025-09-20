import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/generated/locale_keys.g.dart';

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  LocaleKeys.onboarding_wallet_exists_title1.tr(),
                  style: const TextStyle(
                    fontFamily: 'LINESeedKR',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  LocaleKeys.onboarding_wallet_exists_title2.tr(),
                  style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              LocaleKeys.onboarding_wallet_exists_desc.tr(),
              style: const TextStyle(
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