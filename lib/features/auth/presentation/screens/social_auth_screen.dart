import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/target.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/widgets/agree_text_widget.dart';
import 'package:mobile/features/auth/presentation/widgets/social_login_button.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_check_button.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';

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
                context, Routes.appHome, (route) => false);
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
                  path: "assets/images/social_auth_screen_main_img.svg",
                  width: 50,
                  height: 91,
                ),
                const SizedBox(height: 12),
                Text(
                  "같은 가치를 이해하고 있는\n사람들과의  만남",
                  textAlign: TextAlign.center,
                  style: fontR(22),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isAgreeWithTerms = !isAgreeWithTerms;
                                });
                              },
                              child: DefaultCheckButton(
                                isSelected: isAgreeWithTerms,
                                size: 22,
                                borderRadius: 4,
                              ),
                            ),
                            const HorizontalSpace(7),
                            const AgreeTextWidget(),
                          ],
                        ),
                      ),
                      SocialLoginButton(
                        text: 'World ID로 시작',
                        buttonType: SocialLoginButtonType.worldId,
                        onPressed: () {
                          //_login(context);
                          // _launchURL(
                          //     'https://b83f-103-92-103-113.ngrok-free.app/?type=android');
                          // WebViewScreen.push(
                          //     context: context,
                          //     title: "World ID",
                          //     url:
                          //         'https://b83f-103-92-103-113.ngrok-free.app/');

                          Navigator.pushNamedAndRemoveUntil(
                              context, Routes.appHome, (route) => false);
                        },
                      ),
                      const SizedBox(height: 10),
                      SocialLoginButton(
                        text: 'Google 계정으로 시작',
                        buttonType: SocialLoginButtonType.google,
                        onPressed: () async {
                          if (isAgreeWithTerms) {
                            getIt<AuthCubit>().onGoogleLogin();
                          } else {
                            context.showSnackBar(
                                LocaleKeys.agreeTermsAlertMSG.tr());
                          }
                        },
                      ),
                      if (isIOS())
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SocialLoginButton(
                            text: 'Apple ID로 시작',
                            buttonType: SocialLoginButtonType.apple,
                            onPressed: () async {
                              if (isAgreeWithTerms) {
                                getIt<AuthCubit>().onAppleLogin();
                              } else {
                                context.showSnackBar(
                                    LocaleKeys.agreeTermsAlertMSG.tr());
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url,
          forceSafariVC: false, forceWebView: false, enableJavaScript: true);
    } else {
      throw 'Could not launch $url';
    }
  }
}


//web3modalflutter:// 