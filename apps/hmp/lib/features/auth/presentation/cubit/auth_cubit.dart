// ignore_for_file: unused_field

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit(this._authRepository, this._localDataSource)
      : super(AuthState.initial());

  final AuthRepository _authRepository;
  final AuthLocalDataSource _localDataSource;

  // Declare wepinSDK here
  WepinWidgetSDK? wepinSDK;
  WepinLifeCycle wepinStatus = WepinLifeCycle.notInitialized;
  String userEmail = '';

  Future<void> onGoogleLogin() async {
    final result = await _authRepository.requestGoogleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) {
        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<String?> refreshGoogleAccessToken() async {
    try {
      // Check if the user is already signed in
      final googleSignIn = GoogleSignIn();
      final googleUser =
          googleSignIn.currentUser ?? await googleSignIn.signInSilently();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        // save Social Login Type
        _localDataSource
            .setSocialTokenIsAppleOrGoogle(SocialLoginType.GOOGLE.name);

        //== to save access Token to be used for wepin login
        ("the Google Access Toke is: ${googleAuth.accessToken}").log();
        // Save the refreshed access token
        _localDataSource.setGoogleAccessToken(googleAuth.accessToken ?? "");
        //===

        return googleAuth.accessToken;
      } else {
        // User is not signed in; you may need to prompt the user to sign in again
        return null;
      }
    } catch (e) {
      // Handle error (e.g., log it, or return a meaningful error message)
      ("Error refreshing Google access token: $e").log();
      return null;
    }
  }

  Future<void> onAppleLogin() async {
    final result = await _authRepository.requestAppleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) {
        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<void> onWorldIdLogin() async {}
  Future<void> onBackendApiLogin({
    required String firebaseIdToken,
  }) async {
    //
    EasyLoading.show();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response =
        await _authRepository.requestApiLogin(firebaseToken: firebaseIdToken);

    EasyLoading.dismiss();

    //
    response.fold(
      (err) {
        "inside error ****************** ${err.message}".log();
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          isLogInSuccessful: false,
          message: err.message,
        ));
      },
      (success) => emit(
        state.copyWith(
          submitStatus: RequestStatus.success,
          isLogInSuccessful: true,
          message: '',
        ),
      ),
    );
  }

  // wepin related functions
}
