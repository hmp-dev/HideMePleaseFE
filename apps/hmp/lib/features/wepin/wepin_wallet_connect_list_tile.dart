// class WepinWalletConnectLisTile extends StatefulWidget {

// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/error_codes.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/home/presentation/widgets/free_welcome_nft_card.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

/// [WepinWalletConnectLisTile] is a stateless widget that displays
/// the home view before the wallet is connected.
///
/// It listens to the [WalletsCubit] state and shows an error snackbar
/// if there is an error in connecting the wallet. It also listens to the
/// [NftCubit] state and shows the welcome NFT card if it is available.
class WepinWalletConnectLisTile extends StatefulWidget {
  final bool isShowWelcomeNFTCard;
  final bool isPerformRedeemWelcomeNft;

  /// Creates a [WepinWalletConnectLisTile].
  ///
  /// The [onConnectWallet] callback is called when the user taps the
  /// connect wallet button.
  const WepinWalletConnectLisTile({
    super.key,
    this.isShowWelcomeNFTCard = false,
    this.isPerformRedeemWelcomeNft = false,
  });

  @override
  State<WepinWalletConnectLisTile> createState() =>
      _WepinWalletConnectLisTileState();
}

class _WepinWalletConnectLisTileState extends State<WepinWalletConnectLisTile> {
  String? googleAccessToken;
  String? socialTokenIsAppleOrGoogle;
  String? appleIdToken;

  final Map<String, String> currency = {
    'ko': 'KRW',
    'en': 'USD',
    'ja': 'JPY',
  };

  WepinWidgetSDK? wepinSDK;
  String? selectedValue = sdkConfigs[0]['name'];

  WepinLifeCycle wepinStatus = WepinLifeCycle.notInitialized;
  String userEmail = '';
  List<WepinAccount> selectedAccounts = [];
  List<WepinAccount> accountsList = [];
  List<WepinAccountBalanceInfo> balanceList = [];
  List<WepinNFT> nftList = [];
  bool isLoading = false;
  //String? privateKey;
  //List<LoginProvider> loginProviders = sdkConfigs[0]['loginProviders'];
  //List<LoginProvider> selectedSocialLogins = sdkConfigs[0]['loginProviders'];

  @override
  void initState() {
    super.initState();
    initValues();
  }

  initValues() async {
    googleAccessToken =
        await getIt<AuthCubit>().refreshGoogleAccessToken() ?? '';
    socialTokenIsAppleOrGoogle =
        await getIt<AuthLocalDataSource>().getSocialTokenIsAppleOrGoogle() ??
            '';
    appleIdToken = await getIt<AuthCubit>().refreshAppleIdToken() ?? '';

    setState(() {});
  }

