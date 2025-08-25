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
        // 새로운 계정 로그인 시 온보딩 상태 리셋
        try {
          '🔄 [AuthCubit] Resetting onboarding state for new account login...'.log();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(StorageValues.onboardingCurrentStep);
          await prefs.remove(StorageValues.onboardingCompleted);
          '✅ [AuthCubit] Onboarding state reset completed'.log();
        } catch (e) {
          '❌ [AuthCubit] Failed to reset onboarding state: $e'.log();
        }
        
        // Google 로그인 성공 후 Wepin 준비
        try {
          '🔄 [AuthCubit] Google login successful, preparing Wepin...'.log();
          
          // 저장 완료를 위해 짧은 지연 후 토큰 읽기
          await Future.delayed(const Duration(milliseconds: 100));
          
          final googleIdToken = await _localDataSource.getGoogleIdToken();
          '🔍 [AuthCubit] Retrieved Google ID token: ${googleIdToken?.isNotEmpty == true ? 'Success (${googleIdToken!.substring(0, 20)}...)' : 'Empty'}'.log();
          
          if (googleIdToken != null && googleIdToken.isNotEmpty) {
            '🔑 [AuthCubit] Got Google ID token, marking Wepin as ready...'.log();
            await getIt<WepinCubit>().loginWepinWithGoogle(googleIdToken);
          } else {
            '❌ [AuthCubit] Google ID token is empty, retrying...'.log();
            
            // 한 번 더 시도 (더 긴 지연)
            await Future.delayed(const Duration(milliseconds: 500));
            final retryToken = await _localDataSource.getGoogleIdToken();
            
            if (retryToken != null && retryToken.isNotEmpty) {
              '🔄 [AuthCubit] Retry successful, marking Wepin as ready...'.log();
              await getIt<WepinCubit>().loginWepinWithGoogle(retryToken);
            } else {
              '❌ [AuthCubit] Google ID token still empty after retry'.log();
            }
          }
        } catch (e) {
          '❌ [AuthCubit] Failed to prepare Wepin after Google auth: $e'.log();
        }
        
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

        // Save both access token and ID token
        final googleAccessToken = googleAuth.accessToken ?? "";
        final googleIdToken = googleAuth.idToken ?? "";
        
        _localDataSource.setGoogleAccessToken(googleAccessToken);
        _localDataSource.setGoogleIdToken(googleIdToken);
        
        // Return ID token for Wepin SDK
        return googleIdToken;
        // return googleAuth.idToken;//Wepin has suggested that login with id token is recommended. Hence made this change.
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

  Future<String?> refreshAppleIdToken() async {
    try{
      final firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken() ?? "";
      final result = await _authRepository.requestApiLogin(firebaseToken: firebaseToken);


    } catch(e, st){
      ('Error refreshing Apple ID token: $e').log();
    }
    return _localDataSource.getAppleIdToken();
    try {
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
    } catch (e) {
      ('Error refreshing Apple ID token: $e').log();
    }
    return null;
  }

  Future<void> onAppleLogin() async {
    final result = await _authRepository.requestAppleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) async {
        // 새로운 계정 로그인 시 온보딩 상태 리셋
        try {
          '🔄 [AuthCubit] Resetting onboarding state for new account login...'.log();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(StorageValues.onboardingCurrentStep);
          await prefs.remove(StorageValues.onboardingCompleted);
          '✅ [AuthCubit] Onboarding state reset completed'.log();
        } catch (e) {
          '❌ [AuthCubit] Failed to reset onboarding state: $e'.log();
        }
        
        // Apple 로그인 성공 후 Wepin 준비
        try {
          '🔄 [AuthCubit] Apple login successful, preparing Wepin...'.log();
          final appleIdToken = await _localDataSource.getAppleIdToken();
          if (appleIdToken != null && appleIdToken.isNotEmpty) {
            '🔑 [AuthCubit] Got Apple ID token, marking Wepin as ready...'.log();
            await getIt<WepinCubit>().loginWepinWithApple(appleIdToken);
          } else {
            '❌ [AuthCubit] Apple ID token is empty'.log();
          }
        } catch (e) {
          '❌ [AuthCubit] Failed to prepare Wepin after Apple auth: $e'.log();
        }
        
        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<void> onWorldIdLogin() async {}
  Future<void> onBackendApiLogin({
    required String firebaseIdToken,
  }) async {
    EasyLoading.show();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response =
        await _authRepository.requestApiLogin(firebaseToken: firebaseIdToken);

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
}
