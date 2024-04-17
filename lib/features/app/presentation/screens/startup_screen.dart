// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen> {
  @override
  void initState() {
    getIt<AppCubit>().onStart();
    //getIt<ProfileCubit>().onStart();
    super.initState();

    // _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppCubit, AppState>(
          bloc: getIt<AppCubit>(),
          listener: (context, state) {
            if (!state.isLoggedIn) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.socialLogin,
                (route) => false,
              );
            }

            if (state.isLoggedIn) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.appHome,
                (route) => false,
              );
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          bloc: getIt<ProfileCubit>(),
          listener: (context, profileState) {
            if (profileState.isSuccess) {
              Log.info("Profile: ${profileState.userProfile}");
            }
          },
        ),
      ],
      child: const BaseScaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
    );
  }
}
