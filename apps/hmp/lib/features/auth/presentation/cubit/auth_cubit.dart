// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
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

  Future<String?> refreshAppleIdToken() async {
    try {
      // Get the currently signed-in user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Force a refresh of the ID token
        final idToken = await user.getIdToken(true);

        // Save the refreshed ID token
        // save Social Login Type
        _localDataSource
            .setSocialTokenIsAppleOrGoogle(SocialLoginType.APPLE.name);
        //== to save access Token to be used for wepin login
        ("the Apple ID Token is: $idToken").log();
        // save id token in secure Storage
        _localDataSource.setAppleIdToken(idToken ?? "");
        //===

        return idToken;
      } else {
        // User is not signed in; you may need to prompt the user to sign in again
        return null;
      }
    } catch (e) {
      // Handle error (e.g., log it, or return a meaningful error message)
      ("Error refreshing Apple ID token: $e").log();
      return null;
    }
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

  Future<void> initWepinSDK() async {
    if (wepinSDK != null) {
      wepinSDK?.finalize();
    }

    wepinSDK = WepinWidgetSDK(
      wepinAppKey: sdkConfigs[0]['appKey'],
      wepinAppId: sdkConfigs[0]['appId'],
    );

    await wepinSDK!.init(
      attributes:
          WidgetAttributes(defaultLanguage: 'en', defaultCurrency: 'USD'),
    );

    wepinStatus = await wepinSDK!.getStatus();
    userEmail = wepinStatus == WepinLifeCycle.login
        ? (await wepinSDK!.login.getCurrentWepinUser())?.userInfo?.email ?? ''
        : '';

    emit(state.copyWith(wepinSDK: wepinSDK)); // Update state with SDK

    if (wepinStatus == WepinLifeCycle.notInitialized) {
      ('WepinSDK is not initialized.').log();
    }
  }

  // Future<void> loginToWepin() async {
  //   final socialLoginToken =
  //       await getIt<AuthLocalDataSource>().getGoogleAccessToken();
  //   "the idToken passing to Wepin is $socialLoginToken".log();

  //   if (state.wepinSDK != null) {
  //     try {
  //       LoginResult? fbToken;

  //       // if Platform is Google
  //       if (Platform.isAndroid) {
  //         fbToken = await state.wepinSDK!.login.loginWithAccessToken(
  //             provider: 'google', accessToken: socialLoginToken ?? "");
  //       }

  //       if (Platform.isIOS) {
  //         fbToken = await state.wepinSDK!.login
  //             .loginWithIdToken(idToken: socialLoginToken ?? "");
  //       }

  //       if (fbToken != null) {
  //         final wepinUser = await state.wepinSDK?.login.loginWepin(fbToken);

  //         if (wepinUser != null && wepinUser.userInfo != null) {
  //           userEmail = wepinUser.userInfo!.email; // Update user's email
  //           wepinStatus = await state.wepinSDK!.getStatus(); // Get wepin status
  //         } else {
  //           ('Login Failed. No user info found.').log();
  //         }
  //       } else {
  //         ('Login Failed. Invalid token.').log();
  //       }
  //     } catch (e) {
  //       if (!e.toString().contains('UserCancelled')) {
  //         ('Login Failed. (error code - $e)').log();
  //       }
  //     }
  //   } else {
  //     ('WepinSDK is not initialized.').log();
  //   }
  // }

  Future<void> loginToWepin() async {
    // Get the Google access token from local storage
    final socialLoginToken =
        await getIt<AuthLocalDataSource>().getGoogleAccessToken();
    "the idToken passing to Wepin is $socialLoginToken".log();

    if (socialLoginToken == null || socialLoginToken.isEmpty) {
      'Google access token is null or empty.'.log();
      emit(state.copyWith(
        message: 'Failed to get Google token',
        submitStatus: RequestStatus.failure,
      ));
      return;
    }

    // Ensure SDK is initialized before proceeding
    if (state.wepinSDK == null) {
      'WepinSDK is not initialized.'.log();
      emit(state.copyWith(
        message: 'WepinSDK is not initialized',
        submitStatus: RequestStatus.failure,
      ));
      return;
    }

    try {
      // LoginResult? fbToken;
      'inside Try Login. ${state.wepinSDK?.domain}'.log();
      // if Platform is Google (Android and iOS specific implementations)
      // if (Platform.isAndroid) {
      //   fbToken = await state.wepinSDK!.login.loginWithAccessToken(
      //     provider: 'google',
      //     accessToken: socialLoginToken,
      //   );
      // } else if (Platform.isIOS) {
      //   fbToken = await state.wepinSDK!.login
      //       .loginWithIdToken(idToken: socialLoginToken);
      // }

      LoginResult fbToken = await state.wepinSDK!.login.loginWithAccessToken(
        provider: 'google',
        accessToken: socialLoginToken,
      );

      // if (fbToken == null) {
      //   'Login Failed. Invalid token.'.log();
      //   emit(state.copyWith(
      //     message: 'Login Failed. Invalid token.',
      //     submitStatus: RequestStatus.failure,
      //   ));
      //   return;
      // }

      // Proceed with Wepin login
      final wepinUser = await state.wepinSDK?.login.loginWepin(fbToken);

      if (wepinUser != null && wepinUser.userInfo != null) {
        userEmail = wepinUser.userInfo!.email;
        wepinStatus = await state.wepinSDK!.getStatus();

        'Login successful!'.log();
        'After login into Wepin $userEmail'.log();
        'inside Try Login. $wepinStatus'.log();

        emit(
          state.copyWith(
            message: 'Login successful!',
            submitStatus: RequestStatus.success,
          ),
        );
      } else {
        'Login Failed. No user info found.'.log();
        emit(state.copyWith(
          message: 'Login Failed. No user info found.',
          submitStatus: RequestStatus.failure,
        ));
      }
    } catch (e) {
      if (!e.toString().contains('UserCancelled')) {
        ('Login Failed. (error code - $e)').log();
      }
      emit(state.copyWith(
        message: 'Login Failed: $e',
        submitStatus: RequestStatus.failure,
      ));
    }
  }
}
