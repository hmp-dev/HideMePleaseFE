import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/model_banner_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/wepin_setup_pin_screen.dart';

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

                // getIt<HomeCubit>()
                //     .onUpdateHomeViewType(HomeViewType.beforeWalletConnected);

                // pass value to appHome with Navigator.pushNamedAndRemoveUntil to disconnect wallet

                // if (context.mounted) {
                //   Navigator.of(context).pushNamedAndRemoveUntil(
                //       Routes.appScreen, (Route<dynamic> route) => false);
                // }

                final idToken =
                    await getIt<AuthLocalDataSource>().getGoogleAccessToken();
                "the idToken passing to Wepin is $idToken".log();

                //getIt<WepinCubit>().loginWithGoogle(idToken ?? "");

                navigateToWepinSetupScreen(context, idToken ?? "");
              } else {
                // If a wallet is Connected
                // Update Home View to Show with Wallet Connected
                // and then Navigate to Home View
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.afterWalletConnected);

                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.appScreen, (Route<dynamic> route) => false);
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

  void navigateToWepinSetupScreen(BuildContext context, String token) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WepinSetUpPinScreen(googleAuthAccessToken: token),
      ),
    );
  }
}
