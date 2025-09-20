// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/services/live_activity_service.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_state.dart';

@lazySingleton
class AppCubit extends BaseCubit<AppState> {
  final AuthRepository _authRepository;

  AppCubit(this._authRepository) : super(AppState.initial());

  final SecureStorage _secureStorage = getIt<SecureStorage>();

  Future<void> onStart() async {
    await _updateAuthStatus();
  }

  Future<void> _updateAuthStatus() async {
    final authTokenRes = await _authRepository.getAuthToken();

    authTokenRes.fold(
      (error) {
        '❌ [AppCubit] No auth token found or error: $error'.log();
        emit(
          state.copyWith(isLoggedIn: false),
        );
      },
      (authToken) async {
        '🔑 [AppCubit] Auth token found, checking validity...'.log();

        // Check if this is a fresh install by checking for user data
        final prefs = await SharedPreferences.getInstance();

        // More comprehensive check for fresh install
        final hasUserData = prefs.containsKey('userId') ||
                           prefs.containsKey('userEmail') ||
                           prefs.containsKey(StorageValues.hasWallet) ||
                           prefs.containsKey(StorageValues.hasProfileParts) ||
                           prefs.containsKey(StorageValues.onboardingCompleted);

        // Also check if we have a valid social token type stored
        final socialTokenType = await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle);

        if (!hasUserData) {
          '⚠️ [AppCubit] Token exists but no user data - likely stale token from previous install'.log();
          '🧹 [AppCubit] Clearing ALL stale auth data...'.log();

          // Clear ALL auth-related data
          await _secureStorage.delete('authToken');
          await _secureStorage.delete(StorageValues.appleIdToken);
          await _secureStorage.delete(StorageValues.googleAccessToken);
          await _secureStorage.delete(StorageValues.socialTokenIsAppleOrGoogle);
          await _secureStorage.deleteAll(); // Clear all secure storage to be safe

          emit(state.copyWith(isLoggedIn: false));
          return;
        }

        // Even if we have user data, verify it's consistent
        if (socialTokenType == null || socialTokenType.isEmpty) {
          '⚠️ [AppCubit] User data exists but no social token type - inconsistent state'.log();
          '🧹 [AppCubit] Clearing auth tokens due to inconsistent state...'.log();

          // Clear auth tokens but keep user preferences
          await _secureStorage.delete('authToken');
          await _secureStorage.delete(StorageValues.appleIdToken);
          await _secureStorage.delete(StorageValues.googleAccessToken);
          await _secureStorage.delete(StorageValues.socialTokenIsAppleOrGoogle);

          emit(state.copyWith(isLoggedIn: false));
          return;
        }

        '✅ [AppCubit] Valid auth token and user data found'.log();
        emit(state.copyWith(isLoggedIn: true));

        // 자동 로그인 성공 시 Wepin SDK 초기화 및 소셜 토큰 전달
        await _initializeWepinForAutoLogin();
      },
    );
  }

  Future<void> onLogOut() async {
    if (!state.isLoggedIn) {
      '⚠️ [AppCubit] User is not logged in, skipping logout'.log();
      return;
    }

    '🔴 [AppCubit] Starting logout process...'.log();

    try {
      EasyLoading.show();

      final result = await _authRepository.requestLogOut();

      await result.fold(
        (error) async {
          '❌ [AppCubit] Logout API request failed: $error'.log();
          // Even if API logout fails, clear local data
          await _clearLocalDataOnLogout();
        },
        (success) async {
          '✅ [AppCubit] Logout API request successful'.log();
          await _clearLocalDataOnLogout();
        },
      );

      // logout from wepin - handle errors gracefully
      try {
        '🔑 [AppCubit] Logging out from WePIN SDK...'.log();
        await getIt<WepinCubit>().onLogoutWepinSdk();
        '✅ [AppCubit] WePIN SDK logout successful'.log();
      } catch (e) {
        '⚠️ [AppCubit] WePIN SDK logout failed (continuing): $e'.log();
      }

      // emit state for login status as false
      emit(state.copyWith(isLoggedIn: false));
      '✅ [AppCubit] User logged out successfully'.log();

      // Reset DI container - do this last
      try {
        await getIt.reset();
        await configureDependencies();
        onStart();
      } catch (e) {
        '⚠️ [AppCubit] DI reset failed: $e'.log();
      }

    } catch (e) {
      '❌ [AppCubit] Logout process error: $e'.log();
      // Try to clear local data even if logout fails
      try {
        await _clearLocalDataOnLogout();
        emit(state.copyWith(isLoggedIn: false));
      } catch (cleanupError) {
        '❌ [AppCubit] Failed to clear local data: $cleanupError'.log();
      }
      rethrow; // Re-throw to be caught by the UI
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _clearLocalDataOnLogout() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(StorageValues.appleIdToken);
      await _secureStorage.delete(StorageValues.googleAccessToken);
      await _secureStorage.delete(StorageValues.socialTokenIsAppleOrGoogle);
      '✅ [AppCubit] Secure storage cleared'.log();

      // Set flag to show onboarding after logout and clear onboarding data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageValues.showOnboardingAfterLogout, true);
      await prefs.remove(StorageValues.onboardingCompleted);
      await prefs.remove(StorageValues.onboardingCurrentStep);
      await prefs.remove('profilePartsString'); // 프로필 이미지 데이터 삭제
      await prefs.remove(StorageValues.hasProfileParts); // Clear profile parts flag
      '✅ [AppCubit] SharedPreferences cleared'.log();

      // End Live Activity before logout
      try {
        final liveActivityService = getIt<LiveActivityService>();
        await liveActivityService.endCheckInActivity();
        '✅ [AppCubit] Live Activity ended'.log();
      } catch (e) {
        '⚠️ [AppCubit] Live Activity end failed (non-critical): $e'.log();
      }
    } catch (e) {
      '❌ [AppCubit] Error clearing local data: $e'.log();
      throw e;
    }
  }

  Future<void> onRefresh() async {
    if (!state.isLoggedIn) return;

    await getIt.reset();

    // DI
    await configureDependencies();

    onStart();
  }

  void markInitialized() {
    emit(state.copyWith(initialized: true));
  }

  void markUnInitialized() {
    emit(state.copyWith(initialized: false));
  }

  /// 자동 로그인 시 Wepin SDK 초기화 및 소셜 토큰 전달
  Future<void> _initializeWepinForAutoLogin() async {
    try {
      '🔄 [AppCubit] Auto-login detected, initializing Wepin SDK...'.log();
      
      final wepinCubit = getIt<WepinCubit>();
      
      // 1. Wepin SDK 초기화
      await wepinCubit.initializeWepinSDK(
        selectedLanguageCode: 'ko', // 기본값 또는 사용자 설정에서 가져오기
      );
      
      // 2. SDK 상태 확인 및 현재 사용자 확인
      if (wepinCubit.state.wepinWidgetSDK != null) {
        final status = await wepinCubit.state.wepinWidgetSDK!.getStatus();
        '📊 [AppCubit] WePIN SDK status after init: $status'.log();
        
        // 현재 WePIN 사용자 확인
        try {
          final currentUser = await wepinCubit.state.wepinWidgetSDK!.login.getCurrentWepinUser();
          
          if (currentUser != null && currentUser.userInfo != null) {
            '✅ [AppCubit] WePIN 사용자 이미 로그인됨: ${currentUser.userInfo!.email}'.log();
            '📊 [AppCubit] 로그인 상태: ${currentUser.userStatus?.loginStatus}'.log();
            
            // 로그인 완료 상태면 추가 작업 불필요
            if (currentUser.userStatus?.loginStatus == 'complete') {
              '✅ [AppCubit] WePIN 로그인 완료 상태, 토큰 재발급 불필요'.log();
              return;
            }
          } else {
            '⚠️ [AppCubit] WePIN 사용자 정보 없음, 로그인 필요'.log();
          }
        } catch (e) {
          '⚠️ [AppCubit] getCurrentWepinUser 에러 (로그인 필요): $e'.log();
        }
        
        // 이미 로그인된 상태면 토큰 재발급 불필요
        if (status == WepinLifeCycle.login) {
          '✅ [AppCubit] WePIN already logged in, no need to refresh tokens'.log();
          return;
        }
      }
      
      // 3. 로그인이 필요한 경우 저장된 소셜 토큰 확인 및 전달
      final socialTokenType = await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle);
      
      if (socialTokenType != null) {
        '🔑 [AppCubit] Found stored social token type: $socialTokenType'.log();
        
        if (socialTokenType == 'GOOGLE') {
          var googleIdToken = await _secureStorage.read(StorageValues.googleIdToken);
          
          // 토큰이 없거나 비어있으면 리프레시 시도
          if (googleIdToken == null || googleIdToken.isEmpty) {
            '⚠️ [AppCubit] Google ID token empty, attempting to refresh...'.log();
            final refreshedToken = await getIt<AuthCubit>().refreshGoogleAccessToken();
            if (refreshedToken != null && refreshedToken.isNotEmpty) {
              googleIdToken = refreshedToken;
              '✅ [AppCubit] Google token refreshed successfully'.log();
            }
          }
          
          if (googleIdToken != null && googleIdToken.isNotEmpty) {
            '🔄 [AppCubit] Auto-login with Google ID token'.log();
            await wepinCubit.loginWepinWithGoogle(googleIdToken);
          } else {
            '❌ [AppCubit] Failed to get valid Google token'.log();
          }
        } else if (socialTokenType == 'APPLE') {
          var appleToken = await _secureStorage.read(StorageValues.appleIdToken);
          
          // 토큰이 없거나 비어있으면 리프레시 시도
          if (appleToken == null || appleToken.isEmpty) {
            '⚠️ [AppCubit] Apple token empty, attempting to refresh...'.log();
            final refreshedToken = await getIt<AuthCubit>().refreshAppleIdToken();
            if (refreshedToken != null && refreshedToken.isNotEmpty) {
              appleToken = refreshedToken;
              '✅ [AppCubit] Apple token refreshed successfully'.log();
            }
          }
          
          if (appleToken != null && appleToken.isNotEmpty) {
            '🔄 [AppCubit] Auto-login with Apple token'.log();
            await wepinCubit.loginWepinWithApple(appleToken);
          } else {
            '❌ [AppCubit] Failed to get valid Apple token'.log();
          }
        }
      } else {
        '⚠️ [AppCubit] No social token type found, skipping Wepin login'.log();
      }
      
      '✅ [AppCubit] Wepin auto-login initialization completed'.log();
    } catch (e) {
      '❌ [AppCubit] Failed to initialize Wepin for auto-login: $e'.log();
    }
  }
}
