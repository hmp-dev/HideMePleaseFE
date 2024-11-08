// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/wepin_wallet_details_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class EventsWepinScreen extends StatefulWidget {
  const EventsWepinScreen({super.key});

  @override
  State<EventsWepinScreen> createState() => _EventsWepinScreenState();
}

class _EventsWepinScreenState extends State<EventsWepinScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletsCubit, WalletsState>(
      bloc: getIt<WalletsCubit>(),
      builder: (context, state) {
        return state.isWepinWalletConnected
            ? const WepinWalletDetailsView()
            : Center(
                child: EventsComingSoonChildView(
                  onBoardingSlideData: EventsViewData(
                      titleTextA: LocaleKeys.connect_your_wepin_wallet.tr(),
                      titleTextB: "커지는 혜택", // Growing benefits"
                      descText: "무료NFT증정과 함께\n다양한 혜택을 받아보세요!",
                      animationPath: "assets/lottie/onboarding4.json"),
                ),
              );
      },
    );
  }
}

class EventsComingSoonChildView extends StatelessWidget {
  final EventsViewData onBoardingSlideData;

  const EventsComingSoonChildView(
      {super.key, required this.onBoardingSlideData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Spacer(),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: SizedBox(
              width: 182,
              height: 158,
              child: Lottie.asset(onBoardingSlideData.animationPath,
                  fit: BoxFit.contain, alignment: Alignment.center),
            ),
          ),
        ),
        const VerticalSpace(10),
        Text(
          onBoardingSlideData.titleTextA,
          textAlign: TextAlign.center,
          style: fontTitle03Bold(),
        ),
        const VerticalSpace(10),
        Text(
          onBoardingSlideData.titleTextB,
          textAlign: TextAlign.center,
          style: fontTitle03Bold(color: hmpBlue),
        ),
        const VerticalSpace(10),
        Text(
          onBoardingSlideData.descText,
          textAlign: TextAlign.center,
          style: fontCompactMd(color: fore2),
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: HMPCustomButton(
            text: "위핀 지갑 연결",
            onPressed: () {
              if (getIt<WalletsCubit>().state.isWepinWalletConnected) {
                context.showSnackBar(
                  LocaleKeys.wepin_already_connected.tr(),
                );
              } else {
                getIt<WepinCubit>().showLoader();
                getIt<WepinCubit>().onConnectWepinWallet(context,
                    isFromWePinWalletConnect: true);
              }
            },
          ),
        ),
        const VerticalSpace(30),
      ],
    );
  }
}

class EventsViewData {
  final String titleTextA;
  final String titleTextB;
  final String descText;
  final String animationPath;

  EventsViewData({
    required this.titleTextA,
    required this.titleTextB,
    required this.descText,
    required this.animationPath,
  });
}




// MultiBlocListener(
//       listeners: [
//         BlocListener<WepinCubit, WepinState>(
//           listenWhen: (previous, current) =>
//               current.isPerformWepinWalletSave &&
//               current.wepinLifeCycleStatus == WepinLifeCycle.login,
//           bloc: getIt<WepinCubit>(),
//           listener: (context, state) async {
//             if (!state.isPerformWepinWelcomeNftRedeem) {
//               "[EventsWepinScreen] the WepinState is: $state".log();

//               // Manage loader based on isLoading state
//               if (state.isLoading) {
//                 getIt<WepinCubit>().showLoader();
//               } else {
//                 getIt<WepinCubit>().dismissLoader();
//               }

//               if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
//                 await getIt<WepinCubit>().fetchAccounts();
//                 getIt<WepinCubit>()
//                     .dismissLoader(); // Ensure loader dismisses post-fetch
//               }

//               if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
//                   state.accounts.isNotEmpty) {
//                 for (var account in state.accounts) {
//                   if (account.network.toLowerCase() == "ethereum") {
//                     await getIt<WalletsCubit>().onPostWallet(
//                       saveWalletRequestDto: SaveWalletRequestDto(
//                         publicAddress: account.address,
//                         provider: "WEPIN_EVM",
//                       ),
//                     );
//                   }
//                 }
//                 getIt<WepinCubit>().openWepinWidget(context);
//                 getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
//               }
//             }
//           },
//         ),

//         // BlocListener<WepinCubit, WepinState>(
//         //   //ensure that the listenWhen condition checks if current.isPerformWepinWalletSave is true
//         //   // and that it changes only when transitioning from false to true.
//         //   listenWhen: (previous, current) =>
//         //       previous.wepinLifeCycleStatus != WepinLifeCycle.login &&
//         //       current.wepinLifeCycleStatus == WepinLifeCycle.login &&
//         //       current.isPerformWepinWalletSave,
//         //   // listenWhen: (previous, current) => current.isPerformWepinWalletSave,
//         //   bloc: getIt<WepinCubit>(),
//         //   listener: (context, state) {
//         //     if (!state.isPerformWepinWelcomeNftRedeem) {
//         //       "[EventsWepinScreen] the WepinState is: $state".log();

//         //       if (state.isLoading) {
//         //         getIt<WepinCubit>().showLoader();
//         //       } else {
//         //         getIt<WepinCubit>().dismissLoader();
//         //       }

//         //       // 1- Listen Wepin Status if it is login
//         //       // fetch the wallets created by Wepin

//         //       if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
//         //         getIt<WepinCubit>().fetchAccounts();
//         //       }

//         //       // 2- Listen Wepin Status if it is login and wallets are in the state
//         //       // save these wallets for the user

//         //       if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
//         //           state.accounts.isNotEmpty) {
//         //         // if status is login save wallets to backend

//         //         for (var account in state.accounts) {
//         //           if (account.network.toLowerCase() == "ethereum") {
//         //             getIt<WalletsCubit>().onPostWallet(
//         //               saveWalletRequestDto: SaveWalletRequestDto(
//         //                 publicAddress: account.address,
//         //                 provider: "WEPIN_EVM",
//         //               ),
//         //             );
//         //           }
//         //         }
//         //         getIt<WepinCubit>().openWepinWidget(context);
//         //         getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
//         //       }
//         //     }
//         //   },
//         // ),
//         BlocListener<WepinCubit, WepinState>(
//           listenWhen: (previous, current) =>
//               previous.wepinLifeCycleStatus !=
//                   WepinLifeCycle.loginBeforeRegister &&
//               current.wepinLifeCycleStatus ==
//                   WepinLifeCycle.loginBeforeRegister &&
//               current.isPerformWepinWalletSave,
//           // listenWhen: (previous, current) => current.isPerformWepinWalletSave,
//           bloc: getIt<WepinCubit>(),
//           listener: (context, state) {
//             if (!state.isPerformWepinWelcomeNftRedeem) {
//               if (state.wepinLifeCycleStatus ==
//                   WepinLifeCycle.loginBeforeRegister) {
//                 getIt<WepinCubit>().dismissLoader();
//                 // Now loader will be shown by
//                 getIt<WepinCubit>().registerToWepin(context);
//               }
//             }
//           },
//         )
//       ],