// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    // initialize the WepinSDK and Login
    await getIt<WepinCubit>()
        .initializeWepinSDK(selectedLanguageCode: context.locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: BlocListener<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        listenWhen: (previous, current) =>
            previous.isLogInSuccessful != current.isLogInSuccessful,
        listener: (context, state) async {
          // 로딩 상태 처리
          if (state.submitStatus == RequestStatus.loading) {
            EasyLoading.show();
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

            // 온보딩 여부에 따른 화면 전환
            if (isShowOnBoarding == 0 || isShowOnBoarding == null) {
              await Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.onboardingScreen,
                (route) => false,
              );
            } else {
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
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CustomImageView(
                  imagePath: "assets/images/splash2.png",
                  width: 188,
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.openTheDoorsToTheBenefitsWithNFT.tr(),
                  textAlign: TextAlign.center,
                  style: fontTitle05Bold(),
                ),
                const VerticalSpace(60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // MySocialLoginButton(
                    //   imagePath: "assets/social-auth-logos/ic_worldcoin.svg",
                    //   imgHeightWidth: 45,
                    //   onTap: () {
                    //     if (isAgreeWithTerms) {
                    //       getIt<AuthCubit>().onWorldIdLogin();
                    //     } else {
                    //       showHmpAlertDialog(
                    //         context: context,
                    //         title: LocaleKeys
                    //             .requiresAgreementToTermsAndConditions
                    //             .tr(),
                    //         content: LocaleKeys.agreeTermDialogMessage.tr(),
                    //         onConfirm: () {
                    //           Navigator.pop(context);
                    //         },
                    //       );
                    //     }
                    //   },
                    // ),
                    // const HorizontalSpace(20),
                    MySocialLoginButton(
                      imagePath: "assets/social-auth-logos/google-logo.png",
                      imgHeightWidth: 32,
                      onTap: () {
                        if (isAgreeWithTerms) {
                          getIt<AuthCubit>().onGoogleLogin();

                          //getIt<AuthCubit>().loginWithProvider();
                        } else {
                          showAgreeTermsDialogue(context);
                        }
                      },
                    ),
                    if (isIOS())
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: MySocialLoginButton(
                          imagePath: "assets/social-auth-logos/apple-logo.png",
                          onTap: () {
                            if (isAgreeWithTerms) {
                              getIt<AuthCubit>().onAppleLogin();
                            } else {
                              showAgreeTermsDialogue(context);
                            }
                          },
                        ),
                      ),
                  ],
                ),
                const VerticalSpace(20),
                Center(
                  child: Column(
                    children: [
                      const AgreeTextWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            side: const BorderSide(color: fore3),
                            activeColor: hmpBlue,
                            checkColor: white,
                            value: isAgreeWithTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                isAgreeWithTerms = value ?? false;
                              });
                            },
                          ),
                          Text(
                            LocaleKeys.iAgreeToTheAboveTermsAndConditions.tr(),
                            style: fontCompactSm(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // const VerticalSpace(20),
                // const OpenTalkerLogsButton(),
                // const VerticalSpace(20),
                const Spacer(),
              ],
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
