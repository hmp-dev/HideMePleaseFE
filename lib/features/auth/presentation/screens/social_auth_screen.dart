import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/auth/presentation/widgets/social_login_button.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class SocialAuthScreen extends StatefulWidget {
  const SocialAuthScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SocialAuthScreen(),
      ),
    );
  }

  @override
  State<SocialAuthScreen> createState() => _SocialAuthScreenState();
}

class _SocialAuthScreenState extends State<SocialAuthScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
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
                    SocialLoginButton(
                      text: 'Google 계정으로 시작',
                      buttonType: SocialLoginButtonType.google,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 10),
                    SocialLoginButton(
                      text: 'Apple ID로 시작',
                      buttonType: SocialLoginButtonType.apple,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
