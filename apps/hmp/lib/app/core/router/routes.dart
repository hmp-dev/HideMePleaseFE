import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/screens/app_screen.dart';
import 'package:mobile/features/app/presentation/screens/splash_screen.dart';
import 'package:mobile/features/app/presentation/screens/start_up_screen.dart';
import 'package:mobile/features/app/presentation/views/server_error_page.dart';
import 'package:mobile/features/auth/presentation/screens/social_auth_screen.dart';
import 'package:mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:talker_flutter/talker_flutter.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.onboardingScreen:
      return _route(
        Routes.onboardingScreen,
        const OnBoardingScreen(),
      );

    case Routes.splashScreen:
      return _route(
        Routes.splashScreen,
        const SplashScreen(),
      );

    case Routes.startUpScreen:
      return _route(
        Routes.startUpScreen,
        const StartUpScreen(),
      );
    case Routes.socialLogin:
      return _route(
        Routes.socialLogin,
        const SocialAuthScreen(),
      );
    case Routes.appScreen:
      return _route(
        Routes.appScreen,
        const AppScreen(),
      );
    case Routes.serverErrorPage:
      return _route(
        Routes.serverErrorPage,
        const ServeErrorPage(),
      );
    case Routes.talker:
      return _route(
        Routes.talker,
        TalkerScreen(
          talker: getIt<Talker>(),
          theme: talkerTheme,
        ),
      );
    default:
      return null;
  }
}

Route<dynamic> _route(String name, Widget page) {
  return MaterialPageRoute(
    builder: (_) => page,
    settings: RouteSettings(name: name),
  );
}
