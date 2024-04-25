// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
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

  // start UP Logic
  //==> Check if User is LoggedIn --> in not loggedIn navigate to Social Login View
  //--If logged in get UserProfile date
  //--If logged in get userConnected Wallets
  //--> If no wallet Connected -> goto Home with showing Connect a Wallet View
  //--> If Wallet Connected -> fetch list for selected Tokens and  go to home view with  showing view connected wallets and Tokens as slider

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppCubit, AppState>(
          bloc: getIt<AppCubit>(),
          listener: (context, state) {
            if (!state.isLoggedIn) {
              // User is not logged in navigate to Social Login View
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.socialLogin,
                (route) => false,
              );
            }

            if (state.isLoggedIn) {
              // User is logged in
              // a - fetch User Profile Data
              getIt<ProfileCubit>().onGetUserProfile();
              // b - fetch user connected Wallets
              getIt<WalletsCubit>().onGetAllWallets();
              // c - fetch user selected NFT Tokens
              getIt<NftCubit>().onGetSelectedNftTokens();
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
        BlocListener<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          listener: (context, walletsState) {
            if (walletsState.isSuccess) {
              //on fetching Tokens navigate to Home
              Log.info("Profile: ${walletsState.connectedWallets}");
              if (walletsState.connectedWallets.isEmpty) {
                // If a wallet is NOT Connected
                // Update Home View to Show with Before Wallet Connected
                // and then Navigate to Home View
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.beforeWalletConnected);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.appHome,
                  (route) => false,
                );
              } else {
                // If a wallet is Connected
                // Update Home View to Show with Wallet Connected
                // and then Navigate to Home View
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.beforeWalletConnected);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.appHome,
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
      child: const BaseScaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(Colors.transparent),
          ),
        ),
      ),
    );
  }
}
