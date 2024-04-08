import 'package:flutter/material.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/screens/app_screen.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.app:
      return _route(const AppScreen());

    default:
      return null;
  }
}

Route<dynamic> _route(Widget page) {
  return MaterialPageRoute(builder: (_) => page);
}
