import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/widgets/account_selection.dart';
import 'package:mobile/features/wepin/widgets/balance_list.dart';
import 'package:mobile/features/wepin/widgets/nft_list.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

import 'values/sdk_app_info.dart';
import 'widgets/custom_dialog.dart';

class WepinSetUpPinScreen extends StatefulWidget {
  const WepinSetUpPinScreen({
    super.key,
    required this.googleAuthAccessToken,
  });

  final String googleAuthAccessToken;

  @override
  WepinSetUpPinScreenState createState() => WepinSetUpPinScreenState();
}

class WepinSetUpPinScreenState extends State<WepinSetUpPinScreen> {
  final Map<String, String> currency = {
    'ko': 'KRW',
    'en': 'USD',
    'ja': 'JPY',
  };

  WepinWidgetSDK? wepinSDK;
  String? selectedLanguage = 'ko';
  String? selectedValue = sdkConfigs[0]['name'];

  WepinLifeCycle wepinStatus = WepinLifeCycle.notInitialized;
  String userEmail = '';
  List<WepinAccount> selectedAccounts = [];
  List<WepinAccount> accountsList = [];
  List<WepinAccountBalanceInfo> balanceList = [];
  List<WepinNFT> nftList = [];
  bool isLoading = false;
  String? privateKey;
  List<LoginProvider> loginProviders = sdkConfigs[0]['loginProviders'];
  List<LoginProvider> selectedSocialLogins = sdkConfigs[0]['loginProviders'];

  @override
  void initState() {
    super.initState();
    setLoginInfo();
  }

