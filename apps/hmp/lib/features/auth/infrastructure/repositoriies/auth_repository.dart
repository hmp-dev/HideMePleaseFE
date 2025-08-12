import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/exceptions/login_with_google_failure.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart' as helper;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
//import 'package:sendbird_uikit/sendbird_uikit.dart';

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
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = generateNonce();
      final nonce = helper.sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // save Social Login Type
      _localDataSource
          .setSocialTokenIsAppleOrGoogle(SocialLoginType.APPLE.name);
      // save id token in secure Storage
      _localDataSource.setAppleIdToken(oauthCredential.idToken ?? "");
      //===

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final getIdToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      return right(getIdToken ?? "");
    } catch (e, t) {
      ('inside Apple login Error:$e}').log();
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, String>> requestGoogleLogin() async {
    try {
      late final AuthCredential credential;

      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;

      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // save Social Login Type
      _localDataSource
          .setSocialTokenIsAppleOrGoogle(SocialLoginType.GOOGLE.name);

      // save Access token and ID token in secure Storage to be used wepin login
      _localDataSource.setGoogleAccessToken(googleAuth.accessToken ?? "");
      _localDataSource.setGoogleIdToken(googleAuth.idToken ?? ""); // For Wepin login
      //===

      await FirebaseAuth.instance.signInWithCredential(credential);

      final getIdToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      return right(getIdToken ?? "");

      //
    } on FirebaseAuthException catch (e) {
      final errorMsg = LogInWithGoogleFailure.fromCode(e.code);

      ("FirebaseAuthException error is: ${e.message}").log();
      ("FirebaseAuthException error is: ${e.code}").log();
      ("errorMsg: ${errorMsg.message}").log();

      FirebaseCrashlytics.instance.recordError(
        e,
        e.stackTrace,
        information: [
          'errorCode:$e',
          'errorMsg: $errorMsg',
        ],
      );

      return left(
        HMPError.fromNetwork(
          message: errorMsg.message,
        ),
      );
    } catch (e) {
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
  Future<Either<HMPError, Unit>> requestLogOut() async {
    try {
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        GoogleSignIn().signOut(),
        _localDataSource.deleteAll(),
    //SendbirdUIKit.disconnect(),
    //SendbirdChat.disconnect()
      ]);

      return right(unit);
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, Unit>> setAuthToken(String token) async {
    try {
      await _localDataSource.setAuthToken(token);

      return right(unit);
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
  Future<Either<HMPError, String>> getAuthToken() async {
    try {
      final response = await _localDataSource.getAuthToken();

      if (response == null) {
        return left(HMPError.fromNetwork(message: 'Not logged in.'));
      }

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
}


// https://id.worldcoin.org/login?response_type=token&response_mode=fragment&client_id=app_6e9ef9c3f36caeaa4a02cb834db32895&redirect_uri=https://www.google.com/&nonce=dkEmoy_ujfk7B8uTiQpp&ready=true&scope=openid&state=session_102030405060708090