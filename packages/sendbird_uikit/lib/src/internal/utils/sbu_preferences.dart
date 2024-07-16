// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:shared_preferences/shared_preferences.dart';

class SBUPreferences {
  static const String prefDarkTheme = 'prefDartTheme';
  static const String prefPushNotifications = 'prefPushNotifications';
  static const String prefDoNotDisturb = 'prefDoNotDisturb';

  SBUPreferences._();

  static final SBUPreferences _instance = SBUPreferences._();

  factory SBUPreferences() => _instance;

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> clear() async {
    await SBUPreferences().removeDarkTheme();
    await SBUPreferences().removePushNotifications();
    await SBUPreferences().removeDoNotDisturb();
  }

  // Dark theme
  Future<bool> setDarkTheme(bool value) async {
    return await _prefs.setBool(prefDarkTheme, value);
  }

  bool getDarkTheme() {
    return _prefs.getBool(prefDarkTheme) ?? false;
  }

  Future<bool> removeDarkTheme() async {
    return await _prefs.remove(prefDarkTheme);
  }

  // Push notifications
  Future<bool> setPushNotifications(bool value) async {
    return await _prefs.setBool(prefPushNotifications, value);
  }

  bool getPushNotifications() {
    return _prefs.getBool(prefPushNotifications) ?? false;
  }

  Future<bool> removePushNotifications() async {
    return await _prefs.remove(prefPushNotifications);
  }

  // Do not disturb
  Future<bool> setDoNotDisturb(bool value) async {
    return await _prefs.setBool(prefDoNotDisturb, value);
  }

  bool getDoNotDisturb() {
    return _prefs.getBool(prefDoNotDisturb) ?? false;
  }

  Future<bool> removeDoNotDisturb() async {
    return await _prefs.remove(prefDoNotDisturb);
  }
}
