import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Lottie.asset(
          "assets/lottie/splash.json",
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() async {
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.startUpScreen, (route) => false);
                }
              });
          },
        ),
      ),
    );
  }
}
