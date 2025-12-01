import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart' as helper;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit(this._authRepository, this._localDataSource)
      : super(AuthState.initial());

  final AuthRepository _authRepository;
  final AuthLocalDataSource _localDataSource;

  // Declare wepinSDK here

  Future<void> onGoogleLogin() async {
    final result = await _authRepository.requestGoogleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) async {
        // 새로운 계정 로그인 시 온보딩 상태 및 프로필 데이터 리셋
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(StorageValues.onboardingCurrentStep);
          await prefs.remove(StorageValues.onboardingCompleted);
          await prefs.remove('profilePartsString'); // Clear old profile data
          await prefs.remove(StorageValues.hasProfileParts); // Clear profile parts flag
        } catch (e) {
          // Handle error silently
        }

        // Google 로그인 성공 후 Wepin 준비
        try {
          // 저장 완료를 위해 짧은 지연 후 토큰 읽기
          await Future.delayed(const Duration(milliseconds: 100));

          final googleIdToken = await _localDataSource.getGoogleIdToken();

          if (googleIdToken != null && googleIdToken.isNotEmpty) {
            await getIt<WepinCubit>().loginWepinWithGoogle(googleIdToken);
          } else {
            // 한 번 더 시도 (더 긴 지연)
            await Future.delayed(const Duration(milliseconds: 500));
            final retryToken = await _localDataSource.getGoogleIdToken();

            if (retryToken != null && retryToken.isNotEmpty) {
              await getIt<WepinCubit>().loginWepinWithGoogle(retryToken);
            }
          }
        } catch (e) {
          // Handle error silently
        }

        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<String?> refreshGoogleAccessToken() async {
    '🔄 [AuthCubit] Starting Google token refresh...'.log();

    try {
      // Check if the user is already signed in
      // IMPORTANT: serverClientId is required to get ID token
      final googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'openid',
          'profile',
        ],
        // Web OAuth 2.0 Client ID from Firebase Console (required for ID token)
        serverClientId: '307052986452-fnrk7udocq38qvmvrejb49je531hlr8f.apps.googleusercontent.com',
      );
      var googleUser = googleSignIn.currentUser;
      '📱 [AuthCubit] Current Google user: ${googleUser?.email ?? "null"}'.log();

      // Try silent sign-in first
      if (googleUser == null) {
        '🔍 [AuthCubit] No current user, attempting silent sign-in...'.log();
        googleUser = await googleSignIn.signInSilently();
        '📱 [AuthCubit] Silent sign-in result: ${googleUser?.email ?? "null"}'.log();
      }

      if (googleUser != null) {
        '✅ [AuthCubit] Google user found, getting authentication...'.log();
        final googleAuth = await googleUser.authentication;

        // Validate tokens before proceeding
        final googleAccessToken = googleAuth.accessToken ?? "";
        final googleIdToken = googleAuth.idToken ?? "";

        '🔑 [AuthCubit] Access token length: ${googleAccessToken.length}'.log();
        '🔑 [AuthCubit] ID token length: ${googleIdToken.length}'.log();

        if (googleIdToken.isEmpty) {
          '❌ [AuthCubit] Google ID token is empty'.log();
          return null;
        }

        // Save tokens
        await _localDataSource.setSocialTokenIsAppleOrGoogle(SocialLoginType.GOOGLE.name);
        await _localDataSource.setGoogleAccessToken(googleAccessToken);
        await _localDataSource.setGoogleIdToken(googleIdToken);

        '✅ [AuthCubit] Tokens saved, returning Google OAuth ID token'.log();

        // Return the Google OAuth ID token for Wepin, not Firebase token
        return googleIdToken;
      } else {
        '❌ [AuthCubit] No Google user available after silent sign-in'.log();
        return null;
      }
    } catch (e) {
      '❌ [AuthCubit] Error during Google token refresh: $e'.log();
      return null;
    }
  }

  Future<String?> refreshAppleIdToken() async {
    try {
      '⚠️ [AuthCubit] Apple token refresh requested - checking Firebase user first'.log();

      // First, check if we have a valid Firebase user and can get the token from there
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Try to get a fresh ID token from Firebase without re-authentication
          final idToken = await currentUser.getIdToken(true);
          if (idToken != null && idToken.isNotEmpty) {
            '✅ [AuthCubit] Got fresh ID token from Firebase without re-authentication'.log();
            return idToken;
          }
        } catch (e) {
          '⚠️ [AuthCubit] Failed to refresh token from Firebase: $e'.log();
        }
      }

      // Only request new Apple credentials if absolutely necessary (user action required)
      '❌ [AuthCubit] Cannot refresh Apple token without user interaction - returning null'.log();
      return null;

      /* DISABLED: This triggers Apple login UI - should only be called on user action
      // Retrieve the stored nonce if you are using it again, or generate a new one
      final rawNonce = generateNonce();
      final nonce = helper.sha256ofString(rawNonce);

      // Request a fresh Apple credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );


      // Create a new OAuthCredential using the fresh credential from Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Re-authenticate with the new credential to refresh the token
      await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(oauthCredential);

      // save Social Login Type
      _localDataSource
          .setSocialTokenIsAppleOrGoogle(SocialLoginType.APPLE.name);
      _localDataSource.setAppleIdToken(oauthCredential.idToken ?? "");

      return oauthCredential.idToken ?? "";
      */
    } catch (e) {
      '❌ [AuthCubit] Error in refreshAppleIdToken: $e'.log();
    }
    return null;
  }

  Future<void> onAppleLogin() async {
    '🍎 [AuthCubit] Starting Apple login process...'.log();

    // 상태 초기화 - 상태 전환이 확실히 일어나도록 보장
    emit(state.copyWith(
      submitStatus: RequestStatus.initial,
      isLogInSuccessful: false,
    ));

    final result = await _authRepository.requestAppleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) async {
        '✅ [AuthCubit] Apple login successful, got Firebase ID token'.log();

        // 새로운 계정 로그인 시 온보딩 상태 및 프로필 데이터 리셋
        try {
          '🔄 [AuthCubit] Resetting onboarding state for new account login...'.log();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(StorageValues.onboardingCurrentStep);
          await prefs.remove(StorageValues.onboardingCompleted);
          await prefs.remove('profilePartsString'); // Clear old profile data
          await prefs.remove(StorageValues.hasProfileParts); // Clear profile parts flag
          '✅ [AuthCubit] Onboarding state reset completed'.log();
        } catch (e) {
          '❌ [AuthCubit] Failed to reset onboarding state: $e'.log();
        }
        
        // Apple 로그인 성공 후 Wepin 준비
        try {
          '🔄 [AuthCubit] Preparing Wepin after Apple login...'.log();

          // 저장 완료를 위해 짧은 지연 후 토큰 읽기
          await Future.delayed(const Duration(milliseconds: 100));

          final appleIdToken = await _localDataSource.getAppleIdToken();
          '🔍 [AuthCubit] Retrieved Apple ID token: ${appleIdToken?.isNotEmpty == true ? 'Success (${appleIdToken!.substring(0, 20)}...)' : 'Empty'}'.log();

          if (appleIdToken != null && appleIdToken.isNotEmpty) {
            '🔑 [AuthCubit] Got Apple ID token, logging into Wepin...'.log();
            await getIt<WepinCubit>().loginWepinWithApple(appleIdToken);
          } else {
            '❌ [AuthCubit] Apple ID token is empty, retrying...'.log();

            // 한 번 더 시도 (더 긴 지연)
            await Future.delayed(const Duration(milliseconds: 500));
            final retryToken = await _localDataSource.getAppleIdToken();

            if (retryToken != null && retryToken.isNotEmpty) {
              '🔄 [AuthCubit] Retry successful, logging into Wepin...'.log();
              await getIt<WepinCubit>().loginWepinWithApple(retryToken);
            } else {
              '❌ [AuthCubit] Apple ID token still empty after retry'.log();
            }
          }
        } catch (e) {
          '❌ [AuthCubit] Failed to prepare Wepin after Apple auth: $e'.log();
        }

        '📡 [AuthCubit] Calling backend API login with Firebase ID token...'.log();
        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<void> onWorldIdLogin() async {}
  Future<void> onBackendApiLogin({
    required String firebaseIdToken,
  }) async {
    '🚀 [AuthCubit] Starting backend API login...'.log();
    '📊 [AuthCubit] Current state - isLogInSuccessful: ${state.isLogInSuccessful}, submitStatus: ${state.submitStatus}'.log();

    EasyLoading.show();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response =
        await _authRepository.requestApiLogin(firebaseToken: firebaseIdToken);

    response.fold(
      (err) {
        '❌ [AuthCubit] Backend API login failed: ${err.message}'.log();
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          isLogInSuccessful: false,
          message: err.message,
        ));
      },
      (success) async {
        '✅ [AuthCubit] Backend API login successful!'.log();

        // Set authentication flag for auto-login validation
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(StorageValues.isAuthenticated, true);
          '✅ [AuthCubit] Authentication flag set successfully'.log();
        } catch (e) {
          '⚠️ [AuthCubit] Failed to set authentication flag: $e'.log();
          // Don't fail the login process if flag save fails
        }

        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            isLogInSuccessful: true,
            message: '',
          ),
        );
        '📊 [AuthCubit] Final state - isLogInSuccessful: true, submitStatus: success'.log();
      },
    );
  }
}
