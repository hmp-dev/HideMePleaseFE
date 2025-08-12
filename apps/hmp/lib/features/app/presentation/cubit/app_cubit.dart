// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';

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
      (error) => emit(
        state.copyWith(isLoggedIn: false),
      ),
      (authToken) async {
        emit(state.copyWith(isLoggedIn: true));
        
        // 자동 로그인 성공 시 Wepin SDK 초기화 및 소셜 토큰 전달
        await _initializeWepinForAutoLogin();
      },
    );
  }

  Future<void> onLogOut() async {
    if (!state.isLoggedIn) return;
    ("inside onLogOut").log();
    EasyLoading.show();

    final result = await _authRepository.requestLogOut();

    result.fold(
      (l) => ("inside onLogOut Error").log(),
      (r) async {
        _secureStorage.delete(StorageValues.appleIdToken);
        _secureStorage.delete(StorageValues.googleAccessToken);
        _secureStorage.delete(StorageValues.socialTokenIsAppleOrGoogle);

        // logout from wepin
        await getIt<WepinCubit>().onLogoutWepinSdk();
        // emit state for login status as false
        emit(state.copyWith(isLoggedIn: false));
      },
    );

    EasyLoading.dismiss();

    await getIt.reset();

    // DI
    await configureDependencies();

    onStart();
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
      
      // 1. Wepin SDK 초기화
      await getIt<WepinCubit>().initializeWepinSDK(
        selectedLanguageCode: 'ko', // 기본값 또는 사용자 설정에서 가져오기
      );
      
      // 2. 저장된 소셜 토큰 확인 및 전달
      final socialTokenType = await _secureStorage.read(StorageValues.socialTokenIsAppleOrGoogle);
      
      if (socialTokenType != null) {
        '🔑 [AppCubit] Found stored social token type: $socialTokenType'.log();
        
        if (socialTokenType == 'GOOGLE') {
          final googleIdToken = await _secureStorage.read(StorageValues.googleIdToken);
          if (googleIdToken != null && googleIdToken.isNotEmpty) {
            '🔄 [AppCubit] Auto-login with stored Google ID token'.log();
            await getIt<WepinCubit>().loginWepinWithGoogle(googleIdToken);
          } else {
            '❌ [AppCubit] Google token type found but ID token is empty'.log();
          }
        } else if (socialTokenType == 'APPLE') {
          final appleToken = await _secureStorage.read(StorageValues.appleIdToken);
          if (appleToken != null && appleToken.isNotEmpty) {
            '🔄 [AppCubit] Auto-login with stored Apple token'.log();
            await getIt<WepinCubit>().loginWepinWithApple(appleToken);
          } else {
            '❌ [AppCubit] Apple token type found but token is empty'.log();
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
