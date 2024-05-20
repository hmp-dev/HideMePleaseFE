import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_theme_data.dart';

/// A widget that provides a GlassThemeData for its descendants.
class GlassTheme extends StatelessWidget {
  const GlassTheme({
    super.key,
    required this.data,
    required this.child,
  });
  final Widget child;
  final GlassThemeData data;
  static final GlassThemeData _kFallbackTheme = GlassThemeData.fallback();

  static GlassThemeData of(BuildContext context) {
    final _InheritedGlassTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedGlassTheme>();
    final GlassThemeData theme = inheritedTheme?.theme.data ?? _kFallbackTheme;
    return GlassThemeData.localize(theme);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedGlassTheme(
      theme: this,
      child: child,
    );
  }
}

class _InheritedGlassTheme extends InheritedWidget {
  const _InheritedGlassTheme({
    super.key,
    required this.theme,
    required super.child,
  });
  final GlassTheme theme;

  @override
  bool updateShouldNotify(_InheritedGlassTheme old) =>
      theme.data != old.theme.data;
}
