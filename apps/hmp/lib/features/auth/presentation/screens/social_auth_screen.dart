// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/target.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/widgets/agree_text_widget.dart';
import 'package:mobile/features/auth/presentation/widgets/my_social_login_button.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/auth/presentation/widgets/terms_modal_dialog.dart';
import 'package:mobile/features/auth/data/terms_data.dart';

class SocialAuthScreen extends StatefulWidget {
  const SocialAuthScreen({super.key});

  @override
  State<SocialAuthScreen> createState() => _SocialAuthScreenState();
}

class _SocialAuthScreenState extends State<SocialAuthScreen> with WidgetsBindingObserver {
  //final FlutterAppAuth appAuth = const FlutterAppAuth();

  bool isAgreeWithTerms = false;
  int? isShowOnBoarding;
  bool _isActivelyLoggingIn = false;  // Track if login is in progress
  bool _isFirstBuild = true;  // Prevent initial trigger
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkIsShowOnBoarding();
    _checkAndRequestLocationPermission();

    // Check if already logged in and redirect if necessary
    _checkExistingLoginState();

    // Delay SDK initialization to avoid context issues
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _initWallets();
      }
    });
  }

  void _checkExistingLoginState() {
    final authState = getIt<AuthCubit>().state;
    '🔍 [SocialAuthScreen] Checking existing login state - isLogInSuccessful: ${authState.isLogInSuccessful}'.log();

    // If already logged in, navigate away immediately
    if (authState.isLogInSuccessful) {
      '⚠️ [SocialAuthScreen] User already logged in, should not be on login screen'.log();
      // Don't navigate here, let StartupScreen handle it
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    '📱 [SocialAuthScreen] App lifecycle changed: $_lastLifecycleState -> $state'.log();

    if (_lastLifecycleState == AppLifecycleState.paused &&
        state == AppLifecycleState.resumed) {
      '📱 [SocialAuthScreen] App resumed from background'.log();
      // When returning from settings, reset the active login flag
      // to prevent automatic navigation
      if (!_isActivelyLoggingIn) {
        '🔒 [SocialAuthScreen] Not actively logging in, preventing navigation'.log();
      }
    }

    _lastLifecycleState = state;
  }

  Future<void> _checkAndRequestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(LocaleKeys.permission_location_required.tr()),
              content: Text(LocaleKeys.permission_location_enable_msg.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.common_confirm.tr()),
                ),
              ],
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            context.showSnackBar(LocaleKeys.permission_location_denied.tr());
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(LocaleKeys.permission_location_denied_title.tr()),
              content: Text(LocaleKeys.permission_location_settings_msg.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.cancel.tr()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Open app settings
                    Geolocator.openAppSettings();
                  },
                  child: Text(LocaleKeys.settings.tr()),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 위치 정보 가져오기 (시스템 권한 요청 팝업 표시됨)
      final position = await Geolocator.getCurrentPosition();
      "현재 위치: ${position.latitude}, ${position.longitude}".log();

      
    } catch (e) {
      "Error getting location permission: $e".log();
      if (mounted) {
        context.showSnackBar(LocaleKeys.permission_location_error.tr());
      }
    }
  }

  checkIsShowOnBoarding() async {
    isShowOnBoarding = await getInitialScreen();
  }

  // Future<void> _login(BuildContext context) async {
  //   try {
  //     final AuthorizationTokenResponse? result =
  //         await appAuth.authorizeAndExchangeCode(
  //       AuthorizationTokenRequest(
  //         'app_staging_374700e081c2e519c5f50d1f16c5507c',
  //         'https://hidemeplease.xyz/',
  //         discoveryUrl:
  //             'https://id.worldcoin.org/.well-known/openid-configuration',
  //         scopes: ['token'],
  //         clientSecret: 'sk_149c5f5428f1289d5cb671df741191a3716738b0764b8321',
  //       ),
  //     );

  //     if (result != null) {
  //       // Use result.accessToken for API requests
  //       ('Access token: $result').log();
  //       // Navigate to next screen or perform other actions upon successful login
  //     } else {
  //       // Handle null response (possible cancellation or error)
  //       ('Login failed: Result is null').log();
  //     }
  //   } catch (e) {
  //     ('Login failed: $e').log();
  //     // Handle login failure, display error message, etc.
  //   }
  // }

  void _initWallets() async {
    try {
      '🔄 Initializing Wepin SDK from SocialAuthScreen...'.log();
      // initialize the WepinSDK and Login
      await getIt<WepinCubit>()
          .initializeWepinSDK(selectedLanguageCode: context.locale.languageCode);
      '✅ Wepin SDK initialization completed'.log();
    } catch (e) {
      '❌ Failed to initialize Wepin SDK: $e'.log();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF87CEEB),
        body: BlocListener<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        listenWhen: (previous, current) {
            // 더 포괄적인 조건으로 변경 - submitStatus 변화도 감지
            final shouldListen =
                (previous.isLogInSuccessful != current.isLogInSuccessful) ||
                (previous.submitStatus != current.submitStatus &&
                 current.submitStatus == RequestStatus.success &&
                 current.isLogInSuccessful);

            '🔍 [SocialAuthScreen] listenWhen check - '
                'prev isLogIn: ${previous.isLogInSuccessful}, '
                'curr isLogIn: ${current.isLogInSuccessful}, '
                'prev status: ${previous.submitStatus}, '
                'curr status: ${current.submitStatus}, '
                'shouldListen: $shouldListen'.log();
            return shouldListen;
        },
        listener: (context, state) async {
          '🔍 [SocialAuthScreen] BlocListener triggered - submitStatus: ${state.submitStatus}, isLogInSuccessful: ${state.isLogInSuccessful}, isActivelyLoggingIn: $_isActivelyLoggingIn, isFirstBuild: $_isFirstBuild'.log();

          // Prevent initial trigger when widget first builds (but not when actively logging in)
          if (_isFirstBuild && !_isActivelyLoggingIn) {
            '🚫 [SocialAuthScreen] Ignoring first build trigger (not actively logging in)'.log();
            _isFirstBuild = false;
            return;
          }
          _isFirstBuild = false;  // Reset flag after first check

          // Only process if actively logging in
          if (!_isActivelyLoggingIn) {
            '🔒 [SocialAuthScreen] Not actively logging in, ignoring state change'.log();
            return;
          }

          // 로딩 상태 처리
          if (state.submitStatus == RequestStatus.loading) {
            '⏳ [SocialAuthScreen] Showing loading indicator...'.log();
            EasyLoading.show(
              status: LocaleKeys.onboarding_preparing.tr(),
              maskType: EasyLoadingMaskType.black,
            );
            return;
          }

          // 로딩이 끝났을 때 dismiss
          EasyLoading.dismiss();

          // 성공 상태 처리
          if (state.submitStatus == RequestStatus.success && state.isLogInSuccessful) {
            '✅ [SocialAuthScreen] Login successful, checking onboarding requirements...'.log();
            // Wepin SDK 상태 로깅
            if (getIt<WepinCubit>().state.wepinWidgetSDK != null) {
              "${getIt<WepinCubit>().state}".log();
            }

            // 로딩 화면을 보여주기 위한 짧은 지연
            await Future.delayed(const Duration(milliseconds: 500));

            // 지갑과 프로필 정보 가져오기
            '🔍 Checking wallet and profile status...'.log();
            
            // 지갑 정보 확인
            await getIt<WalletsCubit>().onGetAllWallets();
            final hasWallet = await getIt<WalletsCubit>().hasWallet();
            '💼 Has wallet: $hasWallet'.log();
            
            // 프로필 정보 확인
            await getIt<ProfileCubit>().onGetUserProfile();
            final hasProfileParts = await getIt<ProfileCubit>().hasProfileParts();
            '👤 Has profile parts: $hasProfileParts'.log();
            
            // 온보딩 표시 여부 결정
            final shouldShowOnboarding = !hasWallet || !hasProfileParts;
            '🎯 Should show onboarding: $shouldShowOnboarding (hasWallet: $hasWallet, hasProfileParts: $hasProfileParts)'.log();
            
            // 화면 전환
            //if (true) { //debug
            if (shouldShowOnboarding) {
              // 지갑이 없거나 프로필 파츠가 없으면 온보딩 화면으로
              '📱 [SocialAuthScreen] Navigating to onboarding screen'.log();

              // Reset active login flag before navigation
              setState(() {
                _isActivelyLoggingIn = false;
              });

              await Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.onboardingScreen,
                (route) => false,
              );
            } else {
              // 둘 다 있으면 StartUp 화면으로
              '📱 [SocialAuthScreen] Navigating to startup screen'.log();

              // Reset active login flag before navigation
              setState(() {
                _isActivelyLoggingIn = false;
              });

              await Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.startUpScreen,
                (route) => false,
              );
            }
            return;
          }

          // 실패 상태 처리
          if (state.submitStatus == RequestStatus.failure) {
            '❌ [SocialAuthScreen] Login failed: ${state.message}'.log();

            // Reset active login flag on failure
            setState(() {
              _isActivelyLoggingIn = false;
            });

            context.showErrorSnackBar(state.message);
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB),
                Color(0xFFE6F3FB),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  CustomImageView(
                    imagePath: "assets/images/splash3.png",
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    LocaleKeys.splash_benefits_title.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  /*const SizedBox(height: 8),
                  Text(
                    LocaleKeys.splash_nearby_benefits.tr(),
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),*/
                  const Spacer(flex: 2),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF87CEEB),
                            Color(0xFFFFE4B5),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () {
                            if (isAgreeWithTerms) {
                              setState(() {
                                _isActivelyLoggingIn = true;
                              });
                              '🔑 [SocialAuthScreen] Starting Google login...'.log();
                              getIt<AuthCubit>().onGoogleLogin();
                            } else {
                              showAgreeTermsDialogue(context);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  "assets/social-auth-logos/google-logo.png",
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                LocaleKeys.auth_google_login.tr(),
                                style: TextStyle(
                                  fontFamily: 'LINESeedKR',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isIOS()) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF87CEEB),
                              Color(0xFFFFE4B5),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              if (isAgreeWithTerms) {
                                setState(() {
                                  _isActivelyLoggingIn = true;
                                });
                                '🔑 [SocialAuthScreen] Starting Apple login...'.log();
                                getIt<AuthCubit>().onAppleLogin();
                              } else {
                                showAgreeTermsDialogue(context);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    "assets/social-auth-logos/apple-logo.png",
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  LocaleKeys.auth_apple_login.tr(),
                                  style: TextStyle(
                                    fontFamily: 'LINESeedKR',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => TermsModalDialog(
                              title: LocaleKeys.terms_of_service.tr(),
                              content: TermsData.termsOfService,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          LocaleKeys.terms_of_service.tr(),
                          style: TextStyle(
                            fontFamily: 'LINESeedKR',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black87,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => TermsModalDialog(
                              title: LocaleKeys.privacy_policy.tr(),
                              content: TermsData.privacyPolicy,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          LocaleKeys.privacy_policy.tr(),
                          style: TextStyle(
                            fontFamily: 'LINESeedKR',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black87,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isAgreeWithTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              isAgreeWithTerms = value ?? false;
                            });
                          },
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: const Color(0xFF1DA1F2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleKeys.agree_to_terms.tr(),
                        style: const TextStyle(
                          fontFamily: 'LINESeedKR',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  void showAgreeTermsDialogue(BuildContext context) {
    showHmpAlertDialog(
      context: context,
      title: LocaleKeys.requiresAgreementToTermsAndConditions.tr(),
      content: LocaleKeys.agreeTermDialogMessage.tr(),
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }
}
