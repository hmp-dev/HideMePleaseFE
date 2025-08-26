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
                              onSuccess: (tagId) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('체크인 성공!\nTag ID: $tagId'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
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
                            return;
                            
                            // NFC 리딩 시작
                            NfcService().startNfcReading(
                              onTagRead: (tagId) {
                                ('🎉 NFC Tag read successfully: $tagId').log();
                                // TODO: 체크인 처리 로직 구현
                                // 예: 서버에 tagId와 함께 체크인 요청 보내기
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('체크인 성공! Tag ID: $tagId'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              onError: (error) {
                                ('❌ NFC reading error: $error').log();
                                
                                // 에러 메시지 파싱 및 사용자 친화적 메시지 표시
                                String userMessage = 'NFC 읽기 실패';
                                
                                if (error.contains('NFC를 사용할 수 없습니다')) {
                                  userMessage = 'NFC가 비활성화되어 있습니다.\n설정 > 일반 > NFC를 켜주세요.';
                                } else if (error.contains('권한')) {
                                  userMessage = 'NFC 권한이 필요합니다.\n앱을 삭제 후 다시 설치해주세요.';
                                } else if (error.contains('지원하지 않습니다')) {
                                  userMessage = '이 기기는 NFC를 지원하지 않습니다.';
                                } else if (error.contains('사용 중')) {
                                  userMessage = 'NFC가 다른 앱에서 사용 중입니다.\n잠시 후 다시 시도해주세요.';
                                } else if (error.contains('취소')) {
                                  userMessage = 'NFC 읽기가 취소되었습니다.';
                                } else if (error.contains('시간 초과')) {
                                  userMessage = 'NFC 읽기 시간이 초과되었습니다.\n다시 시도해주세요.';
                                } else if (error.contains('알 수 없는 오류')) {
                                  userMessage = 'NFC 태그를 읽을 수 없습니다.\n태그를 천천히 대주세요.';
                                } else {
                                  // 기타 에러의 경우 원본 메시지 일부 표시
                                  userMessage = 'NFC 오류: ${error.length > 50 ? error.substring(0, 50) + "..." : error}';
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(userMessage),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              },
                              context: context,
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