  void setLoginInfo() {
    final selectedConfig =
        sdkConfigs.firstWhere((config) => config['name'] == selectedValue);
    _updateConfig(selectedConfig);
    initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
        selectedConfig['privateKey']!);
  }

  void _updateConfig(Map<String, dynamic> config) {
    setState(() {
      privateKey = config['privateKey'];
      loginProviders = config['loginProviders'];
      selectedSocialLogins = config['loginProviders'];
    });
  }

  Future<void> initWepinSDK(
      String appId, String appKey, String privateKey) async {
    wepinSDK?.finalize();
    wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);
    await wepinSDK!.init(
        attributes: WidgetAttributes(
            defaultLanguage: selectedLanguage!,
            defaultCurrency: currency[selectedLanguage!]!));
    wepinStatus = await wepinSDK!.getStatus();
    userEmail = wepinStatus == WepinLifeCycle.login
        ? (await wepinSDK!.login.getCurrentWepinUser())?.userInfo?.email ?? ''
        : '';

    if (wepinStatus == WepinLifeCycle.notInitialized) {
      showError('WepinSDK is not initialized.');
    }
    setState(() {});

    // call Login with AccessToken

    if (wepinSDK != null) {
      loginWithGoogleProvider();
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(message: message, isError: true),
    );
  }

  void showSuccess(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(title: title, message: message),
    );
  }

  Future<void> performActionWithLoading(Function action) async {
    setState(() => isLoading = true);
    try {
      await action();
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> navigateToAccountSelection(
      {bool? selection, bool? allowMultiSelection, bool? withoutToken}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountSelectionScreen(
          getAccounts: accountsList,
          selection: selection,
          allowMultiSelection: allowMultiSelection ?? false,
          withoutToken: withoutToken,
        ),
      ),
    );

    if (result != null) {
      setState(() => selectedAccounts = result);
    }
  }

  Future<void> navigateToBalanceList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BalanceListScreen(balanceList: balanceList)),
    );
  }

  Future<void> navigateToNftList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WepinNFTListScreen(wepinNFTs: nftList)),
    );
  }

  Future<void> loginWithGoogleProvider() async {
    await performActionWithLoading(() async {
      try {
        LoginResult? fbToken;

        // if Platform is Google
        if (Platform.isAndroid) {
          fbToken = await wepinSDK!.login.loginWithAccessToken(
              provider: 'google', accessToken: widget.googleAuthAccessToken);
        }

        if (Platform.isIOS) {
          fbToken = await wepinSDK!.login
              .loginWithIdToken(idToken: widget.googleAuthAccessToken);
        }

        if (fbToken != null) {
          final wepinUser = await wepinSDK?.login.loginWepin(fbToken);

          if (wepinUser != null && wepinUser.userInfo != null) {
            userEmail = wepinUser.userInfo!.email; // Update user's email
            wepinStatus = await wepinSDK!.getStatus(); // Get wepin status
          } else {
            ('Login Failed. No user info found.').log();
            getIt<AppCubit>().onLogOut();
          }
        } else {
          ('Login Failed. Invalid token.').log();
          getIt<AppCubit>().onLogOut();
        }
      } catch (e) {
        if (!e.toString().contains('UserCancelled')) {
          ('Login Failed. (error code - $e)').log();

          //
          getIt<AppCubit>().onLogOut();
        }
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

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text('Setup Wallet'),
        actions: [
          buildBackArrowIconButton(context),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // 1- Listen Wepin Status if it is login
          // fetch the wallets created by Wepin
          BlocListener<WepinCubit, WepinState>(
            bloc: getIt<WepinCubit>(),
            listener: (context, state) async {
              if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
                accountsList = await wepinSDK!.getAccounts();

                getIt<WepinCubit>().saveAccounts(accountsList);
              }
            },
          ),

          // 2- Listen Wepin Status if it is login and wallets are in the state
          // save these wallets for the user

          BlocListener<WepinCubit, WepinState>(
            bloc: getIt<WepinCubit>(),
            listener: (context, state) async {
              if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
                  state.accounts.isNotEmpty) {
                // if status is login save wallets to backend

                for (var account in accountsList) {
                  "the Wallet account Address is ${account.address}".log();
                  "the Wallet account Network is ${account.network}".log();
                  "the Wallet account Contract is ${account.contract}".log();

                  if (account.network.toLowerCase() == "ethereum") {
                    getIt<WalletsCubit>().onPostWallet(
                      saveWalletRequestDto: SaveWalletRequestDto(
                        publicAddress: account.address,
                        provider: "WEPIN_EVM",
                      ),
                    );
                  }

                  if (account.network.toLowerCase() == "solana") {
                    getIt<WalletsCubit>().onPostWallet(
                      saveWalletRequestDto: SaveWalletRequestDto(
                        publicAddress: account.address,
                        provider: "WEPIN_SOLANA",
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
                previous.connectedWallets.length <
                current.connectedWallets.length,
            bloc: getIt<WalletsCubit>(),
            listener: (context, state) {
              if (state.isSubmitSuccess) {
                // Navigate to start up screen
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.startUpScreen, (route) => false);
              }
            },
          ),
        ],
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (wepinSDK != null) ...[
                    const SizedBox(height: 16.0),
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: const Text('Account Status',
                            style: TextStyle(fontSize: 16)),
                        subtitle: Text(wepinStatus.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Colors.blueAccent),
                          onPressed: getStatus,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView(
                      children: [
                        if (wepinStatus ==
                            WepinLifeCycle.loginBeforeRegister) ...[
                          _buildActionButton('Setup Wallet Pin', () async {
                            await performActionWithLoading(() async {
                              await wepinSDK!.register(context);
                              getStatus();
                            });
                          }),
                          _buildActionButton('Cancel', () async {
                            await performActionWithLoading(() async {
                              await wepinSDK!.login.logoutWepin();
                              userEmail = '';
                              getStatus();

                              getIt<AppCubit>().onLogOut();
                            });
                          }),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              ModalBarrier(
                  color: Colors.black.withOpacity(0.5), dismissible: false),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget buildBackArrowIconButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: Center(
        child: GestureDetector(
          onTap: () {
            getIt<AppCubit>().onLogOut();
          },
          child: const Icon(
            Icons.logout,
            color: white,
          ),
        ),
      ),
    );
  }
}
