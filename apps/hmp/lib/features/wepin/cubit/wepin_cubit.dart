// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

part 'wepin_state.dart';

@lazySingleton
class WepinCubit extends BaseCubit<WepinState> {
  WepinCubit(this._secureStorage)
      : super(const WepinState(
            wepinLifeCycleStatus: WepinLifeCycle.notInitialized));

  final SecureStorage _secureStorage;

  WepinWidgetSDK? _wepinSDK;

  updateIsPerformWepinWelcomeNftRedeem(bool value) {
    emit(state.copyWith(
      isPerformWepinWelcomeNftRedeem: value,
    ));
  }

  Future<void> onConnectWepinWallet(BuildContext context) async {
    // get social login values
    await getSocialLoginValues();

    final status = await state.wepinWidgetSDK!.getStatus();
    "the lifecycle status is $status".log();

    // Update user's email and status if login is successful
    emit(state.copyWith(
      wepinLifeCycleStatus: status,
      isPerformWepinWalletSave: true,
      isLoading: true,
      error: '',
    ));

    if (state.wepinWidgetSDK != null) {
      switch (state.wepinLifeCycleStatus) {
        case WepinLifeCycle.notInitialized:
          // Optionally call login with Google if SDK initialization is successful
          initWepinSDK(selectedLanguageCode: context.locale.languageCode);
          break;

        case WepinLifeCycle.initialized:
          // Optionally call login with Google if SDK initialization is successful
          loginSocialAuthProvider();
          break;

        case WepinLifeCycle.loginBeforeRegister:
          registerToWepin(context);
          break;

        case WepinLifeCycle.login:
          fetchAccounts();
          break;

        default:
          // No action needed for other statuses
          break;
      }
    } else {
      initWepinSDK(selectedLanguageCode: context.locale.languageCode);
    }
  }

