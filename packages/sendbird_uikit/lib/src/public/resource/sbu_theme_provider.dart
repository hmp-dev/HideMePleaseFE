// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/widgets.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_preferences.dart';

/// SBUTheme
enum SBUTheme {
  light,
  dark,
}

/// SBUThemeProvider
class SBUThemeProvider with ChangeNotifier {
  SBUTheme _theme = SBUTheme.light;

  SBUThemeProvider._();

  static final SBUThemeProvider _provider = SBUThemeProvider._();

  factory SBUThemeProvider() => _provider;

  /// Sets theme.
  Future<void> setTheme(SBUTheme theme) async {
    if (_theme != theme) {
      _theme = theme;
      await SBUPreferences().setDarkTheme(_theme == SBUTheme.dark);
      notifyListeners();
    }
  }

  /// Gets theme.
  SBUTheme get theme {
    _theme = SBUPreferences().getDarkTheme() ? SBUTheme.dark : SBUTheme.light;
    return _theme;
  }

  /// Returns `true` if theme is light.
  bool isLight() {
    _theme = SBUPreferences().getDarkTheme() ? SBUTheme.dark : SBUTheme.light;
    return _theme == SBUTheme.light;
  }

  /// Returns `true` if theme is dark.
  bool isDark() {
    _theme = SBUPreferences().getDarkTheme() ? SBUTheme.dark : SBUTheme.light;
    return _theme == SBUTheme.dark;
  }

  /// Toggles current theme.
  void toggleTheme() {
    if (_theme == SBUTheme.light) {
      setTheme(SBUTheme.dark);
    } else {
      setTheme(SBUTheme.light);
    }
  }
}
