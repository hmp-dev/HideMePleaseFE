// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';
// import 'package:mobile/app/core/enum/social_login_type.dart';
// import 'package:mobile/app/core/extensions/log_extension.dart';
// import 'package:mobile/app/core/injection/injection.dart';
// import 'package:mobile/app/core/router/values.dart';
// import 'package:mobile/app/theme/theme.dart';
// import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
// import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
// import 'package:mobile/features/common/presentation/widgets/default_image.dart';
// import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
// import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
// import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
// import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
// import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
// import 'package:mobile/generated/locale_keys.g.dart';
// import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
// import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

// import 'values/sdk_app_info.dart';
// import 'widgets/custom_dialog.dart';

// const String wepin_description_en = '''
// Welcome! Enjoy a delicious lifestyle with NFTs at HideMePlease! 🍽️

// Connecting your wallet is simple—just enter your password, and it will be set up automatically. With our quick wallet registration feature, new users can complete their wallet setup in just a few steps.

// 	1.	Enter your password.
// 	2.	Your wallet will be automatically connected, and you’re ready to start using NFTs!

// No more complicated settings. Start a new experience with HideMePlease today!
// ''';

// const String wepin_description_ko = '''
// 환영합니다! 하이드미플리즈에서 NFT와 함께하는 
// 맛있는 라이프 스타일을 즐겨보세요! 🍽️

// 지갑 연결은 간편하게, 비밀번호만 입력하면 자동으로 
// 설정됩니다. 새로운 유저분들을 위해 준비한 빠른 지갑 
// 등록 기능을 통해 몇 단계만으로 지갑을 완성할 수 있어요.

// 	1.	비밀번호를 입력하세요.
// 	2.	자동으로 지갑이 연결되며, NFT 활용 준비 완료!

// 더 이상 복잡한 설정은 없습니다. 하이드미플리즈와 함께 새로운 경험을 시작해 보세요!
// ''';

// class WepinSetUpPinScreen extends StatefulWidget {
//   const WepinSetUpPinScreen({
//     super.key,
//     required this.googleAccessToken,
//     required this.selectedLanguage,
//     required this.socialTokenIsAppleOrGoogle,
//     required this.appleIdToken,
//   });

//   final String googleAccessToken;
//   final String socialTokenIsAppleOrGoogle;
//   final String appleIdToken;
//   final String selectedLanguage;

//   @override
//   WepinSetUpPinScreenState createState() => WepinSetUpPinScreenState();
// }

// class WepinSetUpPinScreenState extends State<WepinSetUpPinScreen> {
//   final Map<String, String> currency = {
//     'ko': 'KRW',
//     'en': 'USD',
//     'ja': 'JPY',
//   };

//   WepinWidgetSDK? wepinSDK;
//   String? selectedLanguage = 'ko';
//   String? selectedValue = sdkConfigs[0]['name'];

//   WepinLifeCycle wepinStatus = WepinLifeCycle.notInitialized;
//   String userEmail = '';
//   List<WepinAccount> selectedAccounts = [];
//   List<WepinAccount> accountsList = [];
//   List<WepinAccountBalanceInfo> balanceList = [];
//   List<WepinNFT> nftList = [];
//   bool isLoading = false;
//   String? privateKey;
//   List<LoginProvider> loginProviders = sdkConfigs[0]['loginProviders'];
//   List<LoginProvider> selectedSocialLogins = sdkConfigs[0]['loginProviders'];

//   @override
//   void initState() {
//     super.initState();
//     setUpLanguage();
//     setLoginInfo();
//   }

//   setUpLanguage() {
//     setState(() {
//       selectedLanguage = widget.selectedLanguage;
//     });
//   }

//   void setLoginInfo() {
//     final selectedConfig =
//         sdkConfigs.firstWhere((config) => config['name'] == selectedValue);
//     _updateConfig(selectedConfig);
//     initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
//         selectedConfig['privateKey']!);
//   }

//   void _updateConfig(Map<String, dynamic> config) {
//     setState(() {
//       privateKey = config['privateKey'];
//       loginProviders = config['loginProviders'];
//       selectedSocialLogins = config['loginProviders'];
//     });
//   }

//   Future<void> initWepinSDK(
//       String appId, String appKey, String privateKey) async {
//     wepinSDK?.finalize();
//     wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);
//     await wepinSDK!.init(
//         attributes: WidgetAttributes(
//             defaultLanguage: selectedLanguage!,
//             defaultCurrency: currency[selectedLanguage!]!));

