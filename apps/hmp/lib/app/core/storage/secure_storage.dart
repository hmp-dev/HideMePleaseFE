import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@singleton
class SecureStorage {
  final FlutterSecureStorage _flutterSecureStorage;

  const SecureStorage() : _flutterSecureStorage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _flutterSecureStorage.write(
      key: key,
      value: value,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String?> read(String key) async {
    return await _flutterSecureStorage.read(
      key: key,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> delete(String key) async {
    await _flutterSecureStorage.delete(
      key: key,
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> deleteAll() async {
    await _flutterSecureStorage.deleteAll(
      aOptions: _getAndroidOptions(),
    );
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}
