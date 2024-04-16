import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/target.dart';
import 'package:mobile/app/core/injection/injection.dart';
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

class SocialAuthScreen extends StatefulWidget {
  const SocialAuthScreen({super.key});

  @override
  State<SocialAuthScreen> createState() => _SocialAuthScreenState();
}

class _SocialAuthScreenState extends State<SocialAuthScreen> {
  bool isAgreeWithTerms = false;

  @override
  void initState() {
    super.initState();
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
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      if (isAndroid())
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
                        SocialLoginButton(
                          text: 'Apple ID로 시작',
                          buttonType: SocialLoginButtonType.apple,
                          onPressed: () async {
                            if (isAgreeWithTerms) {
                              //TODO implement Cubit to Login with Apple
                            } else {
                              context.showSnackBar(
                                  LocaleKeys.agreeTermsAlertMSG.tr());
                            }
                          },
                        ),
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
}
