// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
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
    if (state.wepinWidgetSDK != null) {
      try {
        await state.wepinWidgetSDK!.finalize();
        "✅ Previous WePIN SDK instance finalized".log();
      } catch (e) {
        "⚠️ Error finalizing previous WePIN SDK: $e".log();
      }
    }

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
        
        // Don't auto-login here - let the widget opening or explicit login handle it
        // This follows the Wepin team's recommendation to login only when needed
        if (wepinStatus == WepinLifeCycle.initialized) {
          "ℹ️ SDK initialized, login will be performed when opening widget".log();
        }
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
      // Need to perform login flow
      "📍 Status is initialized, performing login flow...".log();
      await loginSocialAuthProvider();
      
      // Check if login was successful
      final currentStatus = await state.wepinWidgetSDK!.getStatus();
      if (currentStatus != WepinLifeCycle.login) {
        "❌ Login failed, status is: $currentStatus".log();
        dismissLoader();
        emit(state.copyWith(
          isPerformWepinWalletSave: false,
          isLoading: false,
          error: 'Failed to login to Wepin',
        ));
        return;
      }
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
    
    // 방어적 검사: 컨텍스트 유효성
    if (!context.mounted) {
      "❌ Context is not mounted, cannot open widget".log();
      return;
    }
    
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
        // Already logged in, just open the widget
        "✅ Already logged in, opening widget".log();
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
          // Need to login first
          "📍 SDK initialized, attempting login flow...".log();
          await loginSocialAuthProvider();
          
          // Check status after login attempt
          final statusAfterLogin = await state.wepinWidgetSDK!.getStatus();
          if (statusAfterLogin == WepinLifeCycle.login) {
            "✅ Login successful, opening widget".log();
            await tryOpenWidget();
          } else {
            "❌ Login failed, cannot open widget".log();
            dismissLoader();
            emit(state.copyWith(
              isLoading: false,
              error: 'Failed to login to Wepin',
            ));
          }
        } else {
          dismissLoader();
        }
        break;

      case WepinLifeCycle.initialized:
        // SDK initialized but not logged in - need to login first
        "📍 SDK initialized, need to login before opening widget...".log();
        await loginSocialAuthProvider();
        
        // Check status after login attempt
        final statusAfterLogin = await state.wepinWidgetSDK!.getStatus();
        if (statusAfterLogin == WepinLifeCycle.login) {
          "✅ Login successful, opening widget".log();
          await tryOpenWidget();
        } else {
          "❌ Login failed, cannot open widget".log();
          dismissLoader();
          emit(state.copyWith(
            isLoading: false,
            error: 'Failed to login to Wepin',
          ));
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
      final appleIdTokenResult = await _getAppleTokenWithRetry();
      
      "🍎 Apple ID Token retrieved: ${appleIdTokenResult.isNotEmpty ? 'Success' : 'Failed'}".log();

      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        appleIdToken: appleIdTokenResult,
      ));
    }

    if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      final googleIdTokenResult = await _getGoogleTokenWithRetry();
      
      "🔑 Google ID Token retrieved: ${googleIdTokenResult.isNotEmpty ? 'Success (${googleIdTokenResult.substring(0, min(20, googleIdTokenResult.length))}...)' : 'Failed - Unable to recover'}".log();

      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        googleAccessToken: googleIdTokenResult, // Store ID token in googleAccessToken field for compatibility
      ));
    }
  }

  /// Firebase 토큰인지 확인하는 함수
  bool _isFirebaseToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      final issuer = payload['iss'] as String?;
      "🔍 Token issuer: $issuer".log();
      return issuer?.contains('securetoken.google.com') ?? false;
    } catch (e) {
      "❌ Error checking token: $e".log();
      return false;
    }
  }

  /// JWT 토큰이 만료되었는지 확인하는 함수
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true; // 잘못된 토큰 형식

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return true; // 만료시간 필드가 없음

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final isExpired = now >= exp;

      final remainingSeconds = exp - now;

      if (isExpired) {
        "⚠️ 토큰 만료됨: 현재=$now, 만료=$exp (${-remainingSeconds}초 전 만료)".log();
      } else {
        "✅ 토큰 유효: ${remainingSeconds}초 후 만료".log();
      }

      return isExpired;
    } catch (e) {
      "❌ 토큰 만료 확인 중 오류: $e".log();
      return true; // 파싱할 수 없으면 만료된 것으로 간주
    }
  }

  /// Google 토큰을 재시도 로직과 함께 가져옵니다
  Future<String> _getGoogleTokenWithRetry({int maxRetries = 3}) async {
    "🔄 Getting stored Google ID Token...".log();

    var googleIdTokenResult = await _secureStorage.read(StorageValues.googleIdToken) ?? '';

    // If token is available, check if it's a Firebase token or expired
    if (googleIdTokenResult.isNotEmpty) {
      if (_isFirebaseToken(googleIdTokenResult)) {
        "⚠️ Found Firebase token instead of Google OAuth token, forcing refresh...".log();
        googleIdTokenResult = ''; // Clear Firebase token to force refresh
      } else if (_isTokenExpired(googleIdTokenResult)) {
        "⚠️ Google OAuth token has expired, forcing refresh...".log();
        googleIdTokenResult = ''; // Clear expired token to force refresh
      } else {
        "✅ Found valid and non-expired Google OAuth ID token".log();
        return googleIdTokenResult;
      }
    }
    
    // Token is empty, try to refresh with retries
    "⚠️ Stored Google ID token is empty, attempting to refresh...".log();
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      "🔄 Google token refresh attempt $attempt/$maxRetries".log();
      
      try {
        // Try to refresh the Google token through AuthCubit
        final refreshedToken = await getIt<AuthCubit>().refreshGoogleAccessToken();
        
        if (refreshedToken != null && refreshedToken.isNotEmpty) {
          // Validate token before saving
          if (refreshedToken.length > 10) { // Basic validation
            // Save the refreshed token with verification
            await _secureStorage.write(StorageValues.googleIdToken, refreshedToken);
            
            // Wait a moment for storage to complete
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Verify the token was actually saved
            final verifyToken = await _secureStorage.read(StorageValues.googleIdToken) ?? '';
            if (verifyToken == refreshedToken) {
              "✅ Google ID token refreshed and verified (attempt $attempt)".log();
              return refreshedToken;
            } else {
              "⚠️ Token verification failed after save (attempt $attempt)".log();
            }
          } else {
            "⚠️ Retrieved token appears invalid (too short) - attempt $attempt".log();
          }
        } else {
          "⚠️ No token returned from refresh (attempt $attempt)".log();
        }
      } catch (e) {
        "❌ Error during Google token refresh attempt $attempt: $e".log();
      }
      
      // Wait before next retry (exponential backoff)
      if (attempt < maxRetries) {
        final waitTime = Duration(milliseconds: 500 * attempt);
        "⏳ Waiting ${waitTime.inMilliseconds}ms before retry...".log();
        await Future.delayed(waitTime);
      }
    }
    
    "❌ Failed to refresh Google ID token after $maxRetries attempts".log();
    return '';
  }

  /// Apple 토큰을 재시도 로직과 함께 가져옵니다
  Future<String> _getAppleTokenWithRetry({int maxRetries = 2}) async {
    "🔄 Getting Apple ID Token...".log();
    
    // First try to get stored token
    var appleIdTokenResult = await _secureStorage.read(StorageValues.appleIdToken) ?? '';
    
    if (appleIdTokenResult.isNotEmpty) {
      "✅ Found stored Apple ID token".log();
      return appleIdTokenResult;
    }
    
    // Try to refresh Apple token
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      "🔄 Apple token refresh attempt $attempt/$maxRetries".log();
      
      try {
        final refreshedToken = await getIt<AuthCubit>().refreshAppleIdToken() ?? '';
        
        if (refreshedToken.isNotEmpty) {
          // Save the refreshed token
          await _secureStorage.write(StorageValues.appleIdToken, refreshedToken);
          
          // Wait for storage to complete
          await Future.delayed(const Duration(milliseconds: 100));
          
          "✅ Apple ID token refreshed successfully (attempt $attempt)".log();
          return refreshedToken;
        } else {
          "⚠️ No Apple token returned from refresh (attempt $attempt)".log();
        }
      } catch (e) {
        "❌ Error during Apple token refresh attempt $attempt: $e".log();
      }
      
      // Wait before next retry
      if (attempt < maxRetries) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    
    "❌ Failed to refresh Apple ID token after $maxRetries attempts".log();
    return '';
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
    } catch (e) {
      // handle error
      return null;
    }
  }

  Future<void> loginSocialAuthProvider() async {
    "loginSocialAuthProvider is called".log();
    
    try {
      // 방어적 검사: SDK 유효성 확인
      if (state.wepinWidgetSDK == null) {
        "❌ Wepin SDK is null, cannot proceed with login".log();
        emit(state.copyWith(
          isLoading: false,
          error: 'Wepin SDK not initialized',
        ));
        return;
      }

      // Check current status first with timeout
      WepinLifeCycle currentStatus;
      try {
        currentStatus = await state.wepinWidgetSDK!.getStatus()
            .timeout(const Duration(seconds: 10));
      } catch (timeoutError) {
        "❌ Timeout getting Wepin status: $timeoutError".log();
        emit(state.copyWith(
          isLoading: false,
          error: 'Connection timeout. Please check your network and try again.',
        ));
        return;
      }

      if (currentStatus == WepinLifeCycle.login) {
        "✅ Already logged in to Wepin".log();
        emit(state.copyWith(
          wepinLifeCycleStatus: currentStatus,
          isLoading: false,
        ));
        return;
      }
      
      // Get social login type and token
      final socialType = state.socialTokenIsAppleOrGoogle;
      "🔐 Social login type: $socialType".log();
      
      // Get the appropriate ID token based on social type
      String? idToken;
      String provider = '';
      
      if (socialType == SocialLoginType.GOOGLE.name) {
        idToken = state.googleAccessToken; // This actually contains the ID token
        provider = 'google';
        "🔑 Using Google ID token for login".log();

        // Check if it's a Firebase token and force refresh if needed
        if (idToken != null && idToken.isNotEmpty && _isFirebaseToken(idToken)) {
          "⚠️ Detected Firebase token in state, forcing refresh...".log();
          idToken = null; // Clear to force refresh
        }
      } else if (socialType == SocialLoginType.APPLE.name) {
        idToken = state.appleIdToken;
        provider = 'apple';
        "🔑 Using Apple ID token for login".log();
      }

      if (idToken == null || idToken.isEmpty) {
        "❌ No valid ID token available for login, attempting token refresh...".log();

        // Try to get tokens again with force refresh
        await getSocialLoginValues();
        
        // Get the token again after refresh
        if (socialType == SocialLoginType.GOOGLE.name) {
          idToken = state.googleAccessToken;
        } else if (socialType == SocialLoginType.APPLE.name) {
          idToken = state.appleIdToken;
        }
        
        // If still no token after refresh, show error
        if (idToken == null || idToken.isEmpty) {
          "❌ Still no ID token available after refresh attempt".log();
          emit(state.copyWith(
            isLoading: false,
            error: 'Authentication failed: Unable to get valid login token. Please try logging in again.',
          ));
          return;
        } else {
          "✅ Token obtained after refresh, proceeding with login".log();
        }
      }
      
      try {
        // Step 1: Login with ID Token (위핀 개발팀 제안)
        "📍 Step 1: Calling loginWithIdToken...".log();
        final loginResponse = await state.wepinWidgetSDK!.login.loginWithIdToken(
          idToken: idToken,
          sign: provider, // 'google' or 'apple'
        );
        
        if (loginResponse != null) {
          "✅ loginWithIdToken successful".log();
          
          // Step 2: Login to Wepin (위핀 개발팀 제안)
          "📍 Step 2: Calling loginWepin...".log();
          final wepinLoginResponse = await state.wepinWidgetSDK!.login.loginWepin(loginResponse);
          
          if (wepinLoginResponse != null) {
            "✅ loginWepin successful".log();
            
            // Update status after successful login
            final newStatus = await state.wepinWidgetSDK!.getStatus();
            "📊 New Wepin status: $newStatus".log();
            
            emit(state.copyWith(
              wepinLifeCycleStatus: newStatus,
              isLoading: false,
            ));
            
            "✅ Login flow completed successfully".log();
          } else {
            "❌ loginWepin failed".log();
            emit(state.copyWith(
              isLoading: false,
              error: 'Failed to complete Wepin login',
            ));
          }
        } else {
          "❌ loginWithIdToken failed".log();
          emit(state.copyWith(
            isLoading: false,
            error: 'Failed to login with ID token',
          ));
        }
      } catch (e) {
        "❌ Error during login process: $e".log();
        _handleWepinError(e, 'login process');
      }
    } catch (e) {
      "❌ Error in loginSocialAuthProvider: $e".log();
      _handleWepinError(e, 'social auth login');
    }
  }

  /// Login to Wepin with Google ID Token
  Future<void> loginWepinWithGoogle(String idToken) async {
    "🔄 [WepinCubit] loginWepinWithGoogle called".log();
    
    if (state.wepinWidgetSDK == null) {
      "❌ [WepinCubit] Wepin SDK is not initialized".log();
      return;
    }

    try {
      // Check current status
      final currentStatus = await state.wepinWidgetSDK!.getStatus();
      "📊 [WepinCubit] Current Wepin status: $currentStatus".log();
      
      if (currentStatus == WepinLifeCycle.login) {
        "✅ [WepinCubit] Already logged in to Wepin".log();
        emit(state.copyWith(
          wepinLifeCycleStatus: currentStatus,
          isLoading: false,
        ));
        return;
      }
      
      // Save login type and token for future use
      await _secureStorage.write(StorageValues.socialTokenIsAppleOrGoogle, SocialLoginType.GOOGLE.name);
      await _secureStorage.write(StorageValues.googleIdToken, idToken);
      
      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: SocialLoginType.GOOGLE.name,
        googleAccessToken: idToken, // Store ID token
        isLoading: true,
      ));
      
      // Step 1: Login with ID Token (위핀 개발팀 제안)
      "📍 [WepinCubit] Step 1: Calling loginWithIdToken...".log();
      final loginResponse = await state.wepinWidgetSDK!.login.loginWithIdToken(
        idToken: idToken,
        sign: 'google',
      );
      
      if (loginResponse != null) {
        "✅ [WepinCubit] loginWithIdToken successful".log();
        
        // Step 2: Login to Wepin (위핀 개발팀 제안)
        "📍 [WepinCubit] Step 2: Calling loginWepin...".log();
        final wepinLoginResponse = await state.wepinWidgetSDK!.login.loginWepin(loginResponse);
        
        if (wepinLoginResponse != null) {
          "✅ [WepinCubit] loginWepin successful".log();
          
          // Update status after successful login
          final newStatus = await state.wepinWidgetSDK!.getStatus();
          "📊 [WepinCubit] New Wepin status: $newStatus".log();
          
          emit(state.copyWith(
            wepinLifeCycleStatus: newStatus,
            isLoading: false,
          ));
          
          "✅ [WepinCubit] Google login flow completed successfully".log();
        } else {
          "❌ [WepinCubit] loginWepin failed".log();
          emit(state.copyWith(
            isLoading: false,
            error: 'Failed to complete Wepin login',
          ));
        }
      } else {
        "❌ [WepinCubit] loginWithIdToken failed".log();
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to login with Google ID token',
        ));
      }
    } catch (e) {
      "❌ [WepinCubit] Error: $e".log();
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Login to Wepin with Apple ID Token
  Future<void> loginWepinWithApple(String idToken) async {
    "🔄 [WepinCubit] loginWepinWithApple called".log();
    
    if (state.wepinWidgetSDK == null) {
      "❌ [WepinCubit] Wepin SDK is not initialized".log();
      return;
    }

    try {
      // Check current status
      final currentStatus = await state.wepinWidgetSDK!.getStatus();
      "📊 [WepinCubit] Current Wepin status: $currentStatus".log();
      
      if (currentStatus == WepinLifeCycle.login) {
        "✅ [WepinCubit] Already logged in to Wepin".log();
        emit(state.copyWith(
          wepinLifeCycleStatus: currentStatus,
          isLoading: false,
        ));
        return;
      }
      
      // Save login type and token for future use
      await _secureStorage.write(StorageValues.socialTokenIsAppleOrGoogle, SocialLoginType.APPLE.name);
      await _secureStorage.write(StorageValues.appleIdToken, idToken);
      
      emit(state.copyWith(
        socialTokenIsAppleOrGoogle: SocialLoginType.APPLE.name,
        appleIdToken: idToken,
        isLoading: true,
      ));
      
      // Step 1: Login with ID Token (위핀 개발팀 제안)
      "📍 [WepinCubit] Step 1: Calling loginWithIdToken...".log();
      final loginResponse = await state.wepinWidgetSDK!.login.loginWithIdToken(
        idToken: idToken,
        sign: 'apple',
      );
      
      if (loginResponse != null) {
        "✅ [WepinCubit] loginWithIdToken successful".log();
        
        // Step 2: Login to Wepin (위핀 개발팀 제안)
        "📍 [WepinCubit] Step 2: Calling loginWepin...".log();
        final wepinLoginResponse = await state.wepinWidgetSDK!.login.loginWepin(loginResponse);
        
        if (wepinLoginResponse != null) {
          "✅ [WepinCubit] loginWepin successful".log();
          
          // Update status after successful login
          final newStatus = await state.wepinWidgetSDK!.getStatus();
          "📊 [WepinCubit] New Wepin status: $newStatus".log();
          
          emit(state.copyWith(
            wepinLifeCycleStatus: newStatus,
            isLoading: false,
          ));
          
          "✅ [WepinCubit] Apple login flow completed successfully".log();
        } else {
          "❌ [WepinCubit] loginWepin failed".log();
          emit(state.copyWith(
            isLoading: false,
            error: 'Failed to complete Wepin login',
          ));
        }
      } else {
        "❌ [WepinCubit] loginWithIdToken failed".log();
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to login with Apple ID token',
        ));
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
    // Finalize SDK after closing widget
    try {
      await state.wepinWidgetSDK!.finalize();
      "✅ WePIN SDK finalized after closing widget".log();
    } catch (e) {
      "⚠️ Error finalizing WePIN SDK: $e".log();
    }
    
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
      // Finalize SDK on error
      try {
        await state.wepinWidgetSDK!.finalize();
        "✅ WePIN SDK finalized after error".log();
      } catch (finalizeError) {
        "⚠️ Error finalizing WePIN SDK: $finalizeError".log();
      }
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
              
              // Check if this is from onboarding flow (wallet already exists)
              if (state.isOnboardingFlow) {
                "🎯 Wallet already exists from ONBOARDING - signaling completion".log();
                emit(state.copyWith(
                  walletCreatedFromOnboarding: true,
                  isOnboardingFlow: false,
                ));
                stopWalletCheckTimer();
                dismissLoader();
              }
              // If wallet is already saved and we're trying to redeem NFT
              else if (state.isPerformWepinWelcomeNftRedeem && 
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

  /// 공통 오류 처리 함수
  void _handleWepinError(dynamic error, String operation) {
    final errorString = error.toString();
    "❌ Wepin error during $operation: $errorString".log();
    
    // InvalidLoginSession 감지 및 처리
    if (errorString.contains('InvalidLoginSession')) {
      "🔄 InvalidLoginSession detected during $operation".log();
      _handleInvalidLoginSessionError();
    }
    // 네트워크 관련 오류
    else if (errorString.contains('Network') || 
             errorString.contains('timeout') ||
             errorString.contains('Connection')) {
      "🌐 Network error detected during $operation".log();
      emit(state.copyWith(
        isLoading: false,
        error: 'Network error. Please check your connection and try again.',
      ));
    }
    // 일반 오류
    else {
      emit(state.copyWith(
        isLoading: false,
        error: 'An error occurred during $operation. Please try again.',
      ));
    }
  }

  /// InvalidLoginSession 오류 처리
  void _handleInvalidLoginSessionError() {
    "🔄 Handling InvalidLoginSession error...".log();
    
    // 세션 상태 리셋
    emit(state.copyWith(
      wepinLifeCycleStatus: WepinLifeCycle.initialized,
      isLoading: false,
      error: 'Session expired. Please login again.',
    ));
    
    // 토큰 새로고침 시도
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        "🔄 Attempting to refresh tokens after InvalidLoginSession".log();
        await getSocialLoginValues();
        
        // 토큰이 있으면 자동 재로그인 시도
        final hasValidToken = (state.socialTokenIsAppleOrGoogle == 'GOOGLE' && 
                              (state.googleAccessToken?.isNotEmpty ?? false)) ||
                             (state.socialTokenIsAppleOrGoogle == 'APPLE' && 
                              (state.appleIdToken?.isNotEmpty ?? false));
        
        if (hasValidToken) {
          "🔄 Valid token found, attempting automatic re-login".log();
          await loginSocialAuthProvider();
        } else {
          "⚠️ No valid token found for automatic re-login".log();
        }
      } catch (e) {
        "❌ Failed to recover from InvalidLoginSession: $e".log();
      }
    });
  }

  /// 토큰 유효성 검사
  bool _isTokenValid(String? token) {
    return token != null && 
           token.isNotEmpty && 
           token.length > 10 && // 최소 길이 체크
           !token.contains('null') && // null 문자열 체크
           token.split('.').length >= 2; // JWT 기본 구조 체크 (header.payload)
  }

  /// 안전한 Wepin 상태 가져오기
  Future<WepinLifeCycle?> _getSafeWepinStatus() async {
    try {
      if (state.wepinWidgetSDK == null) {
        "⚠️ Wepin SDK is null".log();
        return null;
      }
      
      return await state.wepinWidgetSDK!.getStatus()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      "❌ Failed to get Wepin status safely: $e".log();
      return null;
    }
  }
}
