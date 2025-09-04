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

class SocialAuthScreen extends StatefulWidget {
  const SocialAuthScreen({super.key});

  @override
  State<SocialAuthScreen> createState() => _SocialAuthScreenState();
}

class _SocialAuthScreenState extends State<SocialAuthScreen> {
  //final FlutterAppAuth appAuth = const FlutterAppAuth();

  bool isAgreeWithTerms = false;
  int? isShowOnBoarding;

  @override
  void initState() {
    super.initState();
    checkIsShowOnBoarding();
    _checkAndRequestLocationPermission();
    // Delay SDK initialization to avoid context issues
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _initWallets();
      }
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("위치 권한 필요"),
              content: Text("이 앱은 위치 정보를 사용합니다. 위치 서비스를 활성화해주세요."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("확인"),
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
            context.showSnackBar("위치 권한이 거부되었습니다");
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("위치 권한 거부됨"),
              content: Text("설정에서 위치 권한을 활성화해주세요"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("확인"),
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
        context.showSnackBar("위치 정보를 가져오는 중 오류가 발생했습니다");
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
        listenWhen: (previous, current) =>
            previous.isLogInSuccessful != current.isLogInSuccessful,
        listener: (context, state) async {
          // 로딩 상태 처리
          if (state.submitStatus == RequestStatus.loading) {
            EasyLoading.show(
              status: '온보딩 준비 중...',
              maskType: EasyLoadingMaskType.black,
            );
            return;
          }

          // 로딩이 끝났을 때 dismiss
          EasyLoading.dismiss();

          // 성공 상태 처리
          if (state.submitStatus == RequestStatus.success && state.isLogInSuccessful) {
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
            if (shouldShowOnboarding) {
              // 지갑이 없거나 프로필 파츠가 없으면 온보딩 화면으로
              '📱 Navigating to onboarding screen'.log();
              await Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.onboardingScreen,
                (route) => false,
              );
            } else {
              // 둘 다 있으면 StartUp 화면으로
              '📱 Navigating to startup screen'.log();
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
                  const Text(
                    '쉽고 재밌게 즐기는',
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '내 주변 맛집 혜택',
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
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
                              const Text(
                                '구글 로그인',
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
                                const Text(
                                  '애플 로그인',
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
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '서비스 이용약관',
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
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '개인정보 취급방침',
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
                      const Text(
                        '위 약관 내용에 동의합니다',
                        style: TextStyle(
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
