// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

part 'wepin_state.dart';

@lazySingleton
class WepinCubit extends BaseCubit<WepinState> {
  WepinCubit(this._secureStorage)
      : super(const WepinState(
            wepinLifeCycleStatus: WepinLifeCycle.notInitialized));

  final SecureStorage _secureStorage;

  Future<void> initializeWepinSDK(
      {required String selectedLanguageCode}) async {
    "inside initWepinSDK ==>".log();

    String appId = sdkConfigs[0]['appId']!;
    String appKeyAndroid = sdkConfigs[0]['appKeyAndroid']!;
    String appKeyApple = sdkConfigs[0]['appKeyApple']!;

    await getSocialLoginValues();

    // Finalize any existing Wepin SDK instance
    //state.wepinWidgetSDK?.finalize();

    try {
      if (Platform.isAndroid) {
        emit(state.copyWith(
          wepinWidgetSDK:
              WepinWidgetSDK(wepinAppKey: appKeyAndroid, wepinAppId: appId),
        ));
      }

      if (Platform.isIOS) {
        emit(state.copyWith(
          wepinWidgetSDK:
              WepinWidgetSDK(wepinAppKey: appKeyApple, wepinAppId: appId),
        ));
      }

      // Initialize the SDK with specified attributes
      await state.wepinWidgetSDK!.init(
        attributes: WidgetAttributes(
          defaultLanguage: selectedLanguageCode,
          defaultCurrency: 'KRW',
        ),
      );

      // Fetch the current status from Wepin SDK
      final wepinStatus = await state.wepinWidgetSDK!.getStatus();

      // Emit the updated state with lifecycle, email, and other details
      emit(state.copyWith(
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

  // requirement for this function is to save wepin wallet inside HMP Backend

  // wepin has following lifecycle status, I can get wallets only when in login status
  // notInitialized, // 'not_initialized'
  // initializing,   // 'initializing'
  // initialized,    // 'initialized'
  // beforeLogin,    // 'before_login'
  // login,          // 'login'
  // loginBeforeRegister, // 'login_before_register'

  // if "initialized" then perform login to wepin
  // if "before_login" then perform register to wepin
  // if "login_before_register" then perform register to wepin
  // wait for register to wepin and then fetch wallets to save in HMP backend
  Future<void> onConnectWepinWallet(
    BuildContext context, {
    bool isFromWePinWalletConnect = false,
    bool isFromWePinWelcomeNftRedeem = false,
    bool isOpenWepinModel = false,
  }) async {
    if (isFromWePinWalletConnect) {
      emit(state.copyWith(isPerformWepinWalletSave: true));
    }

    if (isFromWePinWelcomeNftRedeem) {
      emit(state.copyWith(isPerformWepinWelcomeNftRedeem: true));
    }
    // get social login values
    await getSocialLoginValues();

    // Log initial lifecycle status
    "the initial lifecycle status is ${state.wepinLifeCycleStatus}".log();

    // Get updated lifecycle status from Wepin SDK
    final status = await state.wepinWidgetSDK!.getStatus();

    "the lifecycle status from state.wepinWidgetSDK!.getStatus() is $status"
        .log();

    // Update lifecycle status in state
    emit(state.copyWith(
      wepinLifeCycleStatus: status,
      isPerformWepinWalletSave: true,
      isLoading: true,
      error: '',
    ));

    // Perform actions based on lifecycle status
    if (status == WepinLifeCycle.initialized) {
      // Perform login if status is 'initialized'
      await loginSocialAuthProvider();
      "Performed login to Wepin".log();
    } else if (status == WepinLifeCycle.beforeLogin ||
        status == WepinLifeCycle.loginBeforeRegister) {
      // Perform registration if status is 'before_login' or 'login_before_register'
      await state.wepinWidgetSDK!.register(context);
      "Performed registration to Wepin".log();
    }

    // Check status again after attempting login or registration
    final updatedStatus = await state.wepinWidgetSDK!.getStatus();
    "Updated lifecycle status after login/register attempt is $updatedStatus"
        .log();

    // If login is successful, fetch wallets and save them to HMP backend
    if (updatedStatus == WepinLifeCycle.login) {
      try {
        final wallets = await state.wepinWidgetSDK!.getAccounts();
        await saveWalletsToHMPBackend(wallets);

        "Wallets successfully saved to HMP backend".log();
        emit(state.copyWith(
          isPerformWepinWalletSave: false,
          isLoading: false,
          error: '',
        ));
      } catch (e) {
        "Failed to save wallets to HMP backend: $e".log();
        emit(state.copyWith(
          isPerformWepinWalletSave: false,
          isLoading: false,
          error: 'Failed to save wallets to HMP backend',
        ));
      }
    } else {
      "Cannot fetch wallets, login status is $updatedStatus".log();

      if (updatedStatus == WepinLifeCycle.loginBeforeRegister) {
        dismissLoader();
        // Perform registration if status is 'login_before_register'
        await state.wepinWidgetSDK!.register(context);

        // Check status again after attempting login or registration
        final updatedStatus = await state.wepinWidgetSDK!.getStatus();
        "Updated lifecycle status after login/register attempt is $updatedStatus"
            .log();

        // If login is successful, fetch wallets and save them to HMP backend

        if (updatedStatus == WepinLifeCycle.login) {
          try {
            final wallets = await state.wepinWidgetSDK!.getAccounts();
            await saveWalletsToHMPBackend(wallets);

            "Wallets successfully saved to HMP backend".log();
            emit(state.copyWith(
              isPerformWepinWalletSave: false,
              isLoading: false,
              error: '',
            ));
          } catch (e) {
            "Failed to save wallets to HMP backend: $e".log();
            emit(state.copyWith(
              isPerformWepinWalletSave: false,
              isLoading: false,
              error: 'Failed to save wallets to HMP backend',
            ));
          }
        }
      }
    }

    if (isOpenWepinModel) {
      await Future.delayed(const Duration(milliseconds: 100));
      emit(state.copyWith(isLoading: false));
      dismissLoader();
      await openWepinWidget(context);
    } else {
      dismissLoader();
    }
  }

  /// Opens the Wepin widget based on the current status of the SDK.
  ///
  /// If the SDK is in the [WepinLifeCycle.login] state, the widget is opened
  /// immediately. If the SDK is in the [WepinLifeCycle.initialized] state, the
  /// user is first logged into Wepin using the saved social token, and then the
  /// widget is opened. If the SDK is in any other state, the widget is not
  /// opened.
  Future<void> openWepinWidget(BuildContext context) async {
    "inside openWepinWidget".log();
    showLoader();

    // Check initial Wepin SDK status
    WepinLifeCycle wepinStatus = await state.wepinWidgetSDK!.getStatus();
    "inside openWepinWidget wepinStatus: $wepinStatus".log();

    // Define a helper function to handle widget opening if login status is valid
    Future<void> tryOpenWidget() async {
      dismissLoader();
      emit(state.copyWith(isLoading: false));
      await state.wepinWidgetSDK!.openWidget(context);
    }

    // Handle different Wepin lifecycle statuses
    switch (wepinStatus) {
      case WepinLifeCycle.loginBeforeRegister:
        dismissLoader();
        emit(state.copyWith(isLoading: false));
        await state.wepinWidgetSDK!.register(context);
        await tryOpenWidget();
        break;

      case WepinLifeCycle.login:
        await tryOpenWidget();
        break;

      case WepinLifeCycle.notInitialized:
        await initializeWepinSDK(
            selectedLanguageCode: context.locale.languageCode);
        wepinStatus = await state.wepinWidgetSDK!.getStatus();
        "wepinStatus after initialization: $wepinStatus".log();

        if (wepinStatus == WepinLifeCycle.login) {
          await tryOpenWidget();
        } else {
          dismissLoader();
        }
        break;

      case WepinLifeCycle.initialized:
        await loginSocialAuthProvider();
        await Future.delayed(const Duration(milliseconds: 1000));
        wepinStatus = await state.wepinWidgetSDK!.getStatus();
        "wepinStatus after login attempt: $wepinStatus".log();

        if (wepinStatus == WepinLifeCycle.login) {
          await tryOpenWidget();
        } else {
          dismissLoader();
        }
        break;

      default:
        dismissLoader();
        emit(state.copyWith(isLoading: false));
        "Unhandled Wepin lifecycle status: $wepinStatus".log();
    }
  }

  Future<void> saveWalletToHMP(bool isWepinWalletConnected,
      Future<void> Function() tryOpenWidget) async {
    if (!isWepinWalletConnected) {
      final wallets = await state.wepinWidgetSDK!.getAccounts();
      await saveWalletsToHMPBackend(wallets);
    }
    await tryOpenWidget();
  }

  Future<void> saveWalletsToHMPBackend(List wallets) async {
    // Implement the logic to save the fetched wallets to HMP backend here
    // This could involve making an HTTP request or calling another service

    // if status is login save wallets to backend

    for (var account in wallets) {
      if (account.network.toLowerCase() == "ethereum") {
        getIt<WalletsCubit>().onPostWallet(
          saveWalletRequestDto: SaveWalletRequestDto(
            publicAddress: account.address,
            provider: "WEPIN_EVM",
          ),
        );
      }
    }
  }

  Future<void> getSocialLoginValues() async {
    String socialTokenIsAppleOrGoogle =
        await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle) ??
            '';

    if (socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
      final appleIdTokenResult =
          await _secureStorage.read(StorageValues.appleIdToken) ?? '';

      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        appleIdToken: appleIdTokenResult,
      ));
    }

    if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      //
      final googleAccessTokenResult =
          await getIt<AuthCubit>().refreshGoogleAccessToken() ?? '';

      //
      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        googleAccessToken: googleAccessTokenResult,
      ));
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  Future<String?> refreshAppleToken() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // // Re-authenticate the user and return a new token
      // await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      // final newIdToken =
      //     await FirebaseAuth.instance.currentUser?.getIdToken(true);
      return oauthCredential.idToken;
    } catch (e, t) {
      // handle error
      return null;
    }
  }

  Future<void> loginSocialAuthProvider() async {
    "loginSocialAuthProvider is called".log();

    try {
      LoginResult? fbToken;

      // Determine the login type and proceed accordingly
      if (state.socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
        fbToken = await state.wepinWidgetSDK!.login.loginWithAccessToken(
            provider: 'google', accessToken: state.googleAccessToken);
      }

      // if Login Type is Apple
      if (state.socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
        "inside state.socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name ${state.socialTokenIsAppleOrGoogle}"
            .log();
        fbToken = await state.wepinWidgetSDK!.login
            .loginWithIdToken(idToken: state.appleIdToken);
      }

      if (fbToken != null) {
        final wepinUser = await state.wepinWidgetSDK?.login.loginWepin(fbToken);

        if (wepinUser?.userInfo != null) {
          // Update user's email and status if login is successful
          final wepinStatus = await state.wepinWidgetSDK!.getStatus();
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
    "updateWepinStatus is called ==> newStatus is $newStatus".log();
    emit(state.copyWith(wepinLifeCycleStatus: newStatus));
  }

  Future<void> updateWepinLifeCycleStatus() async {
    var status = await getIt<WepinCubit>().state.wepinWidgetSDK!.getStatus();

    "inside updateWepinLifeCycleStatus ==> the WepinSDK status is $status"
        .log();

    emit(state.copyWith(wepinLifeCycleStatus: status));
  }

  showLoader() {
    dismissLoader();
    emit(state.copyWith(isLoading: true));
    EasyLoading.show();
  }

  dismissLoader() {
    emit(state.copyWith(isLoading: false));
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

  Future<void> resetState() async {
    emit(state.copyWith(wepinLifeCycleStatus: WepinLifeCycle.notInitialized));
  }

  void startCountdown() {
    "start counter is called".log();

    int counter = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      counter++;

      "inside startCountdown ==> counter is $counter".log();
      if (counter >= 20) {
        timer.cancel();
        dismissLoader();
        emit(
          state.copyWith(isCountDownFinished: true, isLoading: false),
        ); // Emit true when reaching 20 seconds
      }
    });
  }

  updateIsPerformWepinWelcomeNftRedeem(bool value) {
    emit(state.copyWith(
      isPerformWepinWelcomeNftRedeem: value,
    ));
  }

  Future<void> onLogoutWepinSdk() async {
    await state.wepinWidgetSDK!.login.logoutWepin();
    emit(state.copyWith(wepinLifeCycleStatus: WepinLifeCycle.notInitialized));
  }
}
