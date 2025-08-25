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
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:flutter/services.dart';
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
  Timer? _walletCheckTimer;

  Future<void> initializeWepinSDK(
      {required String selectedLanguageCode}) async {
    "🚀 Starting Wepin SDK initialization...".log();

    String appId = sdkConfigs[0]['appId']!;
    String appKeyAndroid = sdkConfigs[0]['appKeyAndroid']!;
    String appKeyApple = sdkConfigs[0]['appKeyApple']!;

    // Get social login tokens first
    await getSocialLoginValues();
    "📱 Retrieved social login values".log();

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
        "✅ Wepin SDK initialized successfully with status: $wepinStatus".log();
        // Don't auto-login here, let onboarding handle it when needed
        // loginSocialAuthProvider();
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
      // Start wallet check timer for NFT redemption scenario
      "🎁 Starting wallet check timer for NFT redemption in onConnectWepinWallet".log();
      startWalletCheckTimer();
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
    "🔍 Checking Wepin lifecycle status: $status".log();
    
    if (status == WepinLifeCycle.initialized) {
      "✅ Status is initialized, performing login...".log();
      // Perform login if status is 'initialized'
      await loginSocialAuthProvider();
      "Performed login to Wepin".log();
    } else if (status == WepinLifeCycle.beforeLogin ||
        status == WepinLifeCycle.loginBeforeRegister) {
      "⚠️ Status requires registration: $status".log();
      dismissLoader();
      // Perform registration if status is 'before_login' or 'login_before_register'
      await state.wepinWidgetSDK!.register(context);
      "Performed registration to Wepin".log();
    } else if (status == WepinLifeCycle.login) {
      "✅ Already logged in to Wepin!".log();
    } else {
      "❓ Unhandled Wepin lifecycle status in onConnectWepinWallet: $status".log();
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
        
        // Refresh wallet list after saving
        await getIt<WalletsCubit>().onGetAllWallets();
        "Wallet list refreshed after saving".log();
        
        emit(state.copyWith(
          isPerformWepinWalletSave: false,
          isLoading: false,
          error: '',
        ));
      } catch (e) {
        "Failed to save wallets to HMP backend: $e".log();
        dismissLoader();
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
            
            // Refresh wallet list after saving
            await getIt<WalletsCubit>().onGetAllWallets();
            "Wallet list refreshed after saving".log();
            
            emit(state.copyWith(
              isPerformWepinWalletSave: false,
              isLoading: false,
              error: '',
            ));
          } catch (e) {
            "Failed to save wallets to HMP backend: $e".log();
            dismissLoader();
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
    
    // Start wallet check timer when opening widget for NFT redemption
    if (state.isPerformWepinWelcomeNftRedeem) {
      "🎁 Starting wallet check timer for NFT redemption in openWepinWidget".log();
      startWalletCheckTimer();
    }

    // Check if SDK is null and initialize it if needed
    // null check update by munbbok 250315
    if (state.wepinWidgetSDK == null) {
      "wepinWidgetSDK is null, initializing...".log();
      await initializeWepinSDK(selectedLanguageCode: context.locale.languageCode);
      
      // If still null after initialization, handle the error
      if (state.wepinWidgetSDK == null) {
        dismissLoader();
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to initialize Wepin SDK',
        ));
        return;
      }
    }

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
        } else if (wepinStatus == WepinLifeCycle.initialized) {
          // Use loginWithUI for initialized state
          "🔐 SDK initialized, using loginWithUI...".log();
          dismissLoader();
          await tryOpenWidget(); // Widget will handle login internally
        } else {
          dismissLoader();
        }
        break;

      case WepinLifeCycle.initialized:
        // For initialized state, just open the widget - it will handle login internally
        "🔐 SDK initialized, opening widget with loginWithUI...".log();
        dismissLoader();
        await tryOpenWidget(); // Widget will show login UI internally
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

    "💼 ===== Starting wallet save process =====".log();
    "💼 Total wallets found: ${wallets.length}".log();

    // if status is login save wallets to backend
    bool hasWepinEvm = false;
    bool hasKlip = false;

    for (var account in wallets) {
      "🔍 Found wallet - Network: ${account.network}, Address: ${account.address}".log();
      
      // Check for Ethereum-compatible networks
      bool isEthereumNetwork = account.network.toLowerCase() == "ethereum" ||
                              account.network.toLowerCase().startsWith("evm") ||
                              account.network.toLowerCase() == "polygon" ||
                              account.network.toLowerCase() == "avax-c-chain";
      
      if (isEthereumNetwork) {
        "💾 [WEPIN_EVM] Saving Ethereum wallet to backend".log();
        "💾 [WEPIN_EVM] Wallet address: ${account.address}".log();
        "💾 [WEPIN_EVM] Provider type: WEPIN_EVM".log();
        
        try {
          await getIt<WalletsCubit>().onPostWallet(
            saveWalletRequestDto: SaveWalletRequestDto(
              publicAddress: account.address,
              provider: "WEPIN_EVM",
            ),
          );
          hasWepinEvm = true;
          "✅ [WEPIN_EVM] Ethereum wallet save request completed".log();
        } catch (e) {
          // Check if error is 409 WALLET_ALREADY_LINKED
          if (e.toString().contains('409') || e.toString().contains('WALLET_ALREADY_LINKED')) {
            "⚠️ [WEPIN_EVM] Wallet already linked, updating instead: ${account.address}".log();
            // Wallet already exists, just mark as successful
            hasWepinEvm = true;
            "✅ [WEPIN_EVM] Using existing wallet: ${account.address}".log();
          } else {
            "❌ [WEPIN_EVM] Failed to save wallet: $e".log();
            rethrow;
          }
        }
      }
      
      // Also save KLIP wallet for Klaytn network
      if (account.network.toLowerCase() == "klaytn") {
        "💾 [KLIP] Saving Klaytn wallet to backend".log();
        "💾 [KLIP] Wallet address: ${account.address}".log();
        "💾 [KLIP] Provider type: KLIP".log();
        
        try {
          await getIt<WalletsCubit>().onPostWallet(
            saveWalletRequestDto: SaveWalletRequestDto(
              publicAddress: account.address,
              provider: "KLIP",
            ),
          );
          hasKlip = true;
          "✅ [KLIP] Klaytn wallet save request completed".log();
        } catch (e) {
          // Check if error is 409 WALLET_ALREADY_LINKED
          if (e.toString().contains('409') || e.toString().contains('WALLET_ALREADY_LINKED')) {
            "⚠️ [KLIP] Wallet already linked, updating instead: ${account.address}".log();
            // Wallet already exists, just mark as successful
            hasKlip = true;
            "✅ [KLIP] Using existing wallet: ${account.address}".log();
          } else {
            "❌ [KLIP] Failed to save wallet: $e".log();
            rethrow;
          }
        }
      }
    }
    
    "💼 ===== Wallet save process completed =====".log();
    "💼 Summary: WEPIN_EVM=${hasWepinEvm}, KLIP=${hasKlip}".log();
    
    // Refresh wallet list after saving
    "🔄 Refreshing wallet list after save...".log();
    try {
      await getIt<WalletsCubit>().onGetAllWallets();
      final connectedWallets = getIt<WalletsCubit>().state.connectedWallets;
      "✅ Wallet list refreshed. Total wallets: ${connectedWallets.length}".log();
      for (var wallet in connectedWallets) {
        "📱 Connected wallet: ${wallet.provider} - ${wallet.publicAddress}".log();
      }
    } catch (e) {
      "❌ Failed to refresh wallet list: $e".log();
    }
    
    // Refresh user profile to get updated information
    "🔄 Refreshing user data after wallet save...".log();
    try {
      await getIt<ProfileCubit>().onGetUserProfile();
      "✅ User profile refreshed successfully".log();
    } catch (e) {
      "❌ Failed to refresh user profile: $e".log();
    }
  }

  Future<void> getSocialLoginValues() async {
    String socialTokenIsAppleOrGoogle =
        await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle) ??
            '';
    
    "🔍 Getting social login values, type: $socialTokenIsAppleOrGoogle".log();

    if (socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
      // final appleIdTokenResult =
      //     await _secureStorage.read(StorageValues.appleIdToken) ?? '';

      // final appleIdTokenResult = await FirebaseAuth.instance.currentUser?.getIdToken() ?? "";
      final appleIdTokenResult = await getIt<AuthCubit>().refreshAppleIdToken() ?? '';
      
      "🍎 Apple ID Token retrieved: ${appleIdTokenResult.isNotEmpty ? 'Success' : 'Failed'}".log();

      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        appleIdToken: appleIdTokenResult,
      ));
    }

    if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      "🔄 Getting stored Google ID Token...".log();
      
      var googleIdTokenResult = await _secureStorage.read(StorageValues.googleIdToken) ?? '';
      
      // If token is empty, try to refresh it
      if (googleIdTokenResult.isEmpty) {
        "⚠️ Stored Google ID token is empty, attempting to refresh...".log();
        
        // Try to refresh the Google token through AuthCubit
        final refreshedToken = await getIt<AuthCubit>().refreshGoogleAccessToken();
        
        if (refreshedToken != null && refreshedToken.isNotEmpty) {
          googleIdTokenResult = refreshedToken;
          // Save the refreshed token for future use
          await _secureStorage.write(
            StorageValues.googleIdToken,
            googleIdTokenResult,
          );
          "✅ Google ID token refreshed successfully from GoogleSignIn".log();
        } else {
          "❌ Failed to refresh Google ID token".log();
        }
      }
      
      "🔑 Google ID Token retrieved: ${googleIdTokenResult.isNotEmpty ? 'Success (${googleIdTokenResult.substring(0, min(20, googleIdTokenResult.length))}...)' : 'Failed - Unable to recover'}".log();

      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        googleAccessToken: googleIdTokenResult, // Store ID token in googleAccessToken field for compatibility
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
      // Check if we already have saved Wepin login credentials
      final savedWepinToken = await _secureStorage.read(StorageValues.wepinToken) ?? '';
      
      if (savedWepinToken.isNotEmpty) {
        "✅ Found saved Wepin token, attempting auto-login...".log();
        // Try to restore previous session
        final status = await state.wepinWidgetSDK!.getStatus();
        if (status == WepinLifeCycle.login) {
          "✅ Already logged in to Wepin".log();
          emit(state.copyWith(
            wepinLifeCycleStatus: status,
            isLoading: false,
          ));
          return;
        }
      }
      
      "⚠️ No saved Wepin session, user will need to login when opening widget".log();
      // Don't show login UI here - let the widget handle it when opened
      emit(state.copyWith(
        isLoading: false,
      ));
    } catch (e) {
      "❌ Error in loginSocialAuthProvider: $e".log();
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Login to Wepin - mark SDK as ready for loginWithUI
  Future<void> loginWepinWithGoogle(String idToken) async {
    "🔄 [WepinCubit] loginWepinWithGoogle called".log();
    
    if (state.wepinWidgetSDK == null) {
      "❌ [WepinCubit] Wepin SDK is not initialized".log();
      return;
    }

    try {
      // Just check the current status
      final wepinStatus = await state.wepinWidgetSDK!.getStatus();
      "📊 [WepinCubit] Current Wepin status: $wepinStatus".log();
      
      // Save that we're using Google for future reference
      await _secureStorage.write(StorageValues.socialTokenIsAppleOrGoogle, SocialLoginType.GOOGLE.name);
      
      emit(state.copyWith(
        wepinLifeCycleStatus: wepinStatus,
        socialTokenIsAppleOrGoogle: SocialLoginType.GOOGLE.name,
        isLoading: false,
      ));
      
      // If already logged in, great!
      if (wepinStatus == WepinLifeCycle.login) {
        "✅ [WepinCubit] Already logged in to Wepin".log();
      } else {
        "ℹ️ [WepinCubit] Wepin will show login UI when widget opens".log();
      }
    } catch (e) {
      "❌ [WepinCubit] Error: $e".log();
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Login to Wepin - mark SDK as ready for loginWithUI
  Future<void> loginWepinWithApple(String idToken) async {
    "🔄 [WepinCubit] loginWepinWithApple called".log();
    
    if (state.wepinWidgetSDK == null) {
      "❌ [WepinCubit] Wepin SDK is not initialized".log();
      return;
    }

    try {
      // Just check the current status
      final wepinStatus = await state.wepinWidgetSDK!.getStatus();
      "📊 [WepinCubit] Current Wepin status: $wepinStatus".log();
      
      // Save that we're using Apple for future reference
      await _secureStorage.write(StorageValues.socialTokenIsAppleOrGoogle, SocialLoginType.APPLE.name);
      
      emit(state.copyWith(
        wepinLifeCycleStatus: wepinStatus,
        socialTokenIsAppleOrGoogle: SocialLoginType.APPLE.name,
        isLoading: false,
      ));
      
      // If already logged in, great!
      if (wepinStatus == WepinLifeCycle.login) {
        "✅ [WepinCubit] Already logged in to Wepin".log();
      } else {
        "ℹ️ [WepinCubit] Wepin will show login UI when widget opens".log();
      }
    } catch (e) {
      "❌ [WepinCubit] Error: $e".log();
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
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
    //await state.wepinWidgetSDK!.finalize();
    
    // Stop wallet check timer when closing widget
    stopWalletCheckTimer();
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
      //await state.wepinWidgetSDK!.finalize();
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

  // Start periodic wallet checking for NFT redemption or onboarding
  void startWalletCheckTimer({bool isFromOnboarding = false}) {
    if (isFromOnboarding) {
      "🔄 Starting wallet check timer for ONBOARDING flow".log();
    } else {
      "🔄 Starting wallet check timer for NFT redemption".log();
    }
    "🔄 Current state - isPerformWepinWelcomeNftRedeem: ${state.isPerformWepinWelcomeNftRedeem}".log();
    
    // Cancel any existing timer
    stopWalletCheckTimer();
    
    // Reset counter and set checking flag
    emit(state.copyWith(
      isCheckingWallet: true,
      walletCheckCounter: 0,
      isOnboardingFlow: isFromOnboarding,
    ));
    
    "✅ Timer state updated - isCheckingWallet: true".log();
    
    // Check every 5 seconds
    _walletCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final counter = state.walletCheckCounter + 5;
      emit(state.copyWith(walletCheckCounter: counter));
      
      "⏱️ Wallet check timer: ${counter}s / 600s".log();
      
      // Stop after 10 minutes (600 seconds)
      if (counter >= 600) {
        "⏰ Wallet check timeout after 10 minutes".log();
        stopWalletCheckTimer();
        dismissLoader();
        emit(state.copyWith(
          error: 'Wallet connection timeout. Please try again.',
        ));
        return;
      }
      
      // Check if SDK is initialized
      if (state.wepinWidgetSDK == null) {
        "❌ Wepin SDK not initialized, skipping check".log();
        return;
      }
      
      try {
        // Check Wepin status
        final status = await state.wepinWidgetSDK!.getStatus();
        "📊 Wepin status during check: $status".log();
        
        // If logged in, check for wallets
        if (status == WepinLifeCycle.login) {
          final wallets = await state.wepinWidgetSDK!.getAccounts();
          "💼 Found ${wallets.length} wallets during periodic check".log();
          
          // Log detailed wallet information
          for (var i = 0; i < wallets.length; i++) {
            var account = wallets[i];
            "📱 Wallet #${i+1}: Network=${account.network}, Address=${account.address}".log();
          }
          
          if (wallets.isNotEmpty) {
            // Check if wallet already saved
            await getIt<WalletsCubit>().onGetAllWallets();
            final connectedWallets = getIt<WalletsCubit>().state.connectedWallets;
            "🔗 Currently connected wallets count: ${connectedWallets.length}".log();
            
            bool walletAlreadySaved = false;
            for (var account in wallets) {
              // Check both Ethereum-compatible and Klaytn wallets
              bool isEthereumNetwork = account.network.toLowerCase() == "ethereum" ||
                                      account.network.toLowerCase().startsWith("evm") ||
                                      account.network.toLowerCase() == "polygon" ||
                                      account.network.toLowerCase() == "avax-c-chain";
              
              if (isEthereumNetwork || account.network.toLowerCase() == "klaytn") {
                walletAlreadySaved = connectedWallets.any(
                  (w) => w.publicAddress.toLowerCase() == account.address.toLowerCase()
                );
                if (walletAlreadySaved) {
                  "ℹ️ Wallet ${account.address} already saved".log();
                  break;
                }
              }
            }
            
            if (!walletAlreadySaved) {
              "💾 New wallets detected, saving to backend...".log();
              await saveWalletsToHMPBackend(wallets);
              
              // Wait for backend to sync - increased delay
              "⏳ Waiting for backend synchronization (3 seconds)...".log();
              await Future.delayed(const Duration(seconds: 3));
              
              // Refresh wallet list multiple times to ensure sync
              for (int retry = 0; retry < 3; retry++) {
                "🔄 Refreshing wallet list (attempt ${retry + 1}/3)...".log();
                await getIt<WalletsCubit>().onGetAllWallets();
                final updatedWallets = getIt<WalletsCubit>().state.connectedWallets;
                
                if (updatedWallets.isNotEmpty) {
                  "✅ Wallets synced successfully. Found ${updatedWallets.length} wallets".log();
                  break;
                } else if (retry < 2) {
                  "⏳ Wallets not yet synced, waiting 2 seconds before retry...".log();
                  await Future.delayed(const Duration(seconds: 2));
                }
              }
              
              // After saving, check if we need to redeem NFT
              if (state.isPerformWepinWelcomeNftRedeem) {
                "🎁 Attempting to redeem welcome NFT after wallet save...".log();
                
                // Final wallet check
                await getIt<WalletsCubit>().onGetAllWallets();
                final finalWallets = getIt<WalletsCubit>().state.connectedWallets;
                "📊 Final wallet check - Total wallets: ${finalWallets.length}".log();
                
                // Check if any wallet is connected (WEPIN_EVM or KLIP)
                bool hasValidWallet = finalWallets.any((w) => 
                  w.provider == "WEPIN_EVM" || w.provider == "KLIP"
                );
                
                if (hasValidWallet || finalWallets.isNotEmpty) {
                  "✅ Wallet connected, proceeding with NFT redemption".log();
                  
                  // Trigger NFT redemption
                  if (getIt<NftCubit>().state.welcomeNftEntity.remainingCount > 0) {
                    "🎁 Calling NFT redemption API...".log();
                    getIt<NftCubit>().onGetConsumeWelcomeNft();
                  }
                  
                  // Stop the timer as we've completed the process
                  stopWalletCheckTimer();
                  dismissLoader();
                  emit(state.copyWith(
                    isPerformWepinWelcomeNftRedeem: false,
                  ));
                } else {
                  "⚠️ Wallet not yet marked as connected, will retry...".log();
                }
              } else {
                // Just saving wallet, not redeeming NFT
                "✅ Wallet saved successfully (non-NFT flow)".log();
                
                // Check if this is from onboarding flow
                if (state.isOnboardingFlow) {
                  "🎯 Wallet saved from ONBOARDING - signaling completion".log();
                  emit(state.copyWith(
                    walletCreatedFromOnboarding: true,
                    isOnboardingFlow: false,
                  ));
                }
                
                stopWalletCheckTimer();
                dismissLoader();
              }
            } else {
              "ℹ️ All wallets already saved, checking NFT redemption status...".log();
              
              // If wallet is already saved and we're trying to redeem NFT
              if (state.isPerformWepinWelcomeNftRedeem && 
                  getIt<WalletsCubit>().state.isWepinWalletConnected) {
                "🎁 Wallet already connected, proceeding with NFT redemption".log();
                
                if (getIt<NftCubit>().state.welcomeNftEntity.remainingCount > 0) {
                  "🎁 Calling NFT redemption API (wallet already connected)...".log();
                  getIt<NftCubit>().onGetConsumeWelcomeNft();
                }
                
                stopWalletCheckTimer();
                dismissLoader();
                emit(state.copyWith(
                  isPerformWepinWelcomeNftRedeem: false,
                ));
              }
            }
          } else {
            "⚠️ No wallets found in Wepin SDK".log();
          }
        } else if (status == WepinLifeCycle.loginBeforeRegister) {
          "📝 User needs to complete registration".log();
        }
      } catch (e) {
        "❌ Error during wallet check: $e".log();
      }
    });
  }
  
  // Stop the wallet check timer
  void stopWalletCheckTimer() {
    if (_walletCheckTimer != null) {
      "🛑 Stopping wallet check timer".log();
      _walletCheckTimer!.cancel();
      _walletCheckTimer = null;
      emit(state.copyWith(
        isCheckingWallet: false,
        walletCheckCounter: 0,
      ));
    }
  }
  
  // Reset onboarding wallet flag
  void resetOnboardingWalletFlag() {
    emit(state.copyWith(
      walletCreatedFromOnboarding: false,
    ));
    "🔄 Onboarding wallet flag reset".log();
  }
  
  void dispose() {
    stopWalletCheckTimer();
  }
}
