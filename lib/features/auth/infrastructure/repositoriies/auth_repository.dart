import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/exceptions/login_with_google_failure.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Either<HMPError, String>> requestAppleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      Log.info(credential);

      if (1 == 1) {
        return right("unit");
      }

      return left(HMPError.fromNetwork());
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, String>> requestGoogleLogin() async {
    try {
      late final firebase_auth.AuthCredential credential;

      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;
      credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final getIdToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      Log.info('getIdToken:$getIdToken}');
      debugPrint(getIdToken);

      return right(getIdToken ?? "");

      //
    } on firebase_auth.FirebaseAuthException catch (e) {
      final errorMsg = LogInWithGoogleFailure.fromCode(e.code);
      return left(
        HMPError.fromNetwork(
          message: errorMsg.message,
        ),
      );
    } catch (_) {
      return left(
        HMPError.fromNetwork(
          message: const LogInWithGoogleFailure().message,
        ),
      );
    }
  }

  @override
  Future<Either<HMPError, String>> requestWorldIdLogin() {
    // TODO: implement requestWorldIdLogin
    throw UnimplementedError();
  }

  @override
  Future<Either<HMPError, String>> requestApiLogin({
    required String firebaseToken,
  }) async {
    try {
      final response = await _remoteDataSource.authFirebaseLogin(
          firebaseIDToken: firebaseToken);

      await Future.wait([
        _localDataSource.setAuthToken(response),
      ]);

      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, Unit>> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  // @override
  // Future<Either<AuthError, VerifyOtpResponseDto>> verifyOtp({
  //   required String phoneNumber,
  //   required String otp,
  // }) async {
  //   try {
  //     final response = await _remoteDataSource.verifyOtp(
  //       phoneNumber: phoneNumber,
  //       otp: otp,
  //     );

  //     await Future.wait([
  //       _localDataSource.setAuthToken(response.accessToken!),
  //       if (response.userId != null)
  //         _localDataSource.setUserId(response.userId!),
  //     ]);

  //     return right(response);
  //   } on DioException catch (e, t) {
  //     if (e.response?.statusCode == 400) {
  //       return left(AuthError.fromNetwork(
  //         authErrorType: AuthErrorType.invalidOtp,
  //         message: e.response?.data['message'][0],
  //         error: e,
  //         trace: t,
  //       ));
  //     }

  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, Unit>> logOut() async {
  //   try {
  //     await _localDataSource.deleteAll();

  //     return right(unit);
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, Unit>> setAuthToken(String token) async {
  //   try {
  //     await _localDataSource.setAuthToken(token);

  //     return right(unit);
  //   } on DioException catch (e, t) {
  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, String>> getAuthToken() async {
  //   try {
  //     final response = await _localDataSource.getAuthToken();

  //     if (response == null) {
  //       return left(AuthError.fromNetwork(message: 'Not logged in.'));
  //     }

  //     return right(response);
  //   } on DioException catch (e, t) {
  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, ListTermsResponseDto>> getTerms() async {
  //   try {
  //     final response = await _remoteDataSource.getTerms();

  //     return right(response);
  //   } on DioException catch (e, t) {
  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, GetTermsDetailResponseDto>> getTermDetails(
  //     {required String termsId}) async {
  //   try {
  //     final response = await _remoteDataSource.getTermDetails(termsId: termsId);
  //     return right(response);
  //   } on DioException catch (e, t) {
  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, Unit>> compeleteSignUp() async {
  //   try {
  //     await _remoteDataSource.compeleteSignUp();

  //     return right(unit);
  //   } on DioException catch (e, t) {
  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }

  // @override
  // Future<Either<AuthError, Unit>> setAgreedTerms(List<String> termIds) async {
  //   try {
  //     final response = await _remoteDataSource.setAgreedTerms(termIds);

  //     if (response) {
  //       return right(unit);
  //     }

  //     return left(AuthError.fromNetwork());
  //   } on DioException catch (e, t) {
  //     return left(AuthError.fromNetwork(
  //       message: e.message,
  //       error: e,
  //       trace: t,
  //     ));
  //   } catch (e, t) {
  //     return left(AuthError.fromUnknown(
  //       error: e,
  //       trace: t,
  //     ));
  //   }
  // }
}