  Future<void> initWepinSDK({
    required String selectedLanguageCode,
    bool isFromWePinWalletConnect = false,
    bool isFromWePinWelcomeNftRedeem = false,
  }) async {
    "inside initWepinSDK ==>".log();

    String appId = sdkConfigs[0]['appId']!;
    String appKey = sdkConfigs[0]['appKey']!;

    await getSocialLoginValues();

    // Finalize any existing Wepin SDK instance
    _wepinSDK?.finalize();

    // Initialize a new Wepin SDK instance with provided appId, appKey, and privateKey
    if (isFromWePinWalletConnect) {
      emit(state.copyWith(
        wepinLifeCycleStatus: WepinLifeCycle.initializing,
        isPerformWepinWalletSave: true,
        isLoading: true,
        error: '',
      ));
    }

    if (isFromWePinWelcomeNftRedeem) {
      emit(state.copyWith(
        wepinLifeCycleStatus: WepinLifeCycle.initializing,
        isPerformWepinWelcomeNftRedeem: true,
        isLoading: true,
        error: '',
      ));
    }

    try {
      // Reinitialize the Wepin SDK
      _wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);

      // Initialize the SDK with specified attributes
      await _wepinSDK!.init(
        attributes: WidgetAttributes(
          defaultLanguage: selectedLanguageCode,
          defaultCurrency: 'KRW',
        ),
      );

      // Fetch the current status from Wepin SDK
      final wepinStatus = await _wepinSDK!.getStatus();

      // Emit the updated state with lifecycle, email, and other details
      emit(state.copyWith(
        wepinWidgetSDK: _wepinSDK,
        wepinLifeCycleStatus: wepinStatus,
      ));

      // Handle case if the SDK is not initialized properly
      if (wepinStatus == WepinLifeCycle.notInitialized) {
        emit(state.copyWith(error: 'WepinSDK is not initialized.'));
      } else {
        "inside initWepinSDK ==> $wepinStatus".log();
        //Optionally call login with Google if SDK initialization is successful

        "inside initWepinSDK ==> Calling loginSocialAuthProvider".log();
        loginSocialAuthProvider();
      }
    } catch (error) {
      // Handle any errors during SDK initialization
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> getSocialLoginValues() async {
    String socialTokenIsAppleOrGoogle =
        await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle) ??
            '';
    if (socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
      final appleIdTokenResult =
          await getIt<AuthCubit>().refreshAppleIdToken() ?? '';

      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        appleIdToken: appleIdTokenResult,
      ));
    }

    if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      final googleAccessTokenResult =
          await getIt<AuthCubit>().refreshGoogleAccessToken() ?? '';
      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        googleAccessToken: googleAccessTokenResult,
      ));
    }
  }

  Future<void> loginSocialAuthProvider() async {
    "loginSocialAuthProvider is called".log();

    try {
      LoginResult? fbToken;

      // Determine the login type and proceed accordingly
      if (state.socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
        fbToken = await _wepinSDK!.login.loginWithAccessToken(
            provider: 'google', accessToken: state.googleAccessToken);
      }

      // if Login Type is Apple
      if (state.socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
        fbToken = await _wepinSDK!.login
            .loginWithIdToken(idToken: state.appleIdToken);
      }

      if (fbToken != null) {
        final wepinUser = await _wepinSDK?.login.loginWepin(fbToken);

        if (wepinUser?.userInfo != null) {
          // Update user's email and status if login is successful
          final wepinStatus = await _wepinSDK!.getStatus();
          "inside loginSocialAuthProvider After login ==> wepinStatus is $wepinStatus"
              .log();
          emit(state.copyWith(
            wepinLifeCycleStatus: wepinStatus,
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            error: 'Login Failed. No user info found.',
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Login Failed. Invalid token.',
        ));
      }
    } catch (e) {
      // Handle errors excluding user-cancelled errors
      if (!e.toString().contains('UserCancelled')) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Login Failed. (error code - $e)',
        ));
      } else {
        emit(state.copyWith(
            isLoading: false)); // Set loading to false if user cancels
      }
    }
  }

  // Fetch accounts
  Future<void> fetchAccounts() async {
    try {
      final accounts = await state.wepinWidgetSDK!.getAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> saveAccounts(List<WepinAccount> accounts) async {
    emit(state.copyWith(accounts: accounts, isLoading: false));
  }

  closeWePinWidget() async {
    await state.wepinWidgetSDK!.closeWidget();
    await state.wepinWidgetSDK!.finalize();
  }

  updateIsWepinModelOpen(bool value) {
    emit(state.copyWith(isWepinModelOpen: value));
  }

  Future<void> registerToWepin(BuildContext context) async {
    emit(state.copyWith(
      isLoading: false,
      isWepinModelOpen: true,
    ));

    try {
      await state.wepinWidgetSDK!.register(context);

      // Update user's email and status if login is successful
      final wepinStatus = await state.wepinWidgetSDK!.getStatus();

      emit(state.copyWith(
        wepinLifeCycleStatus: wepinStatus,
        isLoading: false,
        isWepinModelOpen: false,
      ));
    } catch (e) {
      await state.wepinWidgetSDK!.closeWidget();
      await state.wepinWidgetSDK!.finalize();
      emit(state.copyWith(
          isLoading: false, isWepinModelOpen: false, error: e.toString()));
    }
  }

  /// Opens the Wepin widget based on the current status of the SDK.
  ///
  /// If the SDK is in the [WepinLifeCycle.login] state, the widget is opened
  /// immediately. If the SDK is in the [WepinLifeCycle.initialized] state, the
  /// user is first logged into Wepin using the saved social token, and then the
  /// widget is opened. If the SDK is in any other state, the widget is not
  /// opened.
  Future<void> openWepinWidget(BuildContext context,
      [bool isShowWidget = false]) async {
    if (state.isPerformWepinWalletSave || isShowWidget) {
      "inside openWepinWidget".log();
      showLoader();

      final wepinStatus = await state.wepinWidgetSDK!.getStatus();

      // log th status
      "inside openWepinWidget ==> wepinStatus is $wepinStatus".log();

      if (wepinStatus == WepinLifeCycle.login) {
        dismissLoader();
        await state.wepinWidgetSDK!.openWidget(context);
      }

      if (wepinStatus == WepinLifeCycle.notInitialized) {
        // if not initialized login into wepin
        await initWepinSDK(selectedLanguageCode: context.locale.languageCode);

        // again check status of wepin
        final wepinStatus = await state.wepinWidgetSDK!.getStatus();

        "inside openWepinWidget after ==> wepinStatus is $wepinStatus".log();
        dismissLoader();
        if (wepinStatus == WepinLifeCycle.login) {
          await state.wepinWidgetSDK!.openWidget(context);
        }
      }

      if (wepinStatus == WepinLifeCycle.initialized) {
        // if not initialized login into wepin
        await loginSocialAuthProvider();

        await Future.delayed(const Duration(milliseconds: 500));
        // again check status of wepin
        final wepinStatus = await state.wepinWidgetSDK!.getStatus();

        "inside openWepinWidget after loginSocialAuthProvider ==> wepinStatus is $wepinStatus"
            .log();
        dismissLoader();
        if (wepinStatus == WepinLifeCycle.login) {
          await state.wepinWidgetSDK!.openWidget(context);
        }
      }
    }
  }

  // Logout Wepin
  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));

    try {
      await state.wepinWidgetSDK!.login.logoutWepin();

      // Update user's email and status if login is successful
      final wepinStatus = await state.wepinWidgetSDK!.getStatus();

      emit(state.copyWith(
        wepinLifeCycleStatus: wepinStatus,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  updateWepinStatus(WepinLifeCycle newStatus) {
    emit(state.copyWith(wepinLifeCycleStatus: newStatus));
  }

  Future<void> updateWepinLifeCycleStatus() async {
    var status = await getIt<WepinCubit>().state.wepinWidgetSDK!.getStatus();

    "inside updateWepinLifeCycleStatus ==> the WepinSDK status is $status"
        .log();

    emit(state.copyWith(wepinLifeCycleStatus: status));
  }

  showLoader() {
    EasyLoading.show();
  }

  dismissLoader() {
    EasyLoading.dismiss();
  }

  onResetWepinSDKFetchedWallets() {
    emit(state.copyWith(
      accounts: [],
      isLoading: false,
      isPerformWepinWalletSave: false,
      error: '',
      wepinLifeCycleStatus: WepinLifeCycle.notInitialized,
    ));
  }
}
