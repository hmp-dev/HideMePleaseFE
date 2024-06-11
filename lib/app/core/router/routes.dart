import 'package:flutter/material.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/screens/app_screen.dart';
import 'package:mobile/features/app/presentation/screens/splash_screen.dart';
import 'package:mobile/features/app/presentation/screens/startup_screen.dart';
import 'package:mobile/features/auth/presentation/screens/social_auth_screen.dart';
import 'package:mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.onboardingScreen:
      return _route(const OnBoardingScreen());
    case Routes.splashScreen:
      return _route(const SplashScreen());
    case Routes.startUpScreen:
      return _route(const StartUpScreen());
    case Routes.socialLogin:
      return _route(const SocialAuthScreen());
    case Routes.appHome:
      return _route(const AppScreen());
    default:
      return null;
  }
}

Route<dynamic> _route(Widget page) {
  return MaterialPageRoute(builder: (_) => page);
}
