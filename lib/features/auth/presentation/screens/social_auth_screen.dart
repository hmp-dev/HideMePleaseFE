// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/widgets/agree_text_widget.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
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

  @override
  void initState() {
    super.initState();
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
        Log.info('Access token: $result');
        // Navigate to next screen or perform other actions upon successful login
      } else {
        // Handle null response (possible cancellation or error)
        Log.info('Login failed: Result is null');
      }
    } catch (e) {
      Log.error('Login failed: $e');
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
          if (state.isSubmitSuccess && state.isLogInSuccessful) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.startUpScreen, (route) => false);
          }

          if (state.isSubmitFailure) {
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
                DefaultImage(
                  path: "assets/images/noonchi_graphic.png",
                  width: 94,
                  height: 99,
                ),
                const SizedBox(height: 12),
                Text(
                  "NFT로 혜택의 문을 열다",
                  textAlign: TextAlign.center,
                  style: fontTitle05Bold(),
                ),
                const VerticalSpace(60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MySocialLoginButton(
                      imagePath: "assets/social-auth-logos/ic_worldcoin.svg",
                      imgHeightWidth: 45,
                      onTap: () {
                        if (isAgreeWithTerms) {
                          getIt<AuthCubit>().onWorldIdLogin();
                        } else {
                          context
                              .showSnackBar(LocaleKeys.agreeTermsAlertMSG.tr());
                        }
                      },
                    ),
                    MySocialLoginButton(
                      imagePath: "assets/social-auth-logos/google-logo.png",
                      imgHeightWidth: 32,
                      onTap: () {
                        if (isAgreeWithTerms) {
                          getIt<AuthCubit>().onGoogleLogin();
                        } else {
                          context
                              .showSnackBar(LocaleKeys.agreeTermsAlertMSG.tr());
                        }
                      },
                    ),
                    //if (isIOS())
                    MySocialLoginButton(
                      imagePath: "assets/social-auth-logos/apple-logo.png",
                      onTap: () {
                        if (isAgreeWithTerms) {
                          getIt<AuthCubit>().onAppleLogin();
                        } else {
                          context
                              .showSnackBar(LocaleKeys.agreeTermsAlertMSG.tr());
                        }
                      },
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
                            value: isAgreeWithTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                isAgreeWithTerms = value ?? false;
                              });
                            },
                          ),
                          const Text("위 약관 내용에 동의합니다"),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MySocialLoginButton extends StatelessWidget {
  const MySocialLoginButton({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.imgHeightWidth = 36,
  });

  final String imagePath;
  final VoidCallback onTap;
  final double imgHeightWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: DefaultImage(
              path: imagePath,
              width: imgHeightWidth,
              height: imgHeightWidth,
            ),
          ),
        ));
  }
}
