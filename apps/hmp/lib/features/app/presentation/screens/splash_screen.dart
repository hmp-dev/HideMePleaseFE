import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/common/presentation/cubit/submit_location_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  bool isAnimationComplete = false;
  bool isLocationSubmitted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _submitDeviceLocationToBackend();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitDeviceLocationToBackend() async {
    await getIt<SubmitLocationCubit>().onSubmitUserDeviceLocation();
    setState(() {
      isLocationSubmitted = true;
    });
  }

  void _navigateIfReady() {
    if (isAnimationComplete && isLocationSubmitted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.startUpScreen,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          "assets/lottie/splash.json",
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() async {
                setState(() {
                  isAnimationComplete = true;
                });
                _navigateIfReady();
              });
          },
        ),
      ),
    );
  }
}
