// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:mobile/features/space/presentation/widgets/space_guide_overlay.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/app/core/services/check_in_location_service.dart';
import 'package:mobile/app/core/services/nearby_store_validation_service.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  final double _opacity = 1.0;
  bool _showGuide = false;
  late CheckInLocationService _checkInLocationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInLocationService = CheckInLocationService(getIt<SpaceCubit>());
    initializeServices();
    
    // Listen to SpaceCubit state changes to start/stop tracking
    getIt<SpaceCubit>().stream.listen((state) {
      if (state.currentCheckedInSpaceId != null) {
        print('🎯 Check-in detected, starting location tracking');
        _checkInLocationService.startLocationTracking();
      } else {
        print('📍 No active check-in, stopping location tracking');
        _checkInLocationService.stopLocationTracking();
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _checkInLocationService.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed - checking location tracking status');
        // Check if user is checked in and restart tracking
        final spaceState = getIt<SpaceCubit>().state;
        if (spaceState.currentCheckedInSpaceId != null) {
          print('✅ Check-in active, ensuring location tracking is running');
          _checkInLocationService.startLocationTracking();
        }
        break;
      case AppLifecycleState.paused:
        print('📱 App paused - location tracking continues in background');
        // Location tracking continues in background automatically
        // iOS: Uses UIBackgroundModes location
        // Android: Uses forceLocationManager for background updates
        final spaceState = getIt<SpaceCubit>().state;
        if (spaceState.currentCheckedInSpaceId != null) {
          print('🔄 Background tracking active for space: ${spaceState.currentCheckedInSpaceId}');
        }
        break;
      case AppLifecycleState.inactive:
        print('📱 App inactive - location tracking continues');
        // Keep tracking during transitions (e.g., control center, notifications)
        break;
      case AppLifecycleState.detached:
        print('📱 App detached - stopping location tracking and Live Activity');
        _checkInLocationService.stopLocationTracking();
        // End Live Activity when app is terminated
        try {
          final liveActivityService = getIt<LiveActivityService>();
          liveActivityService.endCheckInActivity();
          print('✅ Live Activity ended on app termination');
        } catch (e) {
          print('❌ Failed to end Live Activity on termination: $e');
        }
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden - location tracking continues');
        // Keep tracking when app is hidden but not terminated
        break;
    }
  }

  void _onShowGuide() {
    print('📱 AppView: Request to show guide received');
    setState(() {
      _showGuide = true;
    });
  }

  void _onGuideComplete() {
    print('✅ AppView: Guide completed');
    setState(() {
      _showGuide = false;
    });
  }

  initializeServices() async {
    await getIt<EnableLocationCubit>().onAskDeviceLocation();
    
    // 알림 서비스 초기화 시 콜백 설정
    await NotificationServices.instance.initialize(
      onNotificationTap: _handleNotificationTap,
    );
    
    // 포그라운드 푸시 메시지 리스너 설정 (체크아웃 감지용)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ('📬 Foreground push received').log();
      ('Title: ${message.notification?.title}').log();
      ('Body: ${message.notification?.body}').log();
      
      // 체크아웃 푸시 감지
      if ((message.notification?.title?.contains('체크아웃') ?? false) ||
          (message.notification?.body?.contains('체크아웃') ?? false)) {
        ('🚪 Check-out push detected, ending Live Activity').log();
        _handleCheckOut();
      }
      // 매칭 완료 푸시 감지
      else if ((message.notification?.title?.contains('매칭') ?? false) && 
               (message.notification?.title?.contains('완료') ?? false) ||
               (message.notification?.body?.contains('매칭') ?? false) && 
               (message.notification?.body?.contains('완료') ?? false)) {
        ('🎯 Matching complete push detected').log();
        _handleMatchingComplete('');
      }
    });
    
    final fcmToken = await NotificationServices.instance.getDeviceToken();
    if (fcmToken != null) {
      ("fcmToken: $fcmToken").log();
      getIt<ProfileCubit>()
          .onUpdateUserProfile(UpdateProfileRequestDto(fcmToken: fcmToken));
    }
  }

  /// 알림 탭 처리 함수
  void _handleNotificationTap(NotificationType type, String payloadId) {
    ('🔔 Notification tapped - Type: $type, ID: $payloadId').log();
    
    switch (type) {
      case NotificationType.matchingComplete:
        _handleMatchingComplete(payloadId);
        break;
      case NotificationType.spot:
        // 기존 스팟 알림 처리 로직 (필요시 추가)
        break;
      case NotificationType.chat:
        // 기존 채팅 알림 처리 로직 (필요시 추가)
        break;
      case NotificationType.match:
        // 기존 매치 알림 처리 로직 (필요시 추가)
        break;
      case NotificationType.none:
        break;
    }
  }

  /// 체크아웃 알림 처리
  Future<void> _handleCheckOut() async {
    ('🚪 Handling check-out notification').log();
    
    try {
      // 1. Live Activity 종료
      final liveActivityService = getIt<LiveActivityService>();
      await liveActivityService.endCheckInActivity();
      ('✅ Live Activity ended for check-out').log();
      
      // 2. Space 상태 새로고침 (필요시)
      final spaceCubit = getIt<SpaceCubit>();
      if (spaceCubit.state.currentCheckedInSpaceId != null) {
        await spaceCubit.onFetchAllSpaceViewData();
      }
    } catch (e) {
      ('❌ Error handling check-out: $e').log();
    }
  }
  
  /// 매칭 완료 알림 처리
  Future<void> _handleMatchingComplete(String spaceId) async {
    ('🎯 Matching complete for space: $spaceId').log();
    
    try {
      // 1. Space 관련 상태 새로고침
      final spaceCubit = getIt<SpaceCubit>();
      
      // 전체 스페이스 데이터 새로고침
      spaceCubit.onFetchAllSpaceViewData();
      
      // 특정 스페이스 상세 정보 새로고침 (spaceId가 유효한 경우)
      if (spaceId.isNotEmpty && spaceId != '') {
        spaceCubit.onGetSpaceDetailBySpaceId(spaceId: spaceId);
      }
      
      // 2. 사용자 프로필 정보 새로고침 (포인트, 체크인 상태 등)
      final profileCubit = getIt<ProfileCubit>();
      profileCubit.onGetUserProfile();
      
      // 3. Live Activity 업데이트 (매칭 완료 상태로)
      try {
        final liveActivityService = getIt<LiveActivityService>();
        // 매칭 완료 시에는 Live Activity를 종료
        await liveActivityService.endCheckInActivity();
        ('✅ Live Activity ended for matching completion').log();
      } catch (e) {
        ('❌ Failed to end Live Activity for matching completion: $e').log();
      }
      
      // 4. 사용자에게 매칭 완료 알림 표시 (선택사항)
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('매칭이 완료되었습니다! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      
      ('✅ Matching complete handling finished').log();
    } catch (e) {
      ('❌ Error handling matching complete: $e').log();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                              return NewHomeScreen(
                                onShowGuide: _onShowGuide,
                              );
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
                            ('✅ Check-in button tapped - Validating nearby stores first').log();
                            
                            // 위치를 한 번만 가져와서 전체 체크인 과정에서 재사용
                            Position? checkInPosition;
                            
                            try {
                              // 1. Get current location first (한 번만 가져오기)
                              ('📍 Getting current location for check-in validation').log();
                              checkInPosition = await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );
                              
                              ('📍 Position acquired: ${checkInPosition.latitude}, ${checkInPosition.longitude}').log();
                              ('📍 GPS accuracy: ${checkInPosition.accuracy}m').log();
                              
                              // 2. Refresh space list based on current location
                              ('🔄 Refreshing space list for current location').log();
                              final spaceCubit = getIt<SpaceCubit>();
                              await spaceCubit.onGetAllSpacesForMap(
                                latitude: checkInPosition.latitude,
                                longitude: checkInPosition.longitude,
                              );
                              
                              // Small delay to ensure state is updated
                              await Future.delayed(const Duration(milliseconds: 100));
                              
                              // 3. Pre-validate nearby stores before starting NFC
                              final validationService = getIt<NearbyStoreValidationService>();
                              final nearbyStores = await validationService.validateNearbyStores();
                              
                              if (nearbyStores.isEmpty) {
                                ('❌ No stores within range - showing error dialog').log();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => CheckinFailDialog(
                                    customErrorMessage: '가까운 매장으로 이동해서 다시 시도해봐!',
                                  ),
                                );
                                return;
                              }
                              
                              ('✅ Found ${nearbyStores.length} nearby stores - Starting NFC reading').log();
                              
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
                              
                              // 2. Only start NFC if stores are nearby
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
                                  
                                  // 이미 가져온 위치 재사용 (다시 가져오지 않음)
                                  if (checkInPosition == null) {
                                    ('❌ Position not available - should not happen').log();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => CheckinFailDialog(
                                        customErrorMessage: '위치 정보를 가져올 수 없습니다. 다시 시도해주세요.',
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  ('📍 Reusing location: ${checkInPosition.latitude}, ${checkInPosition.longitude}').log();
                                  
                                  // 1. 먼저 space 정보 가져오기
                                  await getIt<SpaceCubit>().onGetSpaceDetailBySpaceId(
                                    spaceId: spaceId.trim(),
                                  );

                                  final spaceCubit = getIt<SpaceCubit>();
                                  final spaceDetail = spaceCubit.state.spaceDetailEntity;
                                  final spaceEntity = spaceCubit.state.spaceList.firstWhere(
                                    (s) => s.id == spaceId.trim(),
                                    orElse: () => const SpaceEntity.empty(),
                                  );

                                  // 2. 혜택 설명 가져오기
                                  final benefits = spaceCubit.state.benefitsGroupEntity.benefits;
                                  final selectedBenefit = benefits.isNotEmpty ? benefits.first : null;
                                  final benefitDescription = selectedBenefit != null 
                                      ? selectedBenefit.description 
                                      : (spaceEntity.benefitDescription.isNotEmpty 
                                          ? spaceEntity.benefitDescription 
                                          : '체크인 혜택');

                                  bool checkInSuccess = false;
                                  String? checkInErrorMessage;
                                  bool userConfirmed = false;

                                  // 3. 직원확인 다이얼로그 표시
                                  final dialogResult = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext dialogContext) {
                                      return CheckinEmployDialog(
                                        benefitDescription: benefitDescription,
                                        spaceName: spaceDetail.name.isNotEmpty ? spaceDetail.name : '매장',
                                        onConfirm: () {
                                          userConfirmed = true;
                                        },
                                      );
                                    },
                                  );

                                  // 사용자가 취소한 경우 (dialogResult가 true가 아닌 경우)
                                  if (dialogResult != true || !userConfirmed) {
                                    ('⚠️ User cancelled check-in').log();
                                    return;
                                  }
                                  
                                  // 4. 사장님 확인 후 체크인 API 호출
                                  try {
                                    await getIt<SpaceCubit>().onCheckInWithNfc(
                                      spaceId: spaceId.trim(),
                                      latitude: checkInPosition!.latitude,
                                      longitude: checkInPosition.longitude,
                                      benefit: selectedBenefit,
                                    );
                                    ('✅ Check-in API successful').log();
                                    checkInSuccess = true;
                                  } catch (checkInError) {
                                    ('❌ Check-in API failed: $checkInError').log();
                                    checkInSuccess = false;
                                    checkInErrorMessage = checkInError.toString();
                                  }
                                  
                                  // Check if check-in actually failed
                                  if (!checkInSuccess) {
                                    ('❌ Check-in failed').log();
                                    checkInErrorMessage = spaceCubit.state.errorMessage;
                                    
                                    // Parse error message
                                    String errorMessage = checkInErrorMessage ?? '체크인 중 오류가 발생했습니다';
                                    
                                    if (errorMessage.toLowerCase().contains('이미 체크인한 상태입니다') || 
                                        errorMessage.toLowerCase().contains('already_checked_in')) {
                                      errorMessage = '이미 체크인한 상태입니다';
                                    }
                                    
                                    // Show error dialog
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => CheckinFailDialog(
                                        customErrorMessage: errorMessage,
                                      ),
                                    );
                                    return; // 체크인 실패 시 여기서 종료
                                  }
                                  
                                  ('🎯 Check-in successful, proceeding with Live Activity...').log();
                                  
                                  // Space 정보는 이미 위에서 가져왔으므로 상태만 다시 확인
                                  final spaceState = getIt<SpaceCubit>().state;
                                  final updatedSpaceDetail = spaceState.spaceDetailEntity;
                                  
                                  if (updatedSpaceDetail.id.isNotEmpty) {
                                    // currentGroupProgress에서 maxCapacity 파싱 (try 블록 밖으로 이동)
                                    final progress = updatedSpaceDetail.currentGroupProgress;
                                    final parts = progress.split('/');
                                    final maxCapacity = parts.length == 2 ? int.tryParse(parts[1]) ?? 5 : 5;
                                    
                                    // 체크인 사용자 정보 가져오기
                                    try {
                                      final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
                                      final checkInUsersResponse = await spaceRemoteDataSource.getCheckInUsers(
                                        spaceId: spaceId.trim(),
                                      );
                                      
                                      // 현재 체크인한 인원 수 계산
                                      final currentUsers = checkInUsersResponse.currentGroup?.members?.length ?? 1;
                                      final remainingUsers = maxCapacity - currentUsers;
                                      
                                      ('📊 Check-in users - Current: $currentUsers, Remaining: $remainingUsers, Max: $maxCapacity').log();
                                      
                                      // Live Activity 시작 (실제 체크인 데이터 사용)
                                      final liveActivityService = getIt<LiveActivityService>();
                                      await liveActivityService.startCheckInActivity(
                                        spaceName: updatedSpaceDetail.name,
                                        currentUsers: currentUsers,
                                        remainingUsers: remainingUsers,
                                        maxCapacity: maxCapacity,
                                        spaceId: spaceId.trim(),  // 폴링을 위한 spaceId 전달
                                      );
                                    } catch (e) {
                                      ('❌ Failed to fetch check-in users: $e').log();
                                      // 에러 발생 시 기본값으로 Live Activity 시작
                                      final liveActivityService = getIt<LiveActivityService>();
                                      await liveActivityService.startCheckInActivity(
                                        spaceName: updatedSpaceDetail.name,
                                        currentUsers: 1,  // 본인만 체크인한 것으로 표시
                                        remainingUsers: maxCapacity - 1,  // 남은 인원 계산
                                        maxCapacity: maxCapacity,
                                        spaceId: spaceId.trim(),
                                      );
                                    }
                                    
                                    // 라이브 액티비티 업데이트 - 체크인 확인 완료 상태로 변경
                                    try {
                                      ('📱 Updating Live Activity with isConfirmed = true').log();
                                      final liveActivityService = getIt<LiveActivityService>();
                                      await liveActivityService.updateCheckInActivity(
                                        isConfirmed: true,
                                      );
                                      ('✅ Live Activity updated successfully').log();
                                    } catch (e) {
                                      ('❌ Failed to update Live Activity: $e').log();
                                    }
                                    
                                    // 성공 다이얼로그 표시
                                    // Get the current user's available balance
                                    final profileCubit = getIt<ProfileCubit>();
                                    final availableBalance = profileCubit.state.userProfileEntity?.availableBalance ?? 0;
                                    
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: true, // 딤 처리 터치로 닫기 가능
                                      builder: (context) => CheckinSuccessDialog(
                                        spaceName: updatedSpaceDetail.name,
                                        benefitDescription: spaceEntity.benefitDescription.isNotEmpty 
                                            ? spaceEntity.benefitDescription 
                                            : updatedSpaceDetail.introduction,
                                        availableBalance: availableBalance + 1, // Add 1 SAV for the check-in reward
                                      ),
                                    );
                                    
                                    // 체크인 성공 후 사용자 프로필 정보 새로고침
                                    await profileCubit.onGetUserProfile();
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
                                  
                                  // 서버 에러 메시지 파싱
                                  String errorMessage = LocaleKeys.benefitRedeemErrorMsg.tr();
                                  
                                  if (e is HMPError) {
                                    ('❌ HMPError details - message: ${e.message}, error: ${e.error}').log();
                                    
                                    // 서버에서 전달된 직접적인 에러 메시지들 처리
                                    final serverMessage = e.message.toLowerCase();
                                    
                                    if (serverMessage.contains('이미 체크인한 상태입니다') || 
                                        serverMessage.contains('already_checked_in')) {
                                      errorMessage = '이미 체크인한 상태입니다';
                                    } else if (serverMessage.contains('space_out_of_range') ||
                                               serverMessage.contains('거리')) {
                                      errorMessage = '체크인 가능한 거리를 벗어났습니다';
                                    } else if (serverMessage.contains('현재 체크인이 불가능합니다') ||
                                               serverMessage.contains('체크인이 비활성화')) {
                                      errorMessage = '이 공간은 현재 체크인이 불가능합니다';
                                    } else if (serverMessage.contains('체크인 최대 인원수를 초과했습니다') ||
                                               serverMessage.contains('최대 인원')) {
                                      errorMessage = '체크인 최대 인원수를 초과했습니다';
                                    } else if (serverMessage.contains('오늘의 체크인 제한 인원수를 초과했습니다') ||
                                               serverMessage.contains('일일 체크인 제한')) {
                                      errorMessage = '오늘의 체크인 제한 인원수를 초과했습니다';
                                    } else if (serverMessage.contains('invalid_space')) {
                                      errorMessage = '유효하지 않은 공간입니다';
                                    }
                                    
                                    // HMPError의 error 필드에서도 체크 (백업)
                                    if (e.error?.contains('SPACE_OUT_OF_RANGE') == true) {
                                      errorMessage = '체크인 가능한 거리를 벗어났습니다';
                                    } else if (e.error?.contains('ALREADY_CHECKED_IN') == true) {
                                      errorMessage = '이미 체크인한 상태입니다';
                                    } else if (e.error?.contains('INVALID_SPACE') == true) {
                                      errorMessage = '유효하지 않은 공간입니다';
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
                                    builder: (context) => CheckinFailDialog(
                                      customErrorMessage: errorMessage,
                                    ),
                                  );
                                }
                              },
                              onError: (error) {
                                ('❌ NFC error: $error').log();
                                
                                // 사용자 취소는 에러 다이얼로그 표시하지 않음
                                if (error.contains('취소') || 
                                    error.contains('canceled') || 
                                    error.contains('Cancel')) {
                                  ('ℹ️ User canceled NFC reading - no error dialog').log();
                                  return; // 아무 것도 표시하지 않음
                                }
                                
                                // 실제 오류만 다이얼로그 표시
                                String errorMessage = '체크인에 실패했습니다';
                                if (error.contains('권한')) {
                                  errorMessage = 'NFC 권한을 확인해주세요';
                                } else if (error.contains('시간초과') || error.contains('timeout')) {
                                  errorMessage = 'NFC 태그 읽기 시간이 초과되었습니다';
                                } else if (error.contains('시스템이 바쁩')) {
                                  errorMessage = '시스템이 바쁩니다. 잠시 후 다시 시도해주세요';
                                }
                                
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => CheckinFailDialog(
                                    customErrorMessage: errorMessage,
                                  ),
                                );
                              },
                            );
                            
                            } catch (e) {
                              ('❌ Error during nearby store validation: $e').log();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => CheckinFailDialog(
                                  customErrorMessage: '위치 정보를 가져오는 중 오류가 발생했습니다. GPS를 확인해주세요.',
                                ),
                              );
                            }
                          },
                    ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        // Show guide overlay on top of everything
        if (_showGuide)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SpaceGuideOverlay(
              onComplete: _onGuideComplete,
            ),
          ),
      ],
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
                        
                        // Get the current user's available balance
                        final profileCubit = getIt<ProfileCubit>();
                        final availableBalance = profileCubit.state.userProfileEntity?.availableBalance ?? 0;
                        
                        await showDialog(
                          context: context,
                          barrierDismissible: true, // 딤 처리 터치로 닫기 가능
                          builder: (context) => CheckinSuccessDialog(
                            spaceName: spaceToUse.name,
                            benefitDescription: benefitDescription,
                            availableBalance: availableBalance + 1, // Add 1 SAV for the check-in reward
                          ),
                        );
                        
                        // 체크인 성공 후 데이터 새로고침
                        spaceCubit.onFetchAllSpaceViewData();
                        await profileCubit.onGetUserProfile(); // 사용자 프로필 정보 새로고침
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