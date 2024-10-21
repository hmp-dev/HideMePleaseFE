// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/enum/error_codes.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/home/presentation/widgets/free_welcome_nft_card.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

/// [HomeViewBeforeWalletConnect] is a stateless widget that displays
/// the home view before the wallet is connected.
///
/// It listens to the [WalletsCubit] state and shows an error snackbar
/// if there is an error in connecting the wallet. It also listens to the
/// [NftCubit] state and shows the welcome NFT card if it is available.
class HomeViewBeforeWalletConnect extends StatefulWidget {
  /// Creates a [HomeViewBeforeWalletConnect].
  ///
  /// The [onConnectWallet] callback is called when the user taps the
  /// connect wallet button.
  const HomeViewBeforeWalletConnect({
    super.key,
    required this.onConnectWallet,
    // required this.googleAccessToken,
    // required this.socialTokenIsAppleOrGoogle,
    // required this.appleIdToken,
    // required this.selectedLanguage,
  });

  /// The callback function that is called when the user taps the connect
  /// wallet button.
  final VoidCallback onConnectWallet;
  // final String googleAccessToken;
  // final String socialTokenIsAppleOrGoogle;
  // final String appleIdToken;
  // final String selectedLanguage;

  @override
  State<HomeViewBeforeWalletConnect> createState() =>
      _HomeViewBeforeWalletConnectState();
}

class _HomeViewBeforeWalletConnectState
    extends State<HomeViewBeforeWalletConnect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WepinCubit, WepinState>(
          bloc: getIt<WepinCubit>(),
          listener: (context, state) async {
            if (state.isPerformWepinWelcomeNftRedeem) {
              if (state.isLoading) {
                EasyLoading.show();
              } else {
                EasyLoading.dismiss();
              }

              // 0 - Listen Wepin Status if it is not initialized
              if (state.wepinLifeCycleStatus == WepinLifeCycle.notInitialized) {
                getIt<WepinCubit>().initWepinSDK(
                    selectedLanguageCode: context.locale.languageCode);
              }

              // 0- Listen Wepin Status if it is login before registered
              // automatically register
              if (state.wepinLifeCycleStatus ==
                  WepinLifeCycle.loginBeforeRegister) {
                // Now loader will be shown by
                getIt<WepinCubit>().registerToWepin(context);
              }

              // 1- Listen Wepin Status if it is login
              // fetch the wallets created by Wepin

              if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
                getIt<WepinCubit>().fetchAccounts();
                getIt<WepinCubit>().dismissLoader();
              }

              // 2- Listen Wepin Status if it is login and wallets are in the state
              // save these wallets for the user

              if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
                  state.accounts.isNotEmpty) {
                getIt<WepinCubit>().updateIsPerformWepinWelcomeNftRedeem(false);
                // if status is login save wallets to backend

                for (var account in state.accounts) {
                  if (account.network.toLowerCase() == "ethereum") {
                    getIt<WalletsCubit>().onPostWallet(
                      saveWalletRequestDto: SaveWalletRequestDto(
                        publicAddress: account.address,
                        provider: "WEPIN_EVM",
                      ),
                    );
                  }
                }

                getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
              }
            }
          },
        ),

        // 3- Listen Wallets status if it is saved
        // If wallets are saved into backend
        // navigate to start up screen to refetch wallets and navigate to Home
        BlocListener<WalletsCubit, WalletsState>(
          listenWhen: (previous, current) =>
              current.connectedWallets.isNotEmpty,
          bloc: getIt<WalletsCubit>(),
          listener: (context, state) {
            if (state.isSubmitSuccess) {
              final isFreeWelcomeNftAvailable =
                  getIt<NftCubit>().state.welcomeNftEntity.remainingCount > 0;

              "[HomeViewBeforeWalletConnect][WalletsCubit] inside submit success isFreeWelcomeNftAvailable: $isFreeWelcomeNftAvailable"
                  .log();
              "[HomeViewBeforeWalletConnect][WalletsCubit] inside submit success state.isWepinWalletConnected: ${state.isWepinWalletConnected}"
                  .log();
              "[HomeViewBeforeWalletConnect][WalletsCubit] inside submit success state.isKlipWalletConnected: ${state.isKlipWalletConnected}"
                  .log();

              if ((state.isWepinWalletConnected && isFreeWelcomeNftAvailable) ||
                  state.isKlipWalletConnected && isFreeWelcomeNftAvailable) {
                getIt<NftCubit>().onGetConsumeWelcomeNft();
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
            }
          },
        ),
      ],
      child: BlocListener<WalletsCubit, WalletsState>(
        // Listen to the wallets cubit state
        bloc: getIt<WalletsCubit>(),
        listener: (context, state) {
          if (state.submitStatus == RequestStatus.failure) {
            // Map the error message to the appropriate enum message
            String errorMessage = getErrorMessage(state.errorMessage);
            // Show Error Snackbar If Wallet is Already Connected
            context.showErrorSnackBarDismissible(errorMessage);
            "inside listener++++++ error message is $errorMessage".log();
          }
        },
        child: BlocConsumer<NftCubit, NftState>(
          // Listen to the NFT cubit state
          bloc: getIt<NftCubit>(),
          listener: (context, nftState) {},
          builder: (context, nftState) {
            return Column(
              children: [
                const SizedBox(height: 50),
                // Display the logo image
                DefaultImage(
                  path: "assets/images/hide-me-please-logo.png",
                  width: 200,
                ),
                const SizedBox(height: 20),
                Center(
                  // Display the welcome message
                  child: Text(
                    "지갑을 연결하고\n웹컴 NFT를 받아보세요!",
                    textAlign: TextAlign.center,
                    style: fontR(18, lineHeight: 1.4),
                  ),
                ),
                const SizedBox(height: 20),
                // Display the connect wallet button
                ElevatedButton(
                  style: _elevatedButtonStyle(),
                  onPressed: widget.onConnectWallet,
                  child: Text(
                    LocaleKeys.walletConnection.tr(),
                    style: fontCompactMdMedium(color: white),
                  ),
                ),
                const SizedBox(height: 5),
                FreeWelcomeNftCard(
                  welcomeNftEntity: nftState.welcomeNftEntity,
                  onTapClaimButton: () async {
                    getIt<WepinCubit>()
                        .updateIsPerformWepinWelcomeNftRedeem(true);
                    await getIt<WepinCubit>().initWepinSDK(
                      selectedLanguageCode: context.locale.languageCode,
                      isFromWePinWelcomeNftRedeem: true,
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// Returns the style for the elevated button.
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
    context.showErrorSnackBarDismissible(errorMessage);

    getIt<AppCubit>().onLogOut();
    // reset all cubits
    getIt<AppCubit>().onRefresh();
    // Navigate to start up screen
    Navigator.pushNamedAndRemoveUntil(
        context, Routes.startUpScreen, (route) => false);
  }
}
