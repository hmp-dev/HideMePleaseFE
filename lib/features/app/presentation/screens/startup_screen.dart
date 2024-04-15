// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen> {
  @override
  void initState() {
    getIt<AppCubit>().onStart();
    super.initState();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulating a delay with Future.delayed
    await Future.delayed(
        const Duration(milliseconds: 200)); // Adjust the duration as needed

    // Determine where to navigate based on app state
    final appCubit = getIt<AppCubit>();
    if (appCubit.state.status == RequestStatus.success) {
      if (appCubit.state.isLoggedIn) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.appHome,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.socialLogin,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    );
  }
}
