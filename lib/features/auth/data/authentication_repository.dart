import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/app/core/exceptions/log_out_failure.dart';
import 'package:mobile/app/core/exceptions/login_with_google_failure.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/cache_client.dart';
import 'package:mobile/features/auth/data/social_login_response_model.dart';

/// {@template authentication_repository}
/// Repository which manages user Firebase authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<SocialLoginResponseModel> logInWithGoogle() async {
    try {
      // logout if previously logged in
      // await logOut();

      final googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser!.authentication;

      ('googleAuth.accessToken: ${googleAuth.accessToken}').log();

      final socialLoginResponseModel = SocialLoginResponseModel(
        accessToken: googleAuth.accessToken ?? "",
        platform: 'google',
      );

      return socialLoginResponseModel;
    } on FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (e) {
      ("result of google login $e").log();

      throw LogInWithGoogleFailure("$e");
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}
