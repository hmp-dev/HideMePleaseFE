// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/notifications/notification_service.dart';
import 'package:mobile/features/map/presentation/map_screen.dart';
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart';
import 'package:mobile/features/map/presentation/widgets/check_in_bottom_bar.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
//import 'package:mobile/features/community/presentation/screens/community_screen.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/my_profile_screen.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_screen.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/app/core/services/nfc_service.dart';
import 'package:mobile/app/core/services/simple_nfc_test.dart';
import 'package:mobile/app/core/services/safe_nfc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/error/error.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final double _opacity = 1.0;

  // final PreloadPageController _pageController =
  //     PreloadPageController(initialPage: 2);

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  initializeServices() async {
    await getIt<EnableLocationCubit>().onAskDeviceLocation();
    await NotificationServices.instance.initialize();
    final fcmToken = await NotificationServices.instance.getDeviceToken();
    if (fcmToken != null) {
      ("fcmToken: $fcmToken").log();
      getIt<ProfileCubit>()
          .onUpdateUserProfile(UpdateProfileRequestDto(fcmToken: fcmToken));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C0C0E),
            Color(0xCC0C0C0E),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BlocConsumer<PageCubit, PageState>(
              bloc: getIt<PageCubit>(),
              listener: (context, state) {},
              builder: (context, state) {
                return BlocBuilder<EnableLocationCubit, EnableLocationState>(
                  bloc: getIt<EnableLocationCubit>(),
                  builder: (context, locState) {
                    if (locState.isSubmitLoading) return Container();

                    return Stack(
                      children: [
                        // 화면이 전체 영역을 차지하도록 배치
                        PreloadPageView.builder(
                          onPageChanged: (value) {},
                          itemBuilder: (context, index) {
                            print('🏗️ Building page for index: $index');
                            
                            if (index == MenuType.space.menuIndex) {
                              print('🗺️ Returning MapScreen for index $index');
                              return const MapScreen();
                            } else if (index == MenuType.events.menuIndex) {
                              print('🎪 Returning HomeScreen (Events) for index $index');
                              return const HomeScreen(); // EventsWepinScreen();
                            } else if (index == MenuType.home.menuIndex) {
                              print('🏠 Returning HomeScreen for index $index');
                              return const HomeScreen();
                            //} else if (index ==
                            //    MenuType.community.menuIndex) {
                            //  return const CommunityScreen();
                            } else if (index == MenuType.myProfile.menuIndex) {
                              print('👤 Returning MyProfileScreen for index $index');
                              return const MyProfileScreen();
                            }
                            print('❓ Returning default Container for index $index');
                            return Container();
                          },
                          itemCount: MenuType.values.length,
                          controller: state.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          preloadPagesCount: 5,
                        ),
                        // 탭바를 하단에 floating으로 배치
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: CheckInBottomBar(
                          isMapActive: state.menuType == MenuType.space,
                          isMyActive: state.menuType == MenuType.myProfile,
                          onMapTap: () {
                            ('🗺️ MAP button tapped').log();
                            // Navigate to Map Screen
                            _onChangeMenu(MenuType.space);
                            getIt<SpaceCubit>().onFetchAllSpaceViewData();
                          },
                          onMyTap: () {
                            ('👤 My button tapped').log();
                            // Navigate to MyProfile Screen
                            _onChangeMenu(MenuType.myProfile);
                          },
                          onCheckInTap: () async {
                            ('✅ Check-in button tapped - Starting NFC reading').log();
                            
                            // 안전한 NFC 서비스 사용
                            await SafeNfcService.startReading(
                              context: context,
                              onSuccess: (spaceId) async {
                                ('📍 NFC UUID read: $spaceId').log();
                                
                                // UUID 형식 검증
                                final uuidRegex = RegExp(
                                  r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
                                  caseSensitive: false,
                                );
                                
                                if (!uuidRegex.hasMatch(spaceId.trim())) {
                                  ('⚠️ Invalid UUID format: $spaceId').log();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(LocaleKeys.nfc_tag_unreadable.tr()),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }
                                
                                try {
                                  // 위치 권한 확인 및 현재 위치 가져오기
                                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                                  if (!serviceEnabled) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys.locationAlertMessage.tr()),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  LocationPermission permission = await Geolocator.checkPermission();
                                  if (permission == LocationPermission.denied) {
                                    permission = await Geolocator.requestPermission();
                                    if (permission == LocationPermission.denied) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(LocaleKeys.locationAlertMessage.tr()),
                                          backgroundColor: Colors.orange,
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                      return;
                                    }
                                  }
                                  
                                  // 현재 위치 가져오기
                                  final position = await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high,
                                  );
                                  
                                  ('📍 Current location: ${position.latitude}, ${position.longitude}').log();
                                  
                                  // Space 체크인 API 호출
                                  await getIt<SpaceCubit>().onCheckInWithNfc(
                                    spaceId: spaceId.trim(),
                                    latitude: position.latitude,
                                    longitude: position.longitude,
                                  );
                                  
                                  // 성공 메시지 표시
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(LocaleKeys.checkin_success.tr()),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } catch (e) {
                                  ('❌ Check-in error: $e').log();
                                  ('❌ Error type: ${e.runtimeType}').log();
                                  
                                  // 향상된 에러 메시지 파싱
                                  String errorMessage = LocaleKeys.benefitRedeemErrorMsg.tr();
                                  
                                  if (e is HMPError) {
                                    ('❌ HMPError details - message: ${e.message}, error: ${e.error}').log();
                                    
                                    // HMPError의 error 필드에서 체크
                                    if (e.error?.contains('SPACE_OUT_OF_RANGE') == true) {
                                      errorMessage = LocaleKeys.space_out_of_range.tr();
                                    } else if (e.error?.contains('ALREADY_CHECKED_IN') == true) {
                                      errorMessage = LocaleKeys.already_checked_in.tr();
                                    } else if (e.error?.contains('INVALID_SPACE') == true) {
                                      errorMessage = LocaleKeys.invalid_space.tr();
                                    }
                                    // message 필드에서도 체크
                                    else if (e.message.contains('SPACE_OUT_OF_RANGE')) {
                                      errorMessage = LocaleKeys.space_out_of_range.tr();
                                    } else if (e.message.contains('ALREADY_CHECKED_IN')) {
                                      errorMessage = LocaleKeys.already_checked_in.tr();
                                    } else if (e.message.contains('INVALID_SPACE')) {
                                      errorMessage = LocaleKeys.invalid_space.tr();
                                    }
                                  } 
                                  // HMPError가 아닌 경우 toString()으로 체크 (기존 로직 유지)
                                  else if (e.toString().contains('SPACE_OUT_OF_RANGE')) {
                                    errorMessage = LocaleKeys.space_out_of_range.tr();
                                  } else if (e.toString().contains('ALREADY_CHECKED_IN')) {
                                    errorMessage = LocaleKeys.already_checked_in.tr();
                                  } else if (e.toString().contains('INVALID_SPACE')) {
                                    errorMessage = LocaleKeys.invalid_space.tr();
                                  }
                                  
                                  ('📋 Final error message: $errorMessage').log();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                }
                              },
                              onError: (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onChangeMenu(MenuType menuType) {
    ('🔄 Changing to menu: $menuType (index: ${menuType.menuIndex})').log();
    //state.pageController.jumpToPage(menuType.menuIndex);
    getIt<PageCubit>().changePage(menuType.menuIndex, menuType);
    ('✅ Page change completed').log();
  }
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