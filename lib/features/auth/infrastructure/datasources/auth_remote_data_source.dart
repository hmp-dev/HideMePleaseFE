import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';

@lazySingleton
class AuthRemoteDataSource {
  final Network _network;

  const AuthRemoteDataSource(this._network);

  Future<String> authFirebaseLogin({required String firebaseIDToken}) async {
    debugPrint("firebaseIDToken");
    debugPrint(firebaseIDToken);
    debugPrint("firebaseIDToken");

    try {
      final response = await _network
          .post("auth/firebase/login", {"token": firebaseIDToken});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      throw Exception(
        'Something went wrong!',
      );
    } on Exception catch (e, t) {
      throw Exception('$e: $t');
    }
  }
}
