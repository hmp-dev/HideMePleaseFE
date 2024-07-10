import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';

abstract class AuthRepository {
  Future<Either<HMPError, String>> getAuthToken();
  Future<Either<HMPError, Unit>> setAuthToken(String token);

  Future<Either<HMPError, String>> requestGoogleLogin();

  Future<Either<HMPError, String>> requestAppleLogin();

  Future<Either<HMPError, String>> requestWorldIdLogin();

  Future<Either<HMPError, String>> requestApiLogin(
      {required String firebaseToken});

  Future<Either<HMPError, Unit>> requestLogOut();
}
