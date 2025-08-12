import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/model_banner_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../../app/core/storage/secure_storage.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    getIt<AppCubit>().onStart();
    //getIt<ProfileCubit>().onStart();
    super.initState();
  }

  // start UP Logic
  //==> Check if User is LoggedIn --> in not loggedIn navigate to Social Login View
  //---->  If logged in get UserProfile date
  //---->  If logged in get userConnected Wallets
  //----> If no wallet Connected -> goto Home with showing Connect a Wallet View
  //----> If Wallet Connected -> fetch list for selected Tokens and  go to home view with  showing view connected wallets and Tokens as slider

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppCubit, AppState>(
          bloc: getIt<AppCubit>(),
          listener: (context, state) async {
            if (!state.isLoggedIn) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.socialLogin, (Route<dynamic> route) => false);
            } else {
              ("-------inside state.isLoggedIn: ${state.isLoggedIn}").log();

              await getIt<ModelBannerCubit>().onGetModelBannerInfo();

              await getIt<NftCubit>().onGetWelcomeNft();
              // User is logged in
              // a - init
              await getIt<ProfileCubit>().init();

              Future.delayed(const Duration(milliseconds: 200)).then((value) {
                // c - fetch user connected Wallets
                getIt<WalletsCubit>().onGetAllWallets();
              });
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          bloc: getIt<ProfileCubit>(),
          listener: (context, profileState) {
            if (profileState.isSubmitSuccess) {}
          },
        ),
        BlocListener<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          listenWhen: (previous, current) =>
              previous.connectedWallets != current.connectedWallets,
          listener: (context, walletsState) async {
            if (walletsState.submitStatus == RequestStatus.success) {
              // e- fetch Free Welcome NFT which also calls to fetch Selected NFTs

              if (walletsState.connectedWallets.isEmpty) {
                // If a wallet is NOT Connected
                // Update Home View to Show with Before Wallet Connected
                // and then Navigate to Home View

                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.beforeWalletConnected);

                // Check if onboarding has been completed
                final prefs = await SharedPreferences.getInstance();
                final onboardingCompleted = prefs.getBool(StorageValues.onboardingCompleted) ?? false;
                final debugMode = prefs.getBool(StorageValues.onboardingDebugMode) ?? false;
                final savedStep = prefs.getInt(StorageValues.onboardingCurrentStep);

                if (context.mounted) {
                  // Show onboarding if:
                  // 1. Debug mode is enabled (for development)
                  // 2. Onboarding not completed yet
                  // 3. There's a saved step (user left mid-onboarding)
                  if (debugMode || !onboardingCompleted || savedStep != null) {
                    '🚀 온보딩 화면으로 이동 - 디버그모드: $debugMode, 완료: $onboardingCompleted, 저장된 단계: $savedStep'.log();
                    // Show onboarding screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.onboardingScreen, (Route<dynamic> route) => false);
                  } else {
                    // Returning user - go to home
                    const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "true");
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.appScreen, (Route<dynamic> route) => false);
                  }
                }
              } else {

                bool wasNoWallet = (await const SecureStorage().read(StorageValues.wasOnWelcomeWalletConnectScreen)) == "true";

                // If a wallet is Connected
                // Update Home View to Show with Wallet Connected
                // and then Navigate to Home View
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.afterWalletConnected);

                if(wasNoWallet && StackedService.navigatorKey?.currentContext!=null){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyMembershipSettingsScreen(),
                    ),
                          (Route<dynamic> route) => false
                  );
                  /*Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.appScreen, (Route<dynamic> route) => false);*/
                  Future.delayed(const Duration(seconds: 1), () => const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "false"));
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.appScreen, (Route<dynamic> route) => false);
                }
              }
            }

            if (walletsState.submitStatus == RequestStatus.failure) {
              await getIt.reset();
              await configureDependencies();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.serverErrorPage, (Route<dynamic> route) => false);
              }
            }
          },
        ),
      ],
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/loader.json',
              ),
              Text(
                "It is Startup Screen",
                style: fontBodyMd(color: Colors.transparent),
              )
            ],
          ),
        ),
      ),
    );
  }
}
