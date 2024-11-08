// class WepinWalletConnectLisTile extends StatefulWidget {

// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/community/presentation/widgets/get_free_nft_view.dart';
import 'package:mobile/features/home/presentation/widgets/free_welcome_nft_card.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class WepinWalletConnectLisTile extends StatefulWidget {
  final bool isShowWelcomeNFTCard;
  final bool isShowCustomButton;
  final bool isPerformRedeemWelcomeNft;
  final bool isShowWalletConnectModelButton;
  final bool isShowCommunityWelcomeNFTRedeemButton;

  /// Creates a [WepinWalletConnectLisTile].
  ///
  /// The [onConnectWallet] callback is called when the user taps the
  /// connect wallet button.
  const WepinWalletConnectLisTile({
    super.key,
    this.isShowWelcomeNFTCard = false,
    this.isPerformRedeemWelcomeNft = false,
    this.isShowCustomButton = false,
    this.isShowWalletConnectModelButton = false,
    this.isShowCommunityWelcomeNFTRedeemButton = false,
  });

  @override
  State<WepinWalletConnectLisTile> createState() =>
      _WepinWalletConnectLisTileState();
}

class _WepinWalletConnectLisTileState extends State<WepinWalletConnectLisTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    //getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletsCubit, WalletsState>(
      // Listen to the wallets cubit state
      bloc: getIt<WalletsCubit>(),
      listenWhen: (previous, current) =>
          previous.connectedWallets.length != current.connectedWallets.length &&
          previous.connectedWallets != current.connectedWallets,
      listener: (context, state) {
        // perform action to redeem free NFT only from Home ViewBefore
        // isShowWelcomeNFTCard is  true
        if (state.isSubmitSuccess && !state.isWelcomeNftRedeemInProcess) {
          getIt<WalletsCubit>().onUpdateIsWelcomeNftRedeemInProcess(true);
          // close Wallet Connect Model
          getIt<WalletsCubit>().onCloseWalletConnectModel();

          if (widget.isPerformRedeemWelcomeNft) {
            if (getIt<WalletsCubit>().state.isWepinWalletConnected &&
                getIt<NftCubit>().state.welcomeNftEntity.remainingCount > 0) {
              "inside call to onGetConsumeWelcomeNft".log();

              getIt<NftCubit>().onGetConsumeWelcomeNft();

              //
              context.showSnackBarBottom(
                LocaleKeys.welcomeNftRedeemRequesting.tr(),
              );
            } else {
              // reset all cubits
              getIt<AppCubit>().onRefresh();
              // Navigate to start up screen
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.startUpScreen, (route) => false);
            }

            if (state.isFailure) {
              context.showErrorSnackBar(state.errorMessage);
            }
          }
        }
      },
      child: BlocConsumer<NftCubit, NftState>(
        bloc: getIt<NftCubit>(),
        listener: (context, nftState) {},
        builder: (context, nftState) {
          return Column(
            children: [
              widget.isShowCommunityWelcomeNFTRedeemButton
                  ? GetFreeNftView(
                      onTap: () {
                        getIt<WepinCubit>().showLoader();

                        getIt<WepinCubit>().onConnectWepinWallet(context);
                      },
                    )
                  : (widget.isShowWelcomeNFTCard)
                      ? BlocBuilder<WepinCubit, WepinState>(
                          bloc: getIt<WepinCubit>(),
                          builder: (context, state) {
                            return FreeWelcomeNftCard(
                              welcomeNftEntity: nftState.welcomeNftEntity,
                              onTapClaimButton: () {
                                "hello the onTapClaimButton is called".tr();
                                if (state.isLoading) {
                                  return; // Do nothing if in loading state
                                }
                                getIt<WepinCubit>().showLoader();
                                getIt<WepinCubit>()
                                    .onConnectWepinWallet(context);
                              },
                            );
                          },
                        )
                      : widget.isShowCustomButton
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HMPCustomButton(
                                //Connect your WePin wallet
                                text: "위핀 지갑 연결",
                                onPressed: () {
                                  if (getIt<WalletsCubit>()
                                      .state
                                      .isWepinWalletConnected) {
                                    getIt<WalletsCubit>()
                                        .onCloseWalletConnectModel();

                                    context.showSnackBar(
                                      LocaleKeys.wepin_already_connected.tr(),
                                    );
                                  } else {
                                    getIt<WepinCubit>().showLoader();
                                    //initializeWepin();

                                    getIt<WepinCubit>()
                                        .onConnectWepinWallet(context);
                                  }
                                },
                              ),
                            )
                          : BlocConsumer<WalletsCubit, WalletsState>(
                              bloc: getIt<WalletsCubit>(),
                              listener: (context, state) {},
                              builder: (context, state) {
                                "state.tappedWalletName: ${state.tappedWalletName}"
                                    .log();
                                return ElevatedButton(
                                  style: _elevatedButtonStyle(),
                                  onPressed: () async {
                                    // getIt<WepinCubit>()
                                    //     .onResetWepinSDKFetchedWallets();

                                    // await Future.delayed(
                                    //     const Duration(milliseconds: 200));
                                    // //
                                    await getIt<WalletsCubit>()
                                        .onOpenReownAppKitBottomModal(
                                      context: context,
                                      onTapConnectWalletButton: true,
                                    );

                                    // Wait for a brief moment to ensure state is updated
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));

                                    // Re-fetch the state after the delay
                                    final updatedState =
                                        getIt<WalletsCubit>().state;

                                    if (updatedState.tappedWalletName ==
                                        WalletProvider.WEPIN.name) {
                                      getIt<WepinCubit>().showLoader();
                                      //initializeWepin();
                                      getIt<WepinCubit>()
                                          .onConnectWepinWallet(context);
                                    }
                                  },
                                  child: Text(
                                    LocaleKeys.walletConnection.tr(),
                                    style: fontCompactMdMedium(color: white),
                                  ),
                                );
                              },
                            )
            ],
          );
        },
      ),
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(bgNega4),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
    );
  }

  void logAccountDetails(WepinAccount account) {
    "the Wallet account Address is ${account.address}".log();
    "the Wallet account Network is ${account.network}".log();
    "the Wallet account Contract is ${account.contract}".log();
  }

  showErrorAlertAndPerformLogout({required String errorMessage}) {
    getIt<WepinCubit>().dismissLoader();
    context.showErrorSnackBarDismissible(errorMessage);

    // getIt<AppCubit>().onLogOut();
    // // reset all cubits
    // getIt<AppCubit>().onRefresh();
    // // Navigate to start up screen
    // Navigator.pushNamedAndRemoveUntil(
    //     context, Routes.startUpScreen, (route) => false);
  }
}
