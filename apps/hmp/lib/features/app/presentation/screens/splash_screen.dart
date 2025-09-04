import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/submit_location_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _submitDeviceLocationToBackend();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() {
    // GIF 애니메이션 시간 고려하여 6초 후 화면 전환
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.startUpScreen,
          (route) => false,
        );
      }
    });
  }

  Future<void> _submitDeviceLocationToBackend() async {
    // call to submit location only user is logged in
    // use AppCubit to Check if user isLogged in

    if (getIt<AppCubit>().state.isLoggedIn) {
      getIt<SubmitLocationCubit>().onSubmitUserDeviceLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF87CEEB),
      body: Container(
        color: const Color(0xFF87CEEB),
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/lottie/splash.gif",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
