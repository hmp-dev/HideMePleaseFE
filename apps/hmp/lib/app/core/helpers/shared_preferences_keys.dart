import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesKeys {
  setStringData({required String key, required String text}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, text);
  }

  setIntData({required String key, required int id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, id);
  }

  setBoolData({required String key, required bool text}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, text);
  }

  Future<String?> getStringData({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<int?> getIntData({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<bool?> getBoolData({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future setLanguageType(Locale language) async {
    await setStringData(key: 'language_type', text: language.languageCode);
  }

  Future<Locale> getLanguageType() async {
    String? loc = await getStringData(key: 'language_type');
    return Locale(loc ?? "en");
  }
}
