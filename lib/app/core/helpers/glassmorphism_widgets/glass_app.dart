import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_theme.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_theme_data.dart';

/// A widget that provides a GlassTheme for its descendants.
class GlassApp extends StatelessWidget {
  GlassApp({super.key, GlassThemeData? theme, this.home})
      : theme = theme ?? GlassThemeData();
  @override
  Widget build(BuildContext context) {
    return GlassTheme(data: theme, child: home ?? Container());
  }

  final GlassThemeData theme;
  final Widget? home;
}
