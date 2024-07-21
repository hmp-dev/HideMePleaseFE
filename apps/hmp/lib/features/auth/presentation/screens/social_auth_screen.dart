// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
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
import 'package:mobile/features/common/presentation/widgets/open_talker_logs_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SocialAuthScreen extends StatefulWidget {
  const SocialAuthScreen({super.key});

  @override
  State<SocialAuthScreen> createState() => _SocialAuthScreenState();
}

class _SocialAuthScreenState extends State<SocialAuthScreen> {
  final FlutterAppAuth appAuth = const FlutterAppAuth();

  bool isAgreeWithTerms = false;
  int? isShowOnBoarding;

  @override
  void initState() {
    super.initState();
    checkIsShowOnBoarding();
  }

  checkIsShowOnBoarding() async {
    isShowOnBoarding = await getInitialScreen();
  }

  Future<void> _login(BuildContext context) async {
    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          'app_staging_374700e081c2e519c5f50d1f16c5507c',
          'https://hidemeplease.xyz/',
          discoveryUrl:
              'https://id.worldcoin.org/.well-known/openid-configuration',
          scopes: ['token'],
          clientSecret: 'sk_149c5f5428f1289d5cb671df741191a3716738b0764b8321',
        ),
      );

      if (result != null) {
        // Use result.accessToken for API requests
        ('Access token: $result').log();
        // Navigate to next screen or perform other actions upon successful login
      } else {
        // Handle null response (possible cancellation or error)
        ('Login failed: Result is null').log();
      }
    } catch (e) {
      ('Login failed: $e').log();
      // Handle login failure, display error message, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: BlocListener<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        listenWhen: (previous, current) =>
            previous.isLogInSuccessful != current.isLogInSuccessful,
        listener: (context, state) {
          if (state.submitStatus == RequestStatus.success &&
              state.isLogInSuccessful) {
            isShowOnBoarding == 0 || isShowOnBoarding == null
                ? Navigator.pushNamedAndRemoveUntil(
                    context, Routes.onboardingScreen, (route) => false)
                : Navigator.pushNamedAndRemoveUntil(
                    context, Routes.startUpScreen, (route) => false);
          }

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
