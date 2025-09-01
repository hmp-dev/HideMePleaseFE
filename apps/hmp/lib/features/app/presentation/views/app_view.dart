// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/services/live_activity_service.dart';
import 'package:mobile/app/core/notifications/notification_service.dart';
import 'package:mobile/features/map/presentation/map_screen.dart';
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart';
import 'package:mobile/features/map/presentation/widgets/check_in_bottom_bar.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
//import 'package:mobile/features/community/presentation/screens/community_screen.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/home/presentation/screens/new_home_screen.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/my_profile_screen.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_screen.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_employ_dialog.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/app/core/services/nfc_service.dart';
import 'package:mobile/app/core/services/simple_nfc_test.dart';
import 'package:mobile/app/core/services/safe_nfc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_fail_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_success_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/error/error.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final double _opacity = 1.0;

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
                        PreloadPageView.builder(
                          onPageChanged: (value) {},
                          itemBuilder: (context, index) {
                            print('🏗️ Building page for index: $index');
                            
                            if (index == MenuType.home.menuIndex) {
                              print('🏠 Returning NewHomeScreen for index $index');
                              return const NewHomeScreen();
                            } else if (index == MenuType.space.menuIndex) {
                              print('🗺️ Returning MapScreen for index $index');
                              return MapScreen(
                                onShowBottomBar: () => getIt<PageCubit>().showBottomBar(),
                                onHideBottomBar: () => getIt<PageCubit>().hideBottomBar(),
                              );
                            } else if (index == MenuType.events.menuIndex) {
                              print('🎪 Returning HomeScreen (Events) for index $index');
                              return const HomeScreen(); // EventsWepinScreen();

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
                        if (state.showBottomBar)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: CheckInBottomBar(
                          isHomeActive: state.menuType == MenuType.home,
                          isMapActive: state.menuType == MenuType.space,
                          onHomeTap: () {
                            ('🏠 Home button tapped').log();
                            // Navigate to Home Screen
                            _onChangeMenu(MenuType.home);
                          },
                          onMapTap: () {
                            ('🗺️ MAP button tapped').log();
                            _onChangeMenu(MenuType.space);
                            getIt<SpaceCubit>().onFetchAllSpaceViewData();
                          },

                          onCheckInTap: () async {
                            ('✅ Check-in button tapped - Starting NFC reading').log();
                            
                            // DEBUG: Live Activity 즉시 시작 (NFC 없이)
                            // print('🎯 [DEBUG] Starting Live Activity immediately for testing');
                            // final liveActivityService = getIt<LiveActivityService>();
                            // await liveActivityService.startCheckInActivity(
                            //   spaceName: '영동호프',  // 테스트 공간 이름
                            //   currentUsers: 2,      // 현재 2명 체크인 (2개 점 파란색)
                            //   remainingUsers: 1,    // 매칭까지 1명 남음
                            // );
                            
                            // // 디버그: 120초 후 자동 종료
                            // Future.delayed(const Duration(seconds: 120), () {
                            //   print('🎯 [DEBUG] Auto-ending Live Activity after 30 seconds');
                            //   liveActivityService.endCheckInActivity();
                            // });
                            
                            // 안전한 NFC 서비스 사용
                            await SafeNfcService.startReading(
                              context: context,
                              onSuccess: (spaceId) async {
                                ('📍 NFC UUID read: $spaceId').log();
                                
                                // 빈 값 체크
                                if (spaceId.trim().isEmpty) {
                                  ('⚠️ Empty NFC tag value detected').log();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const CheckinFailDialog(),
                                  );
                                  return;
                                }
                                
                                // UUID 형식 검증
                                final uuidRegex = RegExp(
                                  r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
                                  caseSensitive: false,
                                );
                                
                                if (!uuidRegex.hasMatch(spaceId.trim())) {
                                  ('⚠️ Invalid UUID format: $spaceId').log();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const CheckinFailDialog(),
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
                                  
                                  // Space 상세 정보 가져오기
                                  await getIt<SpaceCubit>().onGetSpaceDetailBySpaceId(
                                    spaceId: spaceId.trim(),
                                  );
                                  
                                  // Space 정보 가져오기
                                  final spaceState = getIt<SpaceCubit>().state;
                                  final spaceDetail = spaceState.spaceDetailEntity;
                                  
                                  // spaceList에서 추가 정보 가져오기
                                  final spaceEntity = spaceState.spaceList.firstWhere(
                                    (s) => s.id == spaceId.trim(),
                                    orElse: () => const SpaceEntity.empty(),
                                  );
                                  
                                  if (spaceDetail.id.isNotEmpty) {
                                    // Live Activity 시작 (실제 공간 정보 사용)
                                    final liveActivityService = getIt<LiveActivityService>();
                                    await liveActivityService.startCheckInActivity(
                                      spaceName: spaceDetail.name,
                                      currentUsers: 2,  // TODO: 실제 체크인 수 API에서 받기
                                      remainingUsers: 3,  // TODO: 실제 남은 인원 API에서 받기
                                      spaceId: spaceId.trim(),  // 폴링을 위한 spaceId 전달
                                    );
                                    
                                    // 성공 다이얼로그 표시
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => CheckinSuccessDialog(
                                        spaceName: spaceDetail.name,
                                        benefit: spaceEntity.benefitDescription.isNotEmpty 
                                            ? spaceEntity.benefitDescription 
                                            : spaceDetail.introduction,
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                          // Live Activity 종료
                                          liveActivityService.endCheckInActivity();
                                        },
                                        onConfirm: () {
                                          Navigator.of(context).pop();
                                          // TODO: 직원 확인 로직 추가
                                        },
                                      ),
                                    );
                                  } else {
                                    // Space 정보가 없으면 기본 성공 메시지
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys.checkin_success.tr()),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
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
                                  
                                  // 에러 다이얼로그 표시
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const CheckinFailDialog(),
                                  );
                                }
                              },
                              onError: (error) {
                                ('❌ NFC error: $error').log();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const CheckinFailDialog(),
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
    getIt<PageCubit>().changePage(menuType.menuIndex, menuType);
    ('✅ Page change completed').log();
  }

  void _showNfcScanDialog(BuildContext context, {required Function onCancel}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => onCancel(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready to Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.nfc_tag_nearby.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF007AFF),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.smartphone,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => onCancel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCheckIn() async {
    final spaceCubit = getIt<SpaceCubit>();
    final selectedSpace = spaceCubit.state.selectedSpace;

    if (selectedSpace == null) {
      ('⚠️ Check-in attempt without a selected space.').log();
      showDialog(
        context: context,
        builder: (context) => const CheckinFailDialog(),
      );
      return;
    }

    ('✅ Check-in button tapped for ${selectedSpace.name} - Simulating NFC scan...').log();
    Timer? debugTimer;

    final dialogCompleter = Completer<void>();

    _showNfcScanDialog(context, onCancel: () {
      ('🟧 NFC Scan Canceled by user.').log();
      debugTimer?.cancel();
      if (!dialogCompleter.isCompleted) {
        Navigator.of(context).pop();
        dialogCompleter.complete();
      }
    });

    debugTimer = Timer(const Duration(seconds: 5), () {
      ('✅ NFC simulation successful after 5 seconds.').log();

      if (!dialogCompleter.isCompleted && mounted) {
        Navigator.of(context).pop();
        dialogCompleter.complete();

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            final spaceToUse = selectedSpace;
            final benefitDescription = spaceToUse.benefitDescription.isNotEmpty
                ? spaceToUse.benefitDescription
                : '등록된 혜택이 없습니다.';

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CheckinEmployDialog(
                  benefitDescription: benefitDescription,
                  spaceName: spaceToUse.name,
                  onConfirm: () async {
                    try {
                      final position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      ('📍 Current location for check-in: ${position.latitude}, ${position.longitude}')
                          .log();

                      print('📡 Calling check-in API with parameters:');
                      print('   spaceId: ${spaceToUse.id}');
                      print('   latitude: ${position.latitude}');
                      print('   longitude: ${position.longitude}');

                      await spaceCubit.onCheckInWithNfc(
                        spaceId: spaceToUse.id,
                        latitude: position.latitude,
                        longitude: position.longitude,
                      );

                      if (mounted) {
                        Navigator.of(context).pop();
                        await showDialog(
                          context: context,
                          builder: (context) => CheckinSuccessDialog(
                            spaceName: spaceToUse.name,
                            benefitDescription: benefitDescription,
                          ),
                        );
                        spaceCubit.onFetchAllSpaceViewData();
                      }
                    } catch (e) {
                      ('❌ Check-in error: $e').log();
                      ('❌ Error type: ${e.runtimeType}').log();
                                  
                      String errorMessage = LocaleKeys.benefitRedeemErrorMsg.tr();
                      
                      if (e is HMPError) {
                        ('❌ HMPError details - message: ${e.message}, error: ${e.error}').log();
                        
                        if (e.error?.contains('SPACE_OUT_OF_RANGE') == true) {
                          errorMessage = LocaleKeys.space_out_of_range.tr();
                        } else if (e.error?.contains('ALREADY_CHECKED_IN') == true) {
                          errorMessage = LocaleKeys.already_checked_in.tr();
                        } else if (e.error?.contains('INVALID_SPACE') == true) {
                          errorMessage = LocaleKeys.invalid_space.tr();
                        }
                        else if (e.message.contains('SPACE_OUT_OF_RANGE')) {
                          errorMessage = LocaleKeys.space_out_of_range.tr();
                        } else if (e.message.contains('ALREADY_CHECKED_IN')) {
                          errorMessage = LocaleKeys.already_checked_in.tr();
                        } else if (e.message.contains('INVALID_SPACE')) {
                          errorMessage = LocaleKeys.invalid_space.tr();
                        }
                      } 
                      else if (e.toString().contains('SPACE_OUT_OF_RANGE')) {
                        errorMessage = LocaleKeys.space_out_of_range.tr();
                      } else if (e.toString().contains('ALREADY_CHECKED_IN')) {
                        errorMessage = LocaleKeys.already_checked_in.tr();
                      } else if (e.toString().contains('INVALID_SPACE')) {
                        errorMessage = LocaleKeys.invalid_space.tr();
                      }
                      
                      ('📋 Final error message: $errorMessage').log();
                      
                      if (mounted) {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => const CheckinFailDialog(),
                        );
                      }
                    }
                  },
                );
              },
            );
          }
        });
      }
    });
  }
}