//     wepinStatus = await wepinSDK!.getStatus();
//     // Save to Cubit
//     getIt<WepinCubit>().updateWepinStatus(wepinStatus);
//     //
//     userEmail = wepinStatus == WepinLifeCycle.login
//         ? (await wepinSDK!.login.getCurrentWepinUser())?.userInfo?.email ?? ''
//         : '';

//     if (wepinStatus == WepinLifeCycle.notInitialized) {
//       showError('WepinSDK is not initialized.');
//     }

//     getStatus();
//     setState(() {});

//     // call Login with AccessToken

//     if (wepinSDK != null) {
//       loginSocialAuthProvider();
//     }
//   }

//   void showError(String message) {
//     "Error occurred: $message".log();
//     //
//     if (!message.contains('User Cancel')) {
//       context.showErrorSnackBar(LocaleKeys.somethingError.tr());
//     }

//     // showDialog(
//     //   context: context,
//     //   builder: (ctx) => CustomDialog(message: message, isError: true),
//     // );
//   }

//   void showSuccess(String title, String message) {
//     context.showSnackBar(message);
//     // showDialog(
//     //   context: context,
//     //   builder: (ctx) => CustomDialog(title: title, message: message),
//     // );
//   }

//   Future<void> performActionWithLoading(Function action) async {
//     setState(() => isLoading = true);
//     try {
//       await action();
//     } catch (e) {
//       showError(e.toString());
//       //"Error occurred: $e".log();
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> loginSocialAuthProvider() async {
//     await performActionWithLoading(() async {
//       try {
//         LoginResult? fbToken;

//         // if Login Type is Google
//         if (widget.socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
//           fbToken = await wepinSDK!.login.loginWithAccessToken(
//               provider: 'google', accessToken: widget.googleAccessToken);
//         }

//         // if Login Type is Apple
//         if (widget.socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
//           fbToken = await wepinSDK!.login
//               .loginWithIdToken(idToken: widget.googleAccessToken);
//         }

//         if (fbToken != null) {
//           final wepinUser = await wepinSDK?.login.loginWepin(fbToken);

//           if (wepinUser != null && wepinUser.userInfo != null) {
//             userEmail = wepinUser.userInfo!.email; // Update user's email
//             wepinStatus = await wepinSDK!.getStatus(); // Get wepin status
//             getIt<WepinCubit>().updateWepinStatus(wepinStatus);
//           } else {
//             ('Login Failed. No user info found.').log();
//             getIt<AppCubit>().onLogOut();
//           }
//         } else {
//           ('Login Failed. Invalid token.').log();
//           getIt<AppCubit>().onLogOut();
//         }
//       } catch (e) {
//         if (!e.toString().contains('UserCancelled')) {
//           ('Login Failed. (error code - $e)').log();

//           //
//           getIt<AppCubit>().onLogOut();
//         }
//       }
//     });
//   }

//   void getStatus() async {
//     await performActionWithLoading(() async {
//       if (wepinSDK != null) {
//         wepinStatus = await wepinSDK!.getStatus();
//         getIt<WepinCubit>().updateWepinStatus(wepinStatus);
//       }
//     });
//   }

//   Widget _buildActionButton(String label, VoidCallback onPressed) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       padding: const EdgeInsets.symmetric(horizontal: 0.0),
//       child: HMPCustomButton(
//         text: label,
//         onPressed: onPressed,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<WepinCubit, WepinState>(
//           bloc: getIt<WepinCubit>(),
//           listener: (context, state) async {
//             // 0 - Listen Wepin Status if it is not initialized
//             if (state.wepinLifeCycleStatus == WepinLifeCycle.notInitialized) {
//               final selectedConfig = sdkConfigs
//                   .firstWhere((config) => config['name'] == selectedValue);
//               initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!,
//                   selectedConfig['privateKey']!);
//             }

//             // 0- Listen Wepin Status if it is login before registered
//             // automatically register
//             if (state.wepinLifeCycleStatus ==
//                 WepinLifeCycle.loginBeforeRegister) {
//               await wepinSDK!.register(context);
//               getStatus();
//             }

//             // 1- Listen Wepin Status if it is login
//             // fetch the wallets created by Wepin

//             if (state.wepinLifeCycleStatus == WepinLifeCycle.login) {
//               accountsList = await wepinSDK!.getAccounts();
//               getIt<WepinCubit>().saveAccounts(accountsList);
//             }

//             // 2- Listen Wepin Status if it is login and wallets are in the state
//             // save these wallets for the user

//             if (state.wepinLifeCycleStatus == WepinLifeCycle.login &&
//                 state.accounts.isNotEmpty) {
//               // if status is login save wallets to backend

//               for (var account in accountsList) {
//                 logAccountDetails(account);

//                 if (account.network.toLowerCase() == "ethereum") {
//                   getIt<WalletsCubit>().onPostWallet(
//                     saveWalletRequestDto: SaveWalletRequestDto(
//                       publicAddress: account.address,
//                       provider: "WEPIN_EVM",
//                     ),
//                   );
//                 }
//               }
//             }
//           },
//         ),

//         // 3- Listen Wallets status if it is saved
//         // If wallets are saved into backend
//         // navigate to start up screen to refetch wallets and navigate to Home
//         BlocListener<WalletsCubit, WalletsState>(
//           listenWhen: (previous, current) =>
//               current.connectedWallets.length == 2,
//           bloc: getIt<WalletsCubit>(),
//           listener: (context, state) {
//             if (state.isSubmitSuccess) {
//               // reset all cubits
//               getIt<AppCubit>().onRefresh();
//               // Navigate to start up screen
//               Navigator.pushNamedAndRemoveUntil(
//                   context, Routes.startUpScreen, (route) => false);
//             }
//           },
//         ),
//       ],
//       child: SizedBox(
//         width: double.infinity,
//         height: MediaQuery.of(context).size.height * 0.70,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 10.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 20.0),
//                     child: Text(
//                       LocaleKeys.register_a_quick_wallet.tr(),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: fontTitle05Medium(),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: DefaultImage(
//                       path: 'assets/icons/ic_close.svg',
//                       width: 32,
//                       height: 32,
//                       color: white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       top: 30.0, left: 20, right: 20, bottom: 20),
//                   child: Column(
//                     children: [
//                       if (wepinSDK != null) ...[
//                         if (wepinStatus != WepinLifeCycle.loginBeforeRegister)
//                           Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 const SizedBox(height: 50.0),
//                                 Lottie.asset(
//                                   'assets/lottie/loader.json',
//                                 ),
//                               ],
//                             ),
//                           )
//                         // Card(
//                         //   elevation: 4.0,
//                         //   shape: RoundedRectangleBorder(
//                         //     borderRadius: BorderRadius.circular(12.0),
//                         //   ),
//                         //   child: ListTile(
//                         //     title: const Text('Account Status',
//                         //         style: TextStyle(fontSize: 16)),
//                         //     subtitle: Text(
//                         //       getIt<WepinCubit>().state.wepinLifeCycleStatus.name,
//                         //     ),
//                         //     trailing: IconButton(
//                         //       icon: const Icon(Icons.refresh,
//                         //           color: Colors.blueAccent),
//                         //       onPressed: getStatus,
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                       if (wepinStatus ==
//                           WepinLifeCycle.loginBeforeRegister) ...[
//                         const SizedBox(height: 12),
//                         _buildActionButton(
//                             LocaleKeys.register_wepin_password.tr(), () async {
//                           await performActionWithLoading(() async {
//                             await wepinSDK!.register(context);
//                             getStatus();
//                           });
//                         }),
//                         _buildActionButton(LocaleKeys.cancel.tr(), () async {
//                           await performActionWithLoading(() async {
//                             await wepinSDK!.login.logoutWepin();
//                             userEmail = '';
//                             getStatus();

//                             getIt<AppCubit>().onLogOut();
//                           });
//                         }),
//                       ],
//                     ],
//                   ),
//                 ),
//                 if (isLoading)
//                   ModalBarrier(
//                       color: Colors.black.withOpacity(0.5), dismissible: false),
//                 if (isLoading)
//                   Center(
//                     child: Lottie.asset(
//                       'assets/lottie/loader.json',
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildBackArrowIconButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 18.0),
//       child: Center(
//         child: GestureDetector(
//           onTap: () {
//             getIt<AppCubit>().onLogOut();
//           },
//           child: const Icon(
//             Icons.logout,
//             color: white,
//           ),
//         ),
//       ),
//     );
//   }

//   void logAccountDetails(WepinAccount account) {
//     "the Wallet account Address is ${account.address}".log();
//     "the Wallet account Network is ${account.network}".log();
//     "the Wallet account Contract is ${account.contract}".log();
//   }
// }