  void initializeWepinSdk() {
    final selectedConfig =
        sdkConfigs.firstWhere((config) => config['name'] == selectedValue);
    //_updateConfig(selectedConfig);
    initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
        selectedConfig['privateKey']!);
  }

  // void _updateConfig(Map<String, dynamic> config) {
  //   setState(() {
  //     privateKey = config['privateKey'];
  //     loginProviders = config['loginProviders'];
  //     selectedSocialLogins = config['loginProviders'];
  //   });
  // }

  Future<void> initWepinSDK(
      String appId, String appKey, String privateKey) async {
    // Show Loader
    getIt<WepinCubit>().showLoader();

    wepinSDK?.finalize();
    wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);
    await wepinSDK!.init(
      attributes: WidgetAttributes(
          defaultLanguage: context.locale.languageCode,
          defaultCurrency: currency[context.locale.languageCode]!),
    );

    wepinStatus = await wepinSDK!.getStatus();
    // Save to Cubit
    getIt<WepinCubit>().updateWepinStatus(wepinStatus);
    //
    userEmail = wepinStatus == WepinLifeCycle.login
        ? (await wepinSDK!.login.getCurrentWepinUser())?.userInfo?.email ?? ''
        : '';

    if (wepinStatus == WepinLifeCycle.notInitialized) {
      showError('WepinSDK is not initialized.');
    }

    getStatus();
    //setState(() {});

    // call Login with AccessToken

    if (wepinSDK != null) {
      loginSocialAuthProvider();
    }
  }

  void showError(String message) {
    "Error occurred: $message".log();
    //
    if (!message.contains('User Cancel')) {
      context.showErrorSnackBar(LocaleKeys.somethingError.tr());
    }

    // showDialog(
    //   context: context,
    //   builder: (ctx) => CustomDialog(message: message, isError: true),
    // );
  }

  void showSuccess(String title, String message) {
    context.showSnackBar(message);
    // showDialog(
    //   context: context,
    //   builder: (ctx) => CustomDialog(title: title, message: message),
    // );
  }

  Future<void> performActionWithLoading(Function action) async {
    //setState(() => isLoading = true);
    try {
      await action();
    } catch (e) {
      showError(e.toString());
      //"Error occurred: $e".log();
    } finally {
      //setState(() => isLoading = false);
    }
  }

  Future<void> loginSocialAuthProvider() async {
    await performActionWithLoading(() async {
      try {
        LoginResult? fbToken;

        // if Login Type is Google
        if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
          fbToken = await wepinSDK!.login.loginWithAccessToken(
              provider: 'google', accessToken: googleAccessToken ?? '');
        }

        // if Login Type is Apple
        if (socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
          fbToken = await wepinSDK!.login
              .loginWithIdToken(idToken: appleIdToken ?? '');
        }

        if (fbToken != null) {
          final wepinUser = await wepinSDK?.login.loginWepin(fbToken);

          if (wepinUser != null && wepinUser.userInfo != null) {
            userEmail = wepinUser.userInfo!.email; // Update user's email
            wepinStatus = await wepinSDK!.getStatus(); // Get wepin status
            getIt<WepinCubit>().updateWepinStatus(wepinStatus);
          } else {
            ('Login Failed. No user info found.').log();

            showErrorAlertAndPerformLogout(
                errorMessage: LocaleKeys.somethingError.tr());
          }
        } else {
          ('Login Failed. Invalid token.').log();
          showErrorAlertAndPerformLogout(
              errorMessage: LocaleKeys.somethingError.tr());
        }
      } catch (e) {
        if (!e.toString().contains('UserCancelled')) {
          ('Login Failed. (error code - $e)').log();
        }

        //
        showErrorAlertAndPerformLogout(
            errorMessage: LocaleKeys.somethingError.tr());
      }
    });
  }

  void getStatus() async {
    await performActionWithLoading(() async {
      if (wepinSDK != null) {
        wepinStatus = await wepinSDK!.getStatus();
        getIt<WepinCubit>().updateWepinStatus(wepinStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WepinCubit, WepinState>(
          bloc: getIt<WepinCubit>(),
          listener: (context, state) async {
            // 0 - Listen Wepin Status if it is not initialized
            if (state.wepinLifeCycleStatus == WepinLifeCycle.notInitialized) {
              final selectedConfig = sdkConfigs
                  .firstWhere((config) => config['name'] == selectedValue);
              initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
                  selectedConfig['privateKey']!);
            }

            // 0- Listen Wepin Status if it is login before registered
            // automatically register
            if (state.wepinLifeCycleStatus ==
                WepinLifeCycle.loginBeforeRegister) {
              // Now loader will be shown by
              getIt<WepinCubit>().dismissLoader();
              await wepinSDK!.register(context);
              getStatus();
            }

            // 1- Listen Wepin Status if it is login
            // fetch the wallets created by Wepin

            if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
              accountsList = await wepinSDK!.getAccounts();

              getIt<WepinCubit>().saveAccounts(accountsList);
              // Dismiss Loader with in WepinCubit
              // Now loader will be dismmissed by
              getIt<WepinCubit>().dismissLoader();
            }

            // 2- Listen Wepin Status if it is login and wallets are in the state
            // save these wallets for the user

            if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
                state.accounts.isNotEmpty) {
              // if status is login save wallets to backend

              for (var account in accountsList) {
                logAccountDetails(account);

                if (account.network.toLowerCase() == "ethereum") {
                  getIt<WalletsCubit>().onPostWallet(
                    saveWalletRequestDto: SaveWalletRequestDto(
                      publicAddress: account.address,
                      provider: "WEPIN_EVM",
                    ),
                  );
                }
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
            // perform action to redeem free NFT only from Home ViewBefore
            // isShowWelcomeNFTCard is  true
            if (state.isSubmitSuccess) {
              if (widget.isPerformRedeemWelcomeNft) {
                // close Wallet Connect Model
                getIt<WalletsCubit>().onCloseWalletConnectModel();

                if (getIt<WalletsCubit>().state.isWepinWalletConnected &&
                    getIt<NftCubit>().state.welcomeNftEntity.remainingCount >
                        0) {
                  getIt<NftCubit>().onGetConsumeWelcomeNft();
                } else {
                  // reset all cubits
                  getIt<AppCubit>().onRefresh();
                  // Navigate to start up screen
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.startUpScreen, (route) => false);
                }
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
          bloc: getIt<NftCubit>(),
          listener: (context, nftState) {},
          builder: (context, nftState) {
            return Column(
              children: [
                (widget.isShowWelcomeNFTCard)
                    ? FreeWelcomeNftCard(
                        welcomeNftEntity: nftState.welcomeNftEntity,
                        onTapClaimButton: () {
                          initializeWepinSdk();
                        },
                      )
                    : Container(
                        margin:
                            const EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: WalletListItem(
                          title: 'Wepin',
                          onTap: () {
                            if (getIt<WalletsCubit>()
                                .state
                                .isWepinWalletConnected) {
                              getIt<WalletsCubit>().onCloseWalletConnectModel();

                              context.showSnackBar(
                                LocaleKeys.wepin_already_connected.tr(),
                              );
                            } else {
                              initializeWepinSdk();
                            }
                          },
                          imageUrl:
                              'https://dev-admin.hidemeplease.xyz/assets/244989c6-90e3-428f-b2a7-0316174240c1',
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 17,
                            color: Color(0x4DFFFFFF),
                          ),
                        ),
                      )
              ],
            );
          },
        ),
      ),
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
