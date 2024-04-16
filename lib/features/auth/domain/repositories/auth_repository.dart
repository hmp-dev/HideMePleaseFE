import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';

abstract class AuthRepository {
  Future<Either<HMPError, String>> requestGoogleLogin();

  Future<Either<HMPError, String>> requestAppleLogin();

  Future<Either<HMPError, String>> requestWorldIdLogin();

  Future<Either<HMPError, String>> requestApiLogin(
      {required String firebaseToken});

  Future<Either<HMPError, Unit>> logOut();
}
