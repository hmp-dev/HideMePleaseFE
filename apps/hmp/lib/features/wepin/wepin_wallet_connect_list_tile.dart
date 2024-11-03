// class WepinWalletConnectLisTile extends StatefulWidget {

// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/community/presentation/widgets/get_free_nft_view.dart';
import 'package:mobile/features/home/presentation/widgets/free_welcome_nft_card.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:mobile/generated/locale_keys.g.dart';
// import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
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
  String? googleAccessToken;
  String? socialTokenIsAppleOrGoogle;
  String? appleIdToken;
  final SecureStorage _secureStorage = getIt<SecureStorage>();

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
  }

  initSocialLoginValues() async {
    socialTokenIsAppleOrGoogle =
        await getIt<AuthLocalDataSource>().getSocialTokenIsAppleOrGoogle() ??
            '';

    if (socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
      appleIdToken =
          await _secureStorage.read(StorageValues.appleIdToken) ?? '';
    }

    if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      googleAccessToken =
          await getIt<AuthCubit>().refreshGoogleAccessToken() ?? '';
    }

    setState(() {});
  }

  void initializeWepinSdk() async {
    initSocialLoginValues();
    await Future.delayed(const Duration(milliseconds: 500));

    final selectedConfig =
        sdkConfigs.firstWhere((config) => config['name'] == selectedValue);

    if (Platform.isAndroid) {
      initWepinSDK(selectedConfig['appId']!, selectedConfig['appKeyAndroid']!,
          selectedConfig['privateKey']!);
    }

    if (Platform.isIOS &&
        socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      initWepinSDK(selectedConfig['appId']!, selectedConfig['appKeyApple']!,
          selectedConfig['privateKey']!);
    }

    if (Platform.isIOS &&
        socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
      initWepinSDK(selectedConfig['appId']!, selectedConfig['appKeyApple']!,
          selectedConfig['privateKey']!);
    }
  }

  /// Initializes the Wepin SDK.
  ///
  /// This function will finalize any existing Wepin SDK instance and then
  /// initialize a new Wepin SDK instance with the provided appId, appKey, and
  /// privateKey.
  ///
  /// If the SDK initialization is successful, it will then call the
  /// [loginSocialAuthProvider] function to attempt to login with the
  /// user's social login token.
  ///
  /// If the SDK initialization fails, it will log an error message and
  /// throw an exception.
  ///
  /// Returns a [Future] that completes when the SDK initialization is
  /// complete.
  Future<void> initWepinSDK(
      String appId, String appKey, String privateKey) async {
    await wepinSDK?.finalize();

    try {
      "Initializing WepinSDK AppKey: $appKey".log();

      wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);

      await wepinSDK!.init(
        attributes: WidgetAttributes(
            defaultLanguage: context.locale.languageCode,
            defaultCurrency: currency[context.locale.languageCode]!),
      );
    } on Exception catch (e) {
      getIt<WepinCubit>().dismissLoader();
      "Error Initializing WepinSDK: $e".log();

      throw Exception(e);
    }

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
  void dispose() {
    super.dispose();
    if (wepinSDK != null) {
      wepinSDK!.finalize();
    }
    getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WepinCubit, WepinState>(
          listenWhen: (previous, current) =>
              current.wepinLifeCycleStatus == WepinLifeCycle.login,
          bloc: getIt<WepinCubit>(),
          listener: (context, state) async {
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

        BlocListener<WepinCubit, WepinState>(
          listenWhen: (previous, current) =>
              current.wepinLifeCycleStatus == WepinLifeCycle.login,
          bloc: getIt<WepinCubit>(),
          listener: (context, state) async {
            // 1- Listen Wepin Status if it is login
            // fetch the wallets created by Wepin

            "listening inside state.wepinLifeCycleStatus == WepinLifeCycle.login"
                .log();

            if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
                wepinSDK != null) {
              accountsList = await wepinSDK!.getAccounts();

              getIt<WepinCubit>().saveAccounts(accountsList);
              // Dismiss Loader with in WepinCubit
              // Now loader will be dismissed by
              getIt<WepinCubit>().dismissLoader();
            }
          },
        ),

        BlocListener<WepinCubit, WepinState>(
          listenWhen: (previous, current) =>
              previous.wepinLifeCycleStatus !=
                  WepinLifeCycle.loginBeforeRegister &&
              current.wepinLifeCycleStatus ==
                  WepinLifeCycle.loginBeforeRegister,
          bloc: getIt<WepinCubit>(),
          listener: (context, state) async {
            // 0- Listen Wepin Status if it is login before registered
            // automatically register
            if (state.wepinLifeCycleStatus ==
                WepinLifeCycle.loginBeforeRegister) {
              // Now loader will be shown by
              getIt<WepinCubit>().dismissLoader();
              await wepinSDK!.register(context);
              getStatus();
            }
          },
        ),

        // 3- Listen Wallets status if it is saved
        // If wallets are saved into backend
        // navigate to start up screen to refetch wallets and navigate to Home
        BlocListener<WalletsCubit, WalletsState>(
          listenWhen: (previous, current) =>
              previous.connectedWallets.length !=
                  current.connectedWallets.length &&
              previous.connectedWallets != current.connectedWallets,
          bloc: getIt<WalletsCubit>(),
          listener: (context, state) {
            // perform action to redeem free NFT only from Home ViewBefore
            // isShowWelcomeNFTCard is  true
            if (state.isSubmitSuccess && !state.isWelcomeNftRedeemInProcess) {
              getIt<WalletsCubit>().onUpdateIsWelcomeNftRedeemInProcess(true);
              // close Wallet Connect Model
              getIt<WalletsCubit>().onCloseWalletConnectModel();

              if (widget.isPerformRedeemWelcomeNft) {
                if (getIt<WalletsCubit>().state.isWepinWalletConnected &&
                    getIt<NftCubit>().state.welcomeNftEntity.remainingCount >
                        0) {
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
        ),
      ],
      child: BlocListener<WalletsCubit, WalletsState>(
        // Listen to the wallets cubit state
        bloc: getIt<WalletsCubit>(),
        listener: (context, state) {},
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
                          initializeWepinSdk();
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
                                  initializeWepinSdk();
                                },
                              );
                            },
                          )
                        : widget.isShowCustomButton
                            ? Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                                      initializeWepinSdk();
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
                                          .onConnectWallet(
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
                                        initializeWepinSdk();
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
    context.showErrorSnackBarDismissible(errorMessage);

    // getIt<AppCubit>().onLogOut();
    // // reset all cubits
    // getIt<AppCubit>().onRefresh();
    // // Navigate to start up screen
    // Navigator.pushNamedAndRemoveUntil(
    //     context, Routes.startUpScreen, (route) => false);
  }
}
