// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

part 'wepin_state.dart';

@lazySingleton
class WepinCubit extends BaseCubit<WepinState> {
  WepinCubit()
      : super(const WepinState(
            wepinLifeCycleStatus: WepinLifeCycle.notInitialized));

  WepinWidgetSDK? wepinSDK;

  // Future<void> initWepinSDK() async {
  //   // String appId = sdkConfigs[0]['appId']!;
  //   // String appKey = sdkConfigs[0]['appKey']!;
  //   // String privateKey = sdkConfigs[0]['privateKey']!;

  //   emit(state.copyWith(
  //       lifeCycle: WepinLifeCycle.initializing, isLoading: true));

  //   try {
  //     await wepinSDK.init(
  //       attributes: WidgetAttributes(
  //         defaultLanguage: 'ko',
  //         defaultCurrency: 'KRW',
  //       ),
  //     );
  //     final status = await wepinSDK.getStatus();

  //     emit(state.copyWith(lifeCycle: status, isLoading: false));
  //   } catch (error) {
  //     emit(state.copyWith(isLoading: false, error: error.toString()));
  //   }
  // }

  Future<void> initWepinSDK() async {
    String appId = sdkConfigs[0]['appId']!;
    String appKey = sdkConfigs[0]['appKey']!;
    String privateKey = sdkConfigs[0]['privateKey']!;

    // Finalize any existing Wepin SDK instance
    wepinSDK?.finalize();

    // Initialize a new Wepin SDK instance with provided appId, appKey, and privateKey
    emit(state.copyWith(
        lifeCycle: WepinLifeCycle.initializing, isLoading: true));

    try {
      // Reinitialize the Wepin SDK
      wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);

      // Initialize the SDK with specified attributes
      await wepinSDK!.init(
        attributes: WidgetAttributes(
          defaultLanguage:
              'ko', // This can be changed based on your requirements
          defaultCurrency: 'KRW', // This too
        ),
      );

      // Fetch the current status from Wepin SDK
      final wepinStatus = await wepinSDK!.getStatus();

      // If user is logged in, fetch the current Wepin user email
      String? userEmail = '';
      if (wepinStatus == WepinLifeCycle.login) {
        final wepinUser = await wepinSDK!.login.getCurrentWepinUser();
        userEmail = wepinUser?.userInfo?.email ?? '';
      }

      // Emit the updated state with lifecycle, email, and other details
      emit(state.copyWith(
        lifeCycle: wepinStatus,
        userEmail: userEmail,
        isLoading: false,
      ));

      // Handle case if the SDK is not initialized properly
      if (wepinStatus == WepinLifeCycle.notInitialized) {
        emit(state.copyWith(error: 'WepinSDK is not initialized.'));
      } else {
        // Optionally call login with Google if SDK initialization is successful
        // loginWithGoogleProvider();
      }
    } catch (error) {
      // Handle any errors during SDK initialization
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  // Login with Google provider (for Android/iOS)
  Future<void> loginWithGoogle(String googleAccessToken) async {
    emit(state.copyWith(isLoading: true));

    try {
      LoginResult? loginResult;

      if (Platform.isAndroid) {
        loginResult = await wepinSDK!.login.loginWithAccessToken(
            provider: 'google', accessToken: googleAccessToken);
      } else if (Platform.isIOS) {
        loginResult =
            await wepinSDK!.login.loginWithIdToken(idToken: googleAccessToken);
      }

      if (loginResult != null) {
        final wepinUser = await wepinSDK!.login.loginWepin(loginResult);
        emit(state.copyWith(
          lifeCycle: WepinLifeCycle.login,
          userEmail: wepinUser?.userInfo?.email ?? '',
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Login failed'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Fetch accounts
  Future<void> fetchAccounts() async {
    emit(state.copyWith(isLoading: true));

    try {
      final accounts = await wepinSDK!.getAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> saveAccounts(List<WepinAccount> accounts) async {
    emit(state.copyWith(accounts: accounts, isLoading: false));
  }

  // Logout Wepin
  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));

    try {
      await wepinSDK!.login.logoutWepin();
      emit(state.copyWith(
          lifeCycle: WepinLifeCycle.beforeLogin,
          userEmail: '',
          isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  updateWepinStatus(WepinLifeCycle newStatus) {
    emit(state.copyWith(lifeCycle: newStatus));
  }
}
