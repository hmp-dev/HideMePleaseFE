import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';

@lazySingleton
class AuthLocalDataSource {
  final SecureStorage _secureStorage;

  const AuthLocalDataSource(this._secureStorage);

  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(StorageValues.accessToken, token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(StorageValues.accessToken);
  }

  Future<void> setSocialTokenIsAppleOrGoogle(
      String socialTokenIsAppleOrGoogle) async {
    await _secureStorage.write(
        StorageValues.socialTokenIsAppleOrGoogle, socialTokenIsAppleOrGoogle);
  }

  Future<String?> getSocialTokenIsAppleOrGoogle() async {
    return await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle);
  }

  Future<void> setGoogleAccessToken(String accessToken) async {
    await _secureStorage.write(StorageValues.googleAccessToken, accessToken);
  }

  Future<String?> getGoogleAccessToken() async {
    return await _secureStorage.read(StorageValues.googleAccessToken);
  }

  Future<void> setAppleIdToken(String idToken) async {
    await _secureStorage.write(StorageValues.appleIdToken, idToken);
  }

  Future<String?> getAppleIdToken() async {
    return await _secureStorage.read(StorageValues.appleIdToken);
  }

  Future<void> setUserId(String userId) async {
    await _secureStorage.write(StorageValues.userId, userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(StorageValues.userId);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
