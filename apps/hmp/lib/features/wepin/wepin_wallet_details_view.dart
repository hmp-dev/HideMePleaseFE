// class WepinWalletConnectLisTile extends StatefulWidget {

// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/values/sdk_app_info.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class WepinWalletDetailsView extends StatefulWidget {
  /// Creates a [WepinWalletDetailsView].
  ///
  /// The [onConnectWallet] callback is called when the user taps the
  /// connect wallet button.
  const WepinWalletDetailsView({
    super.key,
  });

  @override
  State<WepinWalletDetailsView> createState() => _WepinWalletDetailsViewState();
}

class _WepinWalletDetailsViewState extends State<WepinWalletDetailsView> {
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
  String? privateKey;
  List<LoginProvider> loginProviders = sdkConfigs[0]['loginProviders'];
  List<LoginProvider> selectedSocialLogins = sdkConfigs[0]['loginProviders'];

  @override
  void initState() {
    super.initState();
    checkWepinStatusAndOpenWidget();
  }

  checkWepinStatusAndOpenWidget() async {
    // if Wepin is already initialized
    if (wepinSDK != null) {
      "++++++++++++++++inside wepinSDK != null".log();
      wepinStatus = await wepinSDK!.getStatus();

      await wepinSDK!.openWidget(context);
    } else {
      initValues();
    }
  }

  initValues() async {
    googleAccessToken =
        await getIt<AuthCubit>().refreshGoogleAccessToken() ?? '';
    socialTokenIsAppleOrGoogle =
        await getIt<AuthLocalDataSource>().getSocialTokenIsAppleOrGoogle() ??
            '';
    appleIdToken = await getIt<AuthCubit>().refreshAppleIdToken() ?? '';

    setState(() {});

    if (getIt<WalletsCubit>().state.isEventViewActive) {
      "inside isEventViewActive ${getIt<WalletsCubit>().state.isEventViewActive}"
          .log();

      Future.delayed(const Duration(milliseconds: 200), () {
        initializeWepinSdk();
      });
    }
  }

  void initializeWepinSdk() {
    final selectedConfig =
        sdkConfigs.firstWhere((config) => config['name'] == selectedValue);

    initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
        selectedConfig['privateKey']!);
  }

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

  @override
  void dispose() {
    super.dispose();
    wepinSDK!.finalize();
    // Set the event view Active Status to false
    getIt<WalletsCubit>().onIsEventViewActive(false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WepinCubit, WepinState>(
      bloc: getIt<WepinCubit>(),
      listener: (context, state) async {
        // 0 - Listen Wepin Status if it is not initialized
        if (state.wepinLifeCycleStatus == WepinLifeCycle.notInitialized) {
          final selectedConfig = sdkConfigs
              .firstWhere((config) => config['name'] == selectedValue);
          initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
              selectedConfig['privateKey']!);
        }

        // 1- Listen Wepin Status if it is login
        // fetch the wallets created by Wepin

        if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
          // Now loader will be Dismissed
          getIt<WepinCubit>().dismissLoader();
          await wepinSDK!.openWidget(context);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  Text(
                    LocaleKeys.access_wepin_wallet.tr(),
                    textAlign: TextAlign.center,
                    style: fontTitle03Bold(),
                  ),
                  const VerticalSpace(70),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 48, // 70% of original width
                            height: 48, // 70% of original height
                            child: CustomImageView(
                              imagePath: "assets/images/launcher-icon.png",
                              radius: BorderRadius.circular(4),
                              width: 48, // Reduced width
                              height: 48,
                              fit: BoxFit.contain, // Reduced height
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Icon(
                              Icons.more_horiz,
                              size: 30,
                              color: fore2,
                            ),
                          ),
                          SizedBox(
                            width: 48, // 70% of original width
                            height: 48, // 70% of original height
                            child: CustomImageView(
                              imagePath: "assets/images/wepin_logo_dark.png",
                              width: 48, // Reduced width
                              height: 48,
                              fit: BoxFit.contain, // Reduced height
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalSpace(70),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              "Powered by",
                              style: fontBodyXsBold(color: fore2),
                            ),
                          ),
                          CustomImageView(
                            svgPath: "assets/images/wepin_white_logo.svg",
                            color: fore2,
                            // Reduced height
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: HMPCustomButton(
                      text: "위핀 지갑 연결",
                      onPressed: () async {
                        if (wepinSDK != null) {
                          await wepinSDK!.openWidget(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
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
