import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/app/core/helpers/map_utils.dart';
import 'package:mobile/app/core/services/live_activity_service.dart';
import 'package:mobile/app/core/services/safe_nfc_service.dart';
import 'package:mobile/app/core/services/global_overlay_service.dart';
import 'package:mobile/features/common/presentation/services/background_location_service.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';
import 'package:mobile/features/space/domain/entities/check_in_status_entity.dart';
import 'package:mobile/features/space/domain/entities/check_in_user_entity.dart';
import 'package:mobile/features/space/domain/entities/check_in_users_response_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_users_response_dto.dart';
import 'package:mobile/features/space/domain/entities/current_group_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/widgets/build_hiding_count_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_employ_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_fail_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/matching_help.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_success_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/space_benefit_list_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/share_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/siren_create_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/siren_post_success_dialog.dart';
import 'package:mobile/features/space/presentation/cubit/siren_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/features/friends/presentation/screens/user_profile_screen.dart';

class SpaceDetailView extends StatefulWidget {
  const SpaceDetailView({super.key, required this.space, this.spaceEntity});

  final SpaceDetailEntity space;
  final SpaceEntity? spaceEntity;

  @override
  State<SpaceDetailView> createState() => _SpaceDetailViewState();
}

class _SpaceDetailViewState extends State<SpaceDetailView> 
    with RouteAware, WidgetsBindingObserver {
  late final SpaceRepository _spaceRepository;
  late final LiveActivityService _liveActivityService;
  
  // Navigator에 직접 접근하기 위한 GlobalKey
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  List<Marker> allMarkers = [];
  late GoogleMapController _controller;
  String? _distanceInKm;
  CheckInStatusEntity? _checkInStatus;
  String? _nfcReadSpaceId;  // NFC로 읽은 매장 ID

  // 체크인 성공 오버레이는 GlobalOverlayService에서 관리
  CheckInUsersResponseEntity? _checkInUsersResponse;
  CurrentGroupEntity? _currentGroup;
  SpaceDetailEntity? _updatedSpaceDetail;
  
  // 주기적 새로고침을 위한 타이머
  Timer? _refreshTimer;
  bool _isActive = true;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5518911, 126.9917937),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _spaceRepository = getIt<SpaceRepository>();
    _liveActivityService = getIt<LiveActivityService>();
    _calculateDistance();
    _fetchCheckInStatus();
    _fetchCheckInUsers();
    
    // 주기적 새로고침 타이머 시작 (30초마다)
    _startPeriodicRefresh();
    _fetchCurrentGroup();
    _fetchSpaceDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicRefresh();
    _isActive = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        ('🔄 [SpaceDetail] App resumed - starting refresh').log();
        if (_isActive && mounted) {
          _startPeriodicRefresh();
          // 앱이 다시 활성화되면 즉시 한 번 새로고침
          _performPeriodicRefresh();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        ('⏸️ [SpaceDetail] App paused/inactive - stopping refresh').log();
        _stopPeriodicRefresh();
        break;
      case AppLifecycleState.hidden:
        ('🫥 [SpaceDetail] App hidden - stopping refresh').log();
        _stopPeriodicRefresh();
        break;
    }
  }

  /// 주기적 새로고침 시작
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isActive || !mounted) {
        timer.cancel();
        return;
      }
      
      ('🔄 [SpaceDetail] Periodic refresh triggered').log();
      _performPeriodicRefresh();
    });
    
    ('⏰ [SpaceDetail] Started periodic refresh every 30 seconds').log();
  }

  /// 주기적 새로고침 중지
  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    ('⏹️ [SpaceDetail] Stopped periodic refresh').log();
  }

  /// 실제 새로고침 작업 수행
  Future<void> _performPeriodicRefresh() async {
    if (!mounted || !_isActive) return;
    
    try {
      ('🔄 [SpaceDetail] Refreshing data...').log();
      
      // 동시에 여러 데이터 새로고침
      await Future.wait([
        _fetchCheckInStatus(),
        _fetchCheckInUsers(),
        _fetchCurrentGroup(),
        _fetchSpaceDetail(),
      ]);
      
      ('✅ [SpaceDetail] Periodic refresh completed').log();
    } catch (e) {
      ('❌ [SpaceDetail] Periodic refresh failed: $e').log();
      
      // 네트워크 오류 등이 발생하면 재시도를 위해 타이머는 계속 유지
    }
  }

  Future<void> _fetchCurrentGroup() async {
    final result =
        await _spaceRepository.getCurrentGroup(spaceId: widget.space.id);
    result.fold(
      (error) {
        print('Error fetching current group: $error');
      },
      (response) {
        print('Successfully fetched current group: $response');
        if (mounted) {
          setState(() {
            _currentGroup = response;
          });
        }
      },
    );
  }

  Future<void> _fetchCheckInUsers() async {
    final result =
        await _spaceRepository.getCheckInUsers(spaceId: widget.space.id);
    result.fold(
      (error) {
        print('Error fetching check-in users: $error');
      },
      (response) {
        print('Successfully fetched check-in users: $response');
        if (mounted) {
          setState(() {
            _checkInUsersResponse = response;
          });
        }
      },
    );
  }

  Future<void> _fetchCheckInStatus() async {
    final result =
        await _spaceRepository.getCheckInStatus(spaceId: widget.space.id);
    result.fold(
      (error) {
        // TODO: Handle error
        print('Error fetching check-in status: $error');
      },
      (status) {
        if (mounted) {
          setState(() {
            _checkInStatus = status;
          });
        }
      },
    );
  }
  
  Future<void> _fetchSpaceDetail() async {
    final result = await _spaceRepository.getSpaceDetail(spaceId: widget.space.id);
    result.fold(
      (error) {
        print('Error fetching space detail: $error');
      },
      (spaceDetail) {
        print('Successfully fetched space detail - checkInCount: ${spaceDetail.checkInCount}');
        if (mounted) {
          setState(() {
            _updatedSpaceDetail = spaceDetail.toEntity();
          });
        }
      },
    );
  }

  Future<void> _calculateDistance() async {
    try {
      print("--- 거리 계산 시작 ---");
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("1. 위치 서비스 활성화 여부: $serviceEnabled");
      if (!serviceEnabled) {
        print("   -> 위치 서비스가 꺼져있어 계산을 중단합니다.");
        return;
      }

      permission = await Geolocator.checkPermission();
      print("2. 현재 위치 권한: $permission");
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("   -> 권한 요청 후 상태: $permission");
        if (permission == LocationPermission.denied) {
          print("   -> 권한이 거부되어 계산을 중단합니다.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("   -> 권한이 영구적으로 거부되어 계산을 중단합니다.");
        return;
      }

      print("3. 현재 위치 가져오기 시도...");
      final position = await Geolocator.getCurrentPosition();
      print("   -> 현재 위치: ${position.latitude}, ${position.longitude}");
      print("   -> 공간 위치: ${widget.space.latitude}, ${widget.space.longitude}");

      // 공간의 좌표가 유효한지 확인
      if (widget.space.latitude == 0 || widget.space.longitude == 0) {
        print("   -> 공간의 좌표가 유효하지 않아 계산을 중단합니다.");
        return;
      }

      print("4. 거리 계산 시도...");
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.space.latitude,
        widget.space.longitude,
      );
      print("   -> 계산된 거리(미터): $distanceInMeters");

      final distanceInKm = distanceInMeters / 1000;
      print("5. 상태 업데이트 시도... (계산된 km: ${distanceInKm.toStringAsFixed(1)})");
      if (mounted) {
        setState(() {
          _distanceInKm = distanceInKm.toStringAsFixed(1);
        });
        print("   -> 상태 업데이트 성공!");
      } else {
        print("   -> 위젯이 unmounted 되어 상태 업데이트를 건너뜁니다.");
      }
      print("--- 거리 계산 종료 ---");
    } catch (e) {
      print("!!! 거리 계산 중 예외 발생: $e !!!");
    }
  }

  Future<void> moveAnimateToAddress(LatLng position) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 92.8334901395799,
          target: position,
          tilt: 9.440717697143555,
          zoom: 18.151926040649414,
        ),
      ),
    );
  }

  Future<void> addMarker(LatLng position) async {
    allMarkers
        .add(Marker(markerId: const MarkerId('myMarker'), position: position));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            widget.space.image == ""
                ? CustomImageView(
                    imagePath: "assets/images/place_holder_card.png",
                    width: MediaQuery.of(context).size.width,
                    height: 160,
                    radius: BorderRadius.circular(2),
                    fit: BoxFit.cover,
                  )
                : CustomImageView(
                    url: widget.space.image,
                    width: MediaQuery.of(context).size.width,
                    height: 160,
                    radius: BorderRadius.circular(2),
                    fit: BoxFit.cover,
                  ),
            buildBackArrowIconButton(context),
            // ✅ FIX: Use actual members count instead of checkInCount for accuracy
            Builder(
              builder: (context) {
                // Priority: actual members > checkInCount from detail > hidingCount from spaceEntity > checkInCount from space
                final actualHidingCount = _checkInUsersResponse?.currentGroup?.members.length
                    ?? _updatedSpaceDetail?.checkInCount
                    ?? widget.spaceEntity?.hidingCount
                    ?? widget.space.checkInCount ?? 0;

                if (actualHidingCount > 0) {
                  return BuildHidingCountWidget(
                    hidingCount: actualHidingCount,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        // // 새로 추가된 타이틀 영역 (주석 처리)
        buildTitleRow(widget.space),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
          child: Text(
            context.locale.languageCode == 'en' && widget.space.nameEn.isNotEmpty
                ? widget.space.nameEn
                : widget.space.name,
            style: fontTitle05Bold(),
          ),
        ),

        // 복원된 원래 함수 호출
        // buildNameTypeRow(widget.space),
        // buildOpenTimeRow(widget.space),

        const VerticalSpace(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Divider(
            thickness: 1,
            color: Color(0x3319BAFF),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                () {
                  final intro = context.locale.languageCode == 'en' && widget.space.introductionEn.isNotEmpty
                      ? widget.space.introductionEn
                      : widget.space.introduction;
                  return intro.length > 90 ? '${intro.substring(0, 90)}...' : intro;
                }(),
                style: fontBodySmMedium(),
              ),
              /*
              const VerticalSpace(10),
              Text(
                widget.space.locationDescription,
                style: fontBodySm(),
              ),
              */
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Divider(
            thickness: 1,
            color: Color(0x3319BAFF),
          ),
        ),

        // 체크인영역
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.checkin_and_matching_benefits.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.1,
                      height: 1.4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const MatchingHelpDialog();
                        },
                      );
                    },
                    child: Row(
                      children: [
                        DefaultImage(
                          path: "assets/icons/icon_detail_matching.svg",
                          width: 16,
                          height: 16,
                        ),
                        const HorizontalSpace(4),
                        Text(
                          LocaleKeys.what_is_matching.tr(),
                          style: fontBodySm(color: Colors.black.withOpacity(0.5)),
                        ),
                        const HorizontalSpace(4),
                        DefaultImage(
                          path: "assets/icons/icon_question.svg",
                          width: 16,
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const VerticalSpace(20),
              BlocBuilder<SpaceCubit, SpaceState>(
                bloc: getIt<SpaceCubit>(),
                builder: (context, state) {
                  return HidingBanner(
                    checkInStatus: _checkInStatus,
                    onCheckIn: _handleCheckIn,
                    benefits: state.benefitsGroupEntity.benefits,
                    currentGroupProgress: _currentGroup?.progress ?? widget.space.currentGroupProgress,
                    onComingSoon: _showSirenCreateDialog,
                    onShare: true ? _showShareDialog : _showShareComingSoonDialog,
                    currentGroup: _currentGroup,
                  );
                },
              ),
              HidingStatusBanner(
                currentGroupProgress: _currentGroup?.progress ?? widget.space.currentGroupProgress,
                checkInUsersResponse: _checkInUsersResponse,
                currentGroup: _currentGroup,
                checkInStatus: _checkInStatus,
                maxCapacity: widget.space.maxCapacity,
              ),
            ],
          ),
        ),

        //const VerticalSpace(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Divider(
            thickness: 1,
            color: Color(0x3319BAFF),
          ),
        ),
        const VerticalSpace(20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFF132E41),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    markers: Set.from(allMarkers),
                    onMapCreated: (GoogleMapController controller) async {
                      setState(() {
                        _controller = controller;
                      });

                      final latLong =
                          LatLng(widget.space.latitude, widget.space.longitude);
                      await moveAnimateToAddress(latLong);
                      await addMarker(latLong);
                    },
                    mapType: MapType.normal,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    indoorViewEnabled: false,
                  ),
                  // This container will absorb gestures on the map
                  Container(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          MapUtils.openMapWithNavigation(
                              widget.space.latitude, widget.space.longitude);
                        },
                        child: DefaultImage(
                          path: context.locale.languageCode == 'en'
                              ? "assets/icons/map_navi_en.png"
                              : "assets/icons/map_navi.png",
                          width: 135,
                          height: 45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 위치, 시간
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Builder(builder: (context) {
            final now = DateTime.now();
            final currentDay = _getDayOfWeekFromDateTime(now);
            BusinessHoursEntity? todayHours;

            if (widget.spaceEntity != null &&
                widget.spaceEntity!.businessHours.isNotEmpty) {
              try {
                todayHours = widget.spaceEntity!.businessHours.firstWhere(
                  (hours) => hours.dayOfWeek == currentDay,
                );
              } catch (e) {
                todayHours = null; // Not found
              }
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DefaultImage(
                      path: "assets/icons/icon_location.png",
                      width: 20,
                      height: 20,
                    ),
                    const HorizontalSpace(10),
                    Expanded(
                      child: Text(
                        context.locale.languageCode == 'en' && widget.space.addressEn.isNotEmpty
                            ? widget.space.addressEn
                            : widget.space.address,
                        style: fontCompactSmBold(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const HorizontalSpace(10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                                ClipboardData(text: context.locale.languageCode == 'en' && widget.space.addressEn.isNotEmpty
                                    ? widget.space.addressEn
                                    : widget.space.address))
                            .then((_) {
                          Fluttertoast.showToast(
                            msg: LocaleKeys.address_copied.tr(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0,
                          );
                        });
                      },
                      child: DefaultImage(
                        path: "assets/icons/icon_copy.svg",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
                // 영업시간 표시 - todayHours가 있으면 상세 정보, 없으면 기본 정보 표시
                if (todayHours != null) ...[
                  const VerticalSpace(10),
                  Row(
                    children: [
                      DefaultImage(
                        path: "assets/icons/icon_time.png",
                        width: 20,
                        height: 20,
                      ),
                      const HorizontalSpace(10),
                      Text(
                        todayHours.isClosed 
                            ? LocaleKeys.closed_today.tr()
                            : '${todayHours.openTime ?? ''} ~ ${todayHours.closeTime ?? ''}',
                        style: fontCompactSmBold(),
                      ),
                    ],
                  ),
                  if (!todayHours.isClosed &&
                      todayHours.breakStartTime != null &&
                      todayHours.breakStartTime!.isNotEmpty &&
                      todayHours.breakEndTime != null &&
                      todayHours.breakEndTime!.isNotEmpty) ...[
                    const VerticalSpace(10),
                    Row(
                      children: [
                        const SizedBox(width: 30), // Indent for alignment
                        Text(
                          '${todayHours.breakStartTime!} ~ ${todayHours.breakEndTime!} ${LocaleKeys.break_time_hours.tr()}',
                          style:
                              fontCompactSm(color: Colors.black.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ],
                ] else if (widget.space.businessHoursStart.isNotEmpty && 
                          widget.space.businessHoursEnd.isNotEmpty) ...[
                  // Fallback: SpaceDetailEntity의 기본 영업시간 정보 사용
                  const VerticalSpace(10),
                  Row(
                    children: [
                      DefaultImage(
                        path: "assets/icons/icon_time.png",
                        width: 20,
                        height: 20,
                      ),
                      const HorizontalSpace(10),
                      Text(
                        '${widget.space.businessHoursStart} ~ ${widget.space.businessHoursEnd}',
                        style: fontCompactSmBold(),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerticalSpace(30),
              // SpaceBenefitListWidget(spaceDetailEntity: widget.space),
              const VerticalSpace(30),
            ],
          ),
        ),
      ],
    );
  }


  void _showNfcScanDialog(BuildContext context, {required Function onCancel}) {
    print('🔷 _showNfcScanDialog called');
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        print('🔷 Building NFC scan dialog UI');
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(color: const Color(0xFF132E41), width: 1),
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
                    color: Color(0xFF132E41).withOpacity(0.3),
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
                          color: Color(0xFF132E41).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF132E41),
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
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.nfc_tag_nearby.tr(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
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
                      color: const Color(0xFF132E41),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132E41),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.smartphone,
                      color: Colors.black,
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
                      backgroundColor: const Color(0xFF132E41),
                      foregroundColor: Colors.black,
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

  // 로컬 체크인 기록 확인 메서드
  Future<bool> _isAlreadyCheckedInToday(String spaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(StorageValues.lastCheckInDate) ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 날짜가 다르면 기록 초기화
    if (lastDate != today) {
      print('📅 Date changed from $lastDate to $today, clearing check-in records');
      await prefs.remove(StorageValues.dailyCheckedInSpaces);
      await prefs.setString(StorageValues.lastCheckInDate, today);
      return false;
    }

    // 당일 체크인 기록 확인
    final checkedSpaces = prefs.getStringList(StorageValues.dailyCheckedInSpaces) ?? [];
    final isCheckedIn = checkedSpaces.contains(spaceId);
    print('📱 Local check-in record for $spaceId: ${isCheckedIn ? "Already checked in today" : "Not checked in today"}');
    print('📱 Today\'s checked-in spaces: $checkedSpaces');
    return isCheckedIn;
  }

  // 체크인 성공 시 로컬 저장
  Future<void> _saveLocalCheckInRecord(String spaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 당일 체크인 목록에 추가
    final checkedSpaces = prefs.getStringList(StorageValues.dailyCheckedInSpaces) ?? [];
    if (!checkedSpaces.contains(spaceId)) {
      checkedSpaces.add(spaceId);
      await prefs.setStringList(StorageValues.dailyCheckedInSpaces, checkedSpaces);
      print('💾 Saved check-in record for space: $spaceId');
      print('💾 Updated daily check-in list: $checkedSpaces');
    }

    // 날짜 업데이트
    await prefs.setString(StorageValues.lastCheckInDate, today);
    print('💾 Updated last check-in date to: $today');
  }

  Future<void> _handleCheckIn() async {
    print('🔵 _handleCheckIn called');
    print('🔵 Platform: ${Platform.isIOS ? "iOS" : "Android"}');

    // 서버에서 체크인 상태 확인 (1차 방어)
    try {
      final result = await _spaceRepository.getCheckInUsers(spaceId: widget.space.id);
      final serverCheckResult = result.fold(
        (error) => null,
        (response) => response,
      );

      if (serverCheckResult != null) {
        print('🔍 Server check-in status: hasCheckedInToday=${serverCheckResult.hasCheckedInToday}, isUnlimitedUser=${serverCheckResult.isUnlimitedUser}');

        // 오늘 이미 체크인했고, 무제한 유저가 아닌 경우 차단
        if (serverCheckResult.hasCheckedInToday && !serverCheckResult.isUnlimitedUser) {
          print('🚫 Already checked in today (server response)');
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => CheckinFailDialog(
                customErrorMessage: '오늘 이미 이 매장에 체크인했어! 내일 다시 방문해줘 😊',
              ),
            );
          }
          return; // 체크인 프로세스 중단
        }
      } else {
        // 서버 응답 실패 시 로컬 체크로 fallback
        print('⚠️ Server check failed, falling back to local check');
        if (await _isAlreadyCheckedInToday(widget.space.id)) {
          print('🚫 Already checked in today (local record)');
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => CheckinFailDialog(
                customErrorMessage: '오늘 이미 이 매장에 체크인했어! 내일 다시 방문해줘 😊',
              ),
            );
          }
          return; // 체크인 프로세스 중단
        }
      }
    } catch (e) {
      print('⚠️ Error checking server status: $e, falling back to local check');
      // 예외 발생 시 로컬 체크로 fallback
      if (await _isAlreadyCheckedInToday(widget.space.id)) {
        print('🚫 Already checked in today (local record)');
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CheckinFailDialog(
              customErrorMessage: '오늘 이미 이 매장에 체크인했어! 내일 다시 방문해줘 😊',
            ),
          );
        }
        return; // 체크인 프로세스 중단
      }
    }

    // 먼저 거리 체크
    print('📍 Checking distance to store before proceeding...');
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.space.latitude,
        widget.space.longitude,
      );
      
      print('📏 Distance to store: ${distance.toStringAsFixed(1)}m');
      
      // 50m 이상 떨어져 있으면 체크인 차단
      if (distance > 50.0) {
        print('❌ Too far from store: ${distance.toStringAsFixed(1)}m > 50m');
        
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CheckinFailDialog(
              customErrorMessage: '매장에서 너무 멀리 떨어져 있어. 가까이 이동해서 다시 시도해봐!',
            ),
          );
        }
        return; // 체크인 프로세스 중단
      }
      
      print('✅ Distance check passed: ${distance.toStringAsFixed(1)}m < 50m');
      
    } catch (e) {
      print('❌ Failed to get location: $e');
      
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CheckinFailDialog(
            customErrorMessage: '위치를 확인할 수 없습니다. 위치 권한을 확인해주세요.',
          ),
        );
      }
      return; // 체크인 프로세스 중단
    }
    
    // 거리 체크 통과 후 기존 프로세스 진행
    if (Platform.isIOS) {
      print('🔵 Calling _handleCheckInIOS');
      _handleCheckInIOS();
    } else {
      print('🔵 Calling _handleCheckInAndroid');
      _handleCheckInAndroid();
    }
  }

  Future<void> _handleCheckInIOS() async {
    print('🍎 _handleCheckInIOS started');
    print('🍎 Using SafeNfcService for iOS NFC reading...');
    
    // SafeNfcService 사용 (앱바와 동일한 방식)
    await SafeNfcService.startReading(
      context: context,
      onSuccess: (spaceId) async {
        print('🍎 NFC tag read successfully: $spaceId');
        ('📍 NFC UUID read: $spaceId').log();

        // NFC로 읽은 매장 ID 저장
        _nfcReadSpaceId = spaceId;
        print('💾 Saved NFC space ID: $_nfcReadSpaceId');

        print('🚀 NFC callback: calling _proceedWithCheckInDirect');
        await _proceedWithCheckInDirect();
      },
      onError: (errorMessage) {
        print('🍎 NFC error: $errorMessage');
        ('NFC error: $errorMessage').log();
        
        // 사용자가 취소한 경우는 에러 다이얼로그를 표시하지 않음
        if (errorMessage.contains('cancelled') || errorMessage.contains('Session invalidated')) {
          ('NFC scan cancelled by user.').log();
        }
      },
    );
  }

  Future<void> _handleCheckInAndroid() async {
    print('🤖 _handleCheckInAndroid started');
    print('🤖 Using SafeNfcService for Android NFC reading...');
    
    // Show NFC scan dialog
    _showNfcScanDialog(context, onCancel: () async {
      ('🟧 NFC Scan Canceled by user.').log();
      // Stop NFC session
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {
        // Ignore errors when stopping session
      }
    });
    
    // SafeNfcService 사용 (iOS와 동일)
    await SafeNfcService.startReading(
      context: context,
      onSuccess: (spaceId) async {
        print('🤖 NFC tag read successfully: $spaceId');
        ('📍 NFC UUID read: $spaceId').log();

        // NFC로 읽은 매장 ID 저장
        _nfcReadSpaceId = spaceId;
        print('💾 Saved NFC space ID: $_nfcReadSpaceId');

        // Close NFC dialog first
        if (mounted && context.mounted) {
          Navigator.of(context).pop();
          await _proceedWithCheckIn(context);
        } else {
          print('⚠️ Widget or context not mounted after NFC read');
        }
      },
      onError: (errorMessage) {
        print('🤖 NFC error: $errorMessage');
        ('NFC error: $errorMessage').log();
        
        if (mounted && context.mounted) {
          Navigator.of(context).pop(); // Close NFC dialog
          
          // 사용자가 취소한 경우는 에러 다이얼로그를 표시하지 않음
          if (!errorMessage.contains('cancelled') && !errorMessage.contains('Session invalidated')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  // 직접 체크인 처리하는 새로운 메서드 (앱바와 동일한 방식)
  Future<void> _proceedWithCheckInDirect() async {
    print('🔄 _proceedWithCheckInDirect called');
    
    // mounted 상태 체크
    if (!mounted) {
      print('⚠️ Widget not mounted');
      return;
    }
    
    // 바로 체크인 프로세스 진행 (지연 없이)
    print('✅ Context is mounted, proceeding with check-in flow immediately...');
    final isEnglish = context.locale.languageCode == 'en';

    // ✅ FIX: Get benefit from spaceCubit to use the latest check-in target space info
    final spaceCubit = getIt<SpaceCubit>();
    final targetSpaceId = _nfcReadSpaceId ?? widget.space.id;
    print('🎯 Target space ID for benefit: $targetSpaceId (NFC: $_nfcReadSpaceId, widget: ${widget.space.id})');
    final targetSpace = spaceCubit.state.spaceList.firstWhere(
      (s) => s.id == targetSpaceId,
      orElse: () => SpaceEntity.empty(),
    );

    final benefitDescription = targetSpace.id.isNotEmpty
        ? (isEnglish && targetSpace.benefitDescriptionEn.isNotEmpty
            ? targetSpace.benefitDescriptionEn
            : (targetSpace.benefitDescription.isNotEmpty
                ? targetSpace.benefitDescription
                : LocaleKeys.no_benefits_registered.tr()))
        : LocaleKeys.no_benefits_registered.tr();

    bool userConfirmed = false;

    // Show CheckinEmployDialog and wait for user confirmation
    print('💳 Showing CheckinEmployDialog...');
    final dialogResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // false로 변경하여 딤 터치로 닫히지 않도록
      builder: (BuildContext context) {
        return CheckinEmployDialog(
          benefitDescription: benefitDescription,
          spaceName: widget.space.name,
          onConfirm: () {
            print('✅ User confirmed in CheckinEmployDialog - onConfirm callback called');
            userConfirmed = true;
          },
        );
      },
    );

    print('📊 Dialog completed - dialogResult: $dialogResult, userConfirmed: $userConfirmed');

    // User cancelled
    if (dialogResult != true) {
      print('⚠️ User cancelled check-in - dialogResult was: $dialogResult');
      return;
    }

    if (!userConfirmed) {
      print('⚠️ userConfirmed is false - onConfirm callback was not called properly');
      return;
    }

    print('🎯 Both dialogResult=true and userConfirmed=true, proceeding with check-in...');

    // 이후 비즉니스 로직 계속... (앱바와 동일한 패턴)
    await _performCheckInDirect();
  }
  
  Future<void> _proceedWithCheckIn(BuildContext dialogContext) async {
    print('🔄 _proceedWithCheckIn called with context');
    
    // Check both mounted and context.mounted
    if (!mounted || !dialogContext.mounted) {
      print('⚠️ Widget or context not mounted, returning early from _proceedWithCheckIn');
      return;
    }

    // Short delay to allow the NFC modal to dismiss smoothly
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted && dialogContext.mounted) {
      print('✅ Widget and context still mounted after delay, proceeding with check-in flow');
      final isEnglish = dialogContext.locale.languageCode == 'en';

      // ✅ FIX: Get benefit from spaceCubit to use the latest check-in target space info
      final spaceCubit = getIt<SpaceCubit>();
      final targetSpaceId = _nfcReadSpaceId ?? widget.space.id;
      print('🎯 Target space ID for benefit: $targetSpaceId (NFC: $_nfcReadSpaceId, widget: ${widget.space.id})');
      final targetSpace = spaceCubit.state.spaceList.firstWhere(
        (s) => s.id == targetSpaceId,
        orElse: () => SpaceEntity.empty(),
      );

      final benefitDescription = targetSpace.id.isNotEmpty
          ? (isEnglish && targetSpace.benefitDescriptionEn.isNotEmpty
              ? targetSpace.benefitDescriptionEn
              : (targetSpace.benefitDescription.isNotEmpty
                  ? targetSpace.benefitDescription
                  : LocaleKeys.no_benefits_registered.tr()))
          : LocaleKeys.no_benefits_registered.tr();

      bool userConfirmed = false;
      
      // Show CheckinEmployDialog and wait for user confirmation
      print('📋 Showing CheckinEmployDialog...');
      final dialogResult = await showDialog<bool>(
        context: dialogContext,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CheckinEmployDialog(
            benefitDescription: benefitDescription,
            spaceName: widget.space.name,
            onConfirm: () {
              print('✅ User confirmed in CheckinEmployDialog');
              userConfirmed = true;
              // onConfirm 콜백이 호출되면 dialog는 자체적으로 Navigator.pop(context, true)를 호출함
            },
          );
        },
      );

      print('📊 Dialog result: $dialogResult, userConfirmed: $userConfirmed');
      
      // User cancelled
      if (dialogResult != true || !userConfirmed) {
        print('⚠️ User cancelled check-in (dialogResult: $dialogResult, userConfirmed: $userConfirmed)');
        return;
      }
      
      print('✅ User confirmed, proceeding with check-in...');

      // User confirmed, proceed with check-in
      await _performCheckIn(dialogContext);
    } else {
      print('⚠️ Widget or context unmounted after delay, cannot proceed with check-in');
    }
  }
  
  // 기존 _performCheckIn 메서드에서 비즈니스 로직 처리
  Future<void> _performCheckInOriginal(BuildContext savedContext, String benefitDescription) async {
    bool checkInSuccess = false;
    
    try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        ('📍 Current location for check-in: ${position.latitude}, ${position.longitude}')
            .log();

        // 위치 검증 추가
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.space.latitude,
          widget.space.longitude,
        );
        
        print('📏 Distance to store: ${distance.toStringAsFixed(1)}m');
        
        // 50m 이상 떨어져 있으면 체크인 차단
        if (distance > 50.0) {
          print('❌ Too far from store: ${distance.toStringAsFixed(1)}m > 50m');
          
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => CheckinFailDialog(
                customErrorMessage: '매장에서 너무 멀리 떨어져 있어. 가까이 이동해서 다시 시도해봐!',
              ),
            );
          }
          return;
        }

        print('📡 Calling check-in API with parameters:');
        print('   spaceId: ${widget.space.id}');
        print('   latitude: ${position.latitude}');
        print('   longitude: ${position.longitude}');
        
        // 체크인 API 호출 - 실패 시 에러 throw됨
        String? checkInErrorMessage;
        
        print('📱 Calling onCheckInWithNfc...');
        final spaceCubit = getIt<SpaceCubit>();
        print('🔍 Before check-in call - submitStatus: ${spaceCubit.state.submitStatus}');
        print('🔍 Before check-in call - errorMessage: ${spaceCubit.state.errorMessage}');
        
        bool checkInApiCalled = false;
        try {
          final targetSpaceId = _nfcReadSpaceId ?? widget.space.id;
          print('🎯 Check-in target space ID: $targetSpaceId (NFC: $_nfcReadSpaceId, widget: ${widget.space.id})');
          await spaceCubit.onCheckInWithNfc(
            spaceId: targetSpaceId,
            latitude: position.latitude,
            longitude: position.longitude,
          );
          checkInApiCalled = true;
          print('✅ onCheckInWithNfc completed without exception');
        } catch (e) {
          print('🚨 Exception caught: $e');
          checkInApiCalled = false;
        }
        
        // Always check the state after the call
        print('📊 After check-in call - submitStatus: ${spaceCubit.state.submitStatus}');
        print('📊 After check-in call - errorMessage: ${spaceCubit.state.errorMessage}');
        print('📊 After check-in call - checkInApiCalled: $checkInApiCalled');
        
        // 명확한 성공/실패 판단
        // API 호출 성공 + 에러 메시지 없음 = 성공
        if (checkInApiCalled && spaceCubit.state.errorMessage.isEmpty) {
          print('✅ Check-in API successful');
          print('🎉 Setting checkInSuccess = true');
          checkInSuccess = true;
        } else if (spaceCubit.state.errorMessage.isNotEmpty) {
          // 에러 메시지가 있으면 실패
          print('❌ Check-in failed with error: ${spaceCubit.state.errorMessage}');
          checkInErrorMessage = spaceCubit.state.errorMessage;
          checkInSuccess = false;
          
          // Show error dialog
          if (mounted && savedContext.mounted) {
            await showDialog(
              context: savedContext,
              barrierDismissible: false,
              builder: (context) => CheckinFailDialog(
                customErrorMessage: checkInErrorMessage,
              ),
            );
          }
          return; // Exit after showing error
        } else if (!checkInApiCalled) {
          // API 호출 자체가 실패한 경우
          print('❌ Check-in API call failed');
          checkInSuccess = false;
          return;
        } else {
          // 그 외의 경우 (submitStatus가 애매한 경우)
          print('⚠️ Ambiguous state but treating as success');
          print('   - checkInApiCalled: $checkInApiCalled');
          print('   - submitStatus: ${spaceCubit.state.submitStatus}');
          print('   - errorMessage: ${spaceCubit.state.errorMessage}');
          checkInSuccess = true;
        }
      } catch (e) {
        // 체크인 실패 시에만 에러 처리
        ('❌ Check-in error: $e').log();
        ('❌ Error type: ${e.runtimeType}').log();
        checkInSuccess = false; // 명시적으로 실패 설정
        
        if (mounted && savedContext.mounted) {
          // 서버 에러 메시지 파싱
          String errorMessage = '체크인 중 오류가 발생했습니다';
          
          if (e is Exception) {
            // Exception 타입의 에러 메시지 추출
            final exceptionMessage = e.toString();
            if (exceptionMessage.startsWith('Exception: ')) {
              errorMessage = exceptionMessage.substring(11);
            }
          } else if (e is HMPError) {
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
            } else if (e.message.isNotEmpty) {
              // 서버에서 직접 전달된 메시지가 있으면 그대로 사용
              errorMessage = e.message;
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
          
          // 커스텀 에러 메시지와 함께 체크인 실패 다이얼로그 표시
          await showDialog(
            context: savedContext,
            barrierDismissible: false,
            builder: (context) => CheckinFailDialog(
              customErrorMessage: errorMessage,
            ),
          );
        }
      }
      
      // 체크인이 성공한 경우에만 후속 작업 처리
      print('🔍 Final checkInSuccess value: $checkInSuccess');
      if (checkInSuccess) {
        print('🎯 Check-in successful, proceeding with post-check-in tasks...');
        
        // 라이브 액티비티 시작 (에러가 나도 체크인 성공에는 영향 없음)
        try {
          print('🔄 Fetching check-in users for Live Activity...');
          final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
          
          CheckInUsersResponseDto? checkInUsersResponse;
          try {
            checkInUsersResponse = await spaceRemoteDataSource.getCheckInUsers(
              spaceId: widget.space.id,
            ).timeout(Duration(seconds: 5)); // 5초 타임아웃으로 단축
            print('✅ Successfully fetched check-in users for Live Activity');
          } catch (e) {
            print('⚠️ getCheckInUsers failed or timed out: $e');
            print('🔄 Proceeding with default values...');
            // API 호출 실패 시 null로 유지하고 기본값 사용
          }
          
          // SpaceEntity의 maxCapacity 사용
          final maxCapacity = widget.space.maxCapacity > 0 ? widget.space.maxCapacity : 5;
          
          // 현재 체크인한 인원 수 계산 (API 응답이 없으면 기본값 1 사용)
          final currentUsers = checkInUsersResponse?.currentGroup?.members?.length ?? 1;
          final remainingUsers = maxCapacity - currentUsers;
                  
          print('📊 Check-in users - Current: $currentUsers, Remaining: $remainingUsers, Max: $maxCapacity');
          
          // Live Activity 시작 (실제 체크인 데이터 또는 기본값 사용)
          final liveActivityService = getIt<LiveActivityService>();
          /*await liveActivityService.startCheckInActivity(
            spaceName: widget.space.name,
            currentUsers: currentUsers,
            remainingUsers: remainingUsers,
            maxCapacity: maxCapacity,
            spaceId: widget.space.id,  // 폴링을 위한 spaceId 전달
          );*/
          print('✅ Live Activity started successfully');
        } catch (e) {
          print('❌ Failed to start Live Activity: $e');
          // Live Activity 실패해도 체크인 성공 다이얼로그는 표시해야 함
          print('🔄 Proceeding without Live Activity...');
        }
        
        // Live Activity 업데이트는 서버 Push로 처리됨
        print('📱 Live Activity will be updated via server push');

        // savedContext만 체크
        print('🔍 Checking savedContext.mounted: ${savedContext.mounted}');
        
        if (savedContext.mounted) {
          print('📱 SavedContext is mounted, proceeding with success flow...');
          // CheckinEmployDialog는 자체적으로 닫히므로 Navigator.pop() 제거
          
          // 체크인 성공 다이얼로그 표시 전에 데이터 먼저 새로고침
          print('🔄 Refreshing data after successful check-in...');
          await Future.wait([
            _fetchCheckInStatus(),
            _fetchCheckInUsers(),  // 매칭 중인 하이더 업데이트
            _fetchCurrentGroup(),   // 프로그레스바 업데이트
            _fetchSpaceDetail(),    // Space 정보 업데이트 (checkInCount 포함)
          ]);
          
          // 프로필 정보도 업데이트 (홈화면, 프로필화면 반영)
          final profileCubit = getIt<ProfileCubit>();
          await profileCubit.onGetUserProfile();
          
          print('✅ Data refresh completed');
          
          // Get the updated available balance
          final availableBalance = profileCubit.state.userProfileEntity?.availableBalance ?? 0;
          print('💰 Current balance: $availableBalance SAV');
          
          // 데이터 업데이트 후 성공 다이얼로그 표시
          print('🎉 Showing CheckinSuccessDialog with savedContext...');
          
          await showDialog(
            context: savedContext,  // 저장된 context 사용
            barrierDismissible: true, // 딤 처리 터치로 닫기 가능
            builder: (dialogContext) => CheckinSuccessDialog(
              spaceName: widget.space.name,
              benefitDescription: benefitDescription,
              availableBalance: availableBalance, // Already updated from server
            ),
          );
          print('✅ CheckinSuccessDialog closed');

          // Request background location permission after check-in
          if (savedContext.mounted) {
            print('🔔 Requesting background location permission after check-in...');
            await BackgroundLocationService.checkAndRequestBackgroundLocation(savedContext);
            print('✅ Background location permission request completed');
          }

          // NFC 체크인 ID 초기화
          _nfcReadSpaceId = null;
          print('🧹 Cleared NFC space ID');

          // ✅ FIX: Refresh space data after check-in to update hiding count
          print('🔄 Refreshing space data after check-in...');
          await _performPeriodicRefresh();
          print('✅ Space data refreshed');
        } else {
          print('⚠️ SavedContext is not mounted, skipping success dialog');
        }
      }
  }
  
  // 앱바와 동일한 패턴의 체크인 처리
  Future<void> _performCheckInDirect() async {
    print('🔄 _performCheckInDirect started');

    // End any existing Live Activity before starting new check-in
    try {
      final liveActivityService = getIt<LiveActivityService>();
      await liveActivityService.endCheckInActivity();
      print('🔄 Ended existing Live Activity before new check-in');
    } catch (e) {
      print('⚠️ No existing Live Activity to end or failed to end: $e');
    }

    bool checkInSuccess = false;
    
    try {
      // 위치 권한 및 현재 위치 확인
      final position = await Geolocator.getCurrentPosition();
      
      // 위치 검증 추가
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.space.latitude,
        widget.space.longitude,
      );
      
      print('📏 Distance to store: ${distance.toStringAsFixed(1)}m');
      
      // 50m 이상 떨어져 있으면 체크인 차단
      if (distance > 50.0) {
        print('❌ Too far from store: ${distance.toStringAsFixed(1)}m > 50m');
        
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CheckinFailDialog(
              customErrorMessage: '매장에서 너무 멀리 떨어져 있어. 가까이 이동해서 다시 시도해봐!',
            ),
          );
        }
        return;
      }

      // 체크인 API 호출
      print('📱 Calling spaceCubit.onCheckInWithNfc...');
      final spaceCubit = getIt<SpaceCubit>();
      final targetSpaceId = _nfcReadSpaceId ?? widget.space.id;
      print('🎯 Check-in target space ID: $targetSpaceId (NFC: $_nfcReadSpaceId, widget: ${widget.space.id})');
      await spaceCubit.onCheckInWithNfc(
        spaceId: targetSpaceId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      // API 성공 확인
      print('📊 After API call - errorMessage: "${spaceCubit.state.errorMessage}"');
      if (spaceCubit.state.errorMessage.isEmpty) {
        print('✅ Check-in API successful');
        checkInSuccess = true;
      } else {
        print('❌ Check-in failed with error: ${spaceCubit.state.errorMessage}');
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CheckinFailDialog(
              customErrorMessage: spaceCubit.state.errorMessage,
            ),
          );
        }
        return;
      }
    } catch (e) {
      print('❌ Check-in error: $e');
      
      // Clean up Live Activity if it was started
      try {
        final liveActivityService = getIt<LiveActivityService>();
        await liveActivityService.endCheckInActivity();
        print('🧹 Live Activity cleaned up after check-in failure');
      } catch (cleanupError) {
        print('⚠️ Failed to clean up Live Activity: $cleanupError');
      }
      
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CheckinFailDialog(
            customErrorMessage: '체크인 중 오류가 발생했습니다',
          ),
        );
      }
      return;
    }
    
    // 체크인 성공 시 후속 처리 (앱바와 동일한 패턴)
    if (checkInSuccess) {
      print('🎯 Check-in successful, proceeding with post-check-in tasks...');

      // 1. 로컬에 체크인 기록 저장 (추가 방어)
      await _saveLocalCheckInRecord(widget.space.id);
      print('💾 Local check-in record saved');

      // 2. 체크인 상태 즉시 업데이트 (버튼 비활성화를 위해)
      print('🔄 Immediately updating check-in status...');
      await _fetchCheckInStatus();
      print('✅ Check-in status updated');

      // 3. UI 즉시 새로고침으로 버튼 비활성화
      if (mounted) {
        setState(() {
          print('🎨 UI refreshed - check-in button should be disabled now');
        });
      }

      // Live Activity는 SpaceCubit.onCheckInWithNfc에서 시작됨
      // 업데이트는 서버 Push 또는 폴링으로 처리됨
      print('📱 Live Activity is managed by SpaceCubit and server push');

      print('🔄 Updating profile...');
      // 프로필 정보 업데이트
      final profileCubit = getIt<ProfileCubit>();
      await profileCubit.onGetUserProfile();
      print('✅ Profile updated');

      // 성공 상태 업데이트 (setState 사용)
      print('🔍 Checking mounted: $mounted');

      final availableBalance = profileCubit.state.userProfileEntity?.availableBalance ?? 0;
      print('💰 Available balance: $availableBalance');

      // 체크인 성공 시점에 현재 매장의 최신 혜택 정보 가져오기
      final isEnglish = context.locale.languageCode == 'en';
      final spaceCubit = getIt<SpaceCubit>();
      final targetSpaceId = _nfcReadSpaceId ?? widget.space.id;
      print('🎯 Target space ID for benefit: $targetSpaceId (NFC: $_nfcReadSpaceId, widget: ${widget.space.id})');
      final targetSpace = spaceCubit.state.spaceList.firstWhere(
        (s) => s.id == targetSpaceId,
        orElse: () => SpaceEntity.empty(),
      );

      final benefitDescription = targetSpace.id.isNotEmpty
          ? (isEnglish && targetSpace.benefitDescriptionEn.isNotEmpty
              ? targetSpace.benefitDescriptionEn
              : (targetSpace.benefitDescription.isNotEmpty
                  ? targetSpace.benefitDescription
                  : LocaleKeys.no_benefits_registered.tr()))
          : LocaleKeys.no_benefits_registered.tr();

      print('🎉 Triggering CheckinSuccess overlay with setState...');
      print('📋 Success parameters:');
      print('   - spaceName: ${widget.space.name}');
      print('   - benefitDescription: $benefitDescription');
      print('   - availableBalance: $availableBalance');

      // 전역 오버레이 서비스 호출 (mounted 상태 무관)
      GlobalOverlayService.showCheckInSuccessOverlay(
        spaceName: widget.space.name ?? '매장',
        benefitDescription: benefitDescription ?? '체크인 혜택',
        availableBalance: availableBalance,  // 서버에서 이미 체크인 획득분이 반영된 최신 값
      );
      print('✅ GlobalOverlayService called successfully');

      print('🔄 Starting data refresh...');
      // 데이터 새로고침 (mounted 체크 없이 실행) - 체크인 상태 한번 더 확인
      try {
        await Future.wait([
          _fetchCheckInStatus(), // 한번 더 확실히 업데이트
          _fetchCheckInUsers(),
          _fetchCurrentGroup(),
          _fetchSpaceDetail(),
        ]);
        print('✅ Data refresh completed');
      } catch (e) {
        print('⚠️ Data refresh failed: $e');
      }
    } else {
      print('❌ Check-in was not successful, skipping post-processing');
    }
  }

  // 기존 메서드들 (하위 호환성을 위해 유지)
  Future<void> _performCheckIn(BuildContext savedContext) async {
    // 새로운 방식으로 리다이렉트
    await _performCheckInDirect();
  }

  /// Builds a row that displays the category icon, business status, and distance.
  Widget buildTitleRow(SpaceDetailEntity spaceDetailEntity) {
    final status = _getBusinessStatus(spaceDetailEntity, widget.spaceEntity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Icon and Status
          Row(
            children: [
              // Category with blue background label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF19BAFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (spaceDetailEntity.category.toLowerCase() == "meal")
                        ? DefaultImage(
                            path: "assets/icons/icon_label_food.png",
                            width: 16,
                            height: 16,
                          )
                        : (spaceDetailEntity.category.toLowerCase() == "walkerhill")
                            ? DefaultImage(
                                path: "assets/icons/walkerhill.png",
                                width: 16,
                                height: 16,
                              )
                            : DefaultImage(
                                path: () {
                                  final validCategories = ['cafe', 'coworking', 'entire', 'etc', 'meal', 'music', 'pub'];
                                  final lowerCategory = spaceDetailEntity.category.toLowerCase();
                                  if (validCategories.contains(lowerCategory)) {
                                    return "assets/icons/ic_space_category_$lowerCategory.svg";
                                  }
                                  return "assets/icons/ic_space_category_etc.svg";
                                }(),
                                width: 16,
                                height: 16,
                              ),
                    const HorizontalSpace(5),
                    Text(
                      getLocalCategoryName(spaceDetailEntity.category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const HorizontalSpace(15),
              Text(
                status.text,
                style: fontCompactSm(color: status.color),
              ),
            ],
          ),
          // Right side: Distance
          if (_distanceInKm != null)
            Text(
              LocaleKeys.distance_from_me.tr(args: [_distanceInKm ?? '']),
              style: fontBodySm(color: fore3),
            )
          else
            // 로딩 중일 때 빈 공간을 차지하여 UI가 흔들리지 않도록 함
            const SizedBox(height: 18),
        ],
      ),
    );
  }

  /// Determines the business status text and color.
  ({String text, Color color}) _getBusinessStatus(
      SpaceDetailEntity spaceDetailEntity, SpaceEntity? spaceEntity) {
    // 1. Use detailed business hours if available
    if (spaceEntity != null && spaceEntity.businessHours.isNotEmpty) {
      // Temporary closure check
      if (spaceEntity.isTemporarilyClosed) {
        return (text: LocaleKeys.temporarily_closed.tr(), color: Colors.red[300]!);
      }

      final isOpen = spaceEntity.isCurrentlyOpen;
      final now = DateTime.now();
      final currentDay = _getDayOfWeekFromDateTime(now);

      final todayHours = spaceEntity.businessHours.firstWhere(
        (hours) => hours.dayOfWeek == currentDay,
        orElse: () => BusinessHoursEntity(
          dayOfWeek: currentDay,
          isClosed: true,
        ),
      );

      Color color = isOpen ? hmpBlue : fore3;
      String statusText = '';
      String hoursText = '';

      if (isOpen) {
        statusText = LocaleKeys.business_open.tr();
        if (todayHours.closeTime != null) {
          // Break time check
          if (todayHours.breakStartTime != null &&
              todayHours.breakEndTime != null) {
            final breakStartParts = todayHours.breakStartTime!.split(':');
            final breakEndParts = todayHours.breakEndTime!.split(':');
            final currentMinutes = now.hour * 60 + now.minute;
            final breakStartMinutes = int.parse(breakStartParts[0]) * 60 +
                int.parse(breakStartParts[1]);
            final breakEndMinutes =
                int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

            // 휴게시간 30분 전 체크
            if (currentMinutes >= breakStartMinutes - 30 && currentMinutes < breakStartMinutes) {
              hoursText = '${todayHours.breakStartTime!} ${LocaleKeys.break_time.tr()}';
            } else if (currentMinutes >= breakStartMinutes &&
                currentMinutes < breakEndMinutes) {
              statusText = LocaleKeys.break_time.tr();
              hoursText = '${todayHours.breakEndTime!} ${LocaleKeys.reopens_at.tr()}';
            } else {
              hoursText = '${todayHours.closeTime!} ${LocaleKeys.closes_at.tr()}';
            }
          } else {
            hoursText = '${todayHours.closeTime!} ${LocaleKeys.closes_at.tr()}';
          }
        }
      } else {
        // Closed
        final currentMinutes = now.hour * 60 + now.minute;
        bool isHandled = false;

        // 1. 오늘 휴무인지 확인
        if (todayHours.isClosed) {
          statusText = LocaleKeys.closed_day.tr();
          isHandled = true;

          // 내일 영업 시간 표시
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final tomorrowDay = _getDayOfWeekFromDateTime(tomorrow);
          final tomorrowHours = spaceEntity.businessHours.firstWhere(
            (hours) => hours.dayOfWeek == tomorrowDay,
            orElse: () => BusinessHoursEntity(
              dayOfWeek: tomorrowDay,
              isClosed: true,
            ),
          );

          if (!tomorrowHours.isClosed && tomorrowHours.openTime != null) {
            hoursText = '${LocaleKeys.tomorrow.tr()} ${tomorrowHours.openTime!} ${LocaleKeys.opens_at.tr()}';
          }
        }

        // 2. 오픈 전인지 확인
        if (!isHandled && todayHours.openTime != null) {
          final openParts = todayHours.openTime!.split(':');
          final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);

          if (currentMinutes < openMinutes) {
            statusText = LocaleKeys.business_before_open.tr();
            hoursText = '${todayHours.openTime!} ${LocaleKeys.opens_at.tr()}';
            isHandled = true;
          }
        }

        // 3. 휴게시간 중인지 확인
        if (!isHandled && todayHours.breakStartTime != null && todayHours.breakEndTime != null) {
          final breakStartParts = todayHours.breakStartTime!.split(':');
          final breakEndParts = todayHours.breakEndTime!.split(':');
          final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
          final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

          if (currentMinutes >= breakStartMinutes && currentMinutes < breakEndMinutes) {
            statusText = LocaleKeys.break_time.tr();
            hoursText = '${todayHours.breakEndTime!} 까지';
            isHandled = true;
          }
        }

        // 4. 영업 종료 (기본)
        if (!isHandled) {
          statusText = LocaleKeys.business_end.tr();

          // 마감 시간 이후면 내일 오픈 시간 표시
          if (todayHours.closeTime != null) {
            final closeParts = todayHours.closeTime!.split(':');
            final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

            if (currentMinutes > closeMinutes) {
              final tomorrow = DateTime.now().add(const Duration(days: 1));
              final tomorrowDay = _getDayOfWeekFromDateTime(tomorrow);
              final tomorrowHours = spaceEntity.businessHours.firstWhere(
                (hours) => hours.dayOfWeek == tomorrowDay,
                orElse: () => BusinessHoursEntity(
                  dayOfWeek: tomorrowDay,
                  isClosed: true,
                ),
              );

              if (!tomorrowHours.isClosed && tomorrowHours.openTime != null) {
                hoursText = '${LocaleKeys.tomorrow.tr()} ${tomorrowHours.openTime!} ${LocaleKeys.opens_at.tr()}';
              }
            }
          }
        }
      }

      // Combine the texts
      final combinedText =
          hoursText.isNotEmpty ? '$statusText • $hoursText' : statusText;

      return (text: combinedText, color: color);
    }

    // 2. Fallback to old logic
    bool isSpaceOpen = spaceDetailEntity.spaceOpen == true;
    return (
      text: isSpaceOpen ? LocaleKeys.open.tr() : LocaleKeys.businessClosed.tr(),
      color: isSpaceOpen ? hmpBlue : fore3
    );
  }

  // ===================================================================
  // =================== 복원된 함수들 시작 ===================
  // ===================================================================

  /// Builds a row that displays the name and type of the space.
  Padding buildNameTypeRow(SpaceDetailEntity spaceDetailEntity) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            spaceDetailEntity.name,
            style: fontTitle05Bold(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(
              color: fore5,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                (spaceDetailEntity.category.toLowerCase() == "walkerhill")
                    ? DefaultImage(
                        path: "assets/icons/walkerhill.png",
                        width: 16,
                        height: 16,
                      )
                    : DefaultImage(
                        path: () {
                          final validCategories = ['cafe', 'coworking', 'entire', 'etc', 'meal', 'music', 'pub'];
                          final lowerCategory = spaceDetailEntity.category.toLowerCase();
                          if (validCategories.contains(lowerCategory)) {
                            return "assets/icons/ic_space_category_$lowerCategory.svg";
                          }
                          return "assets/icons/ic_space_category_etc.svg";
                        }(),
                        width: 16,
                        height: 16,
                      ),
                const HorizontalSpace(3),
                Text(
                  getLocalCategoryName(spaceDetailEntity.category),
                  style: fontCompactSm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a row that displays the opening time of the space.
  Padding buildOpenTimeRow(SpaceDetailEntity spaceDetailEntity) {
    if (widget.spaceEntity != null &&
        widget.spaceEntity!.businessHours.isNotEmpty) {
      return _buildBusinessHoursWithWeekdays(widget.spaceEntity!);
    }

    final start = spaceDetailEntity.businessHoursStart;
    final end = spaceDetailEntity.businessHoursEnd;
    bool isSpaceOpen = spaceDetailEntity.spaceOpen == true;
    Color color = isSpaceOpen ? hmpBlue : fore3;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            getOpenCloseString(start, end),
            style: fontCompactSm(color: color),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: fore4,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            getBusinessHours(spaceDetailEntity.businessHoursStart,
                spaceDetailEntity.businessHoursEnd),
            style: fontCompactSm(color: fore2),
          )
        ],
      ),
    );
  }

  Padding _buildBusinessHoursWithWeekdays(SpaceEntity space) {
    if (space.isTemporarilyClosed) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              LocaleKeys.temporarily_closed.tr(),
              style: fontCompactSm(color: Colors.red[300]),
            ),
          ],
        ),
      );
    }

    final isOpen = space.isCurrentlyOpen;
    final now = DateTime.now();
    final currentDay = _getDayOfWeekFromDateTime(now);

    final todayHours = space.businessHours.firstWhere(
      (hours) => hours.dayOfWeek == currentDay,
      orElse: () => BusinessHoursEntity(
        dayOfWeek: currentDay,
        isClosed: true,
      ),
    );

    Color color = isOpen ? hmpBlue : fore3;
    String statusText = '';
    String hoursText = '';

    if (isOpen) {
      statusText = '영업 중';
      if (todayHours.closeTime != null) {
        if (todayHours.breakStartTime != null &&
            todayHours.breakEndTime != null) {
          final breakStartParts = todayHours.breakStartTime!.split(':');
          final breakEndParts = todayHours.breakEndTime!.split(':');
          final currentMinutes = now.hour * 60 + now.minute;
          final breakStartMinutes = int.parse(breakStartParts[0]) * 60 +
              int.parse(breakStartParts[1]);
          final breakEndMinutes =
              int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

          // 휴게시간 30분 전 체크
          if (currentMinutes >= breakStartMinutes - 30 && currentMinutes < breakStartMinutes) {
            hoursText = '${todayHours.breakStartTime!} ${LocaleKeys.break_time.tr()}';
          } else if (currentMinutes >= breakStartMinutes &&
              currentMinutes < breakEndMinutes) {
            statusText = LocaleKeys.break_time.tr();
            hoursText = '${todayHours.breakEndTime!} ${LocaleKeys.reopens_at.tr()}';
          } else {
            hoursText = '${todayHours.closeTime!} ${LocaleKeys.closes_at.tr()}';
          }
        } else {
          hoursText = '${todayHours.closeTime!} 마감';
        }
      }
    } else {
      // Closed
      final currentMinutes = now.hour * 60 + now.minute;
      bool isHandled = false;

      // 1. 오늘 휴무인지 확인
      if (todayHours.isClosed) {
        statusText = LocaleKeys.closed_day.tr();
        isHandled = true;

        // 내일 영업 시간 표시
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowDay = _getDayOfWeekFromDateTime(tomorrow);
        final tomorrowHours = space.businessHours.firstWhere(
          (hours) => hours.dayOfWeek == tomorrowDay,
          orElse: () => BusinessHoursEntity(
            dayOfWeek: tomorrowDay,
            isClosed: true,
          ),
        );

        if (!tomorrowHours.isClosed && tomorrowHours.openTime != null) {
          hoursText = '${LocaleKeys.tomorrow.tr()} ${tomorrowHours.openTime!} ${LocaleKeys.opens_at.tr()}';
        }
      }

      // 2. 오픈 전인지 확인
      if (!isHandled && todayHours.openTime != null) {
        final openParts = todayHours.openTime!.split(':');
        final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);

        if (currentMinutes < openMinutes) {
          statusText = LocaleKeys.business_before_open.tr();
          hoursText = '${todayHours.openTime!} ${LocaleKeys.opens_at.tr()}';
          isHandled = true;
        }
      }

      // 3. 휴게시간 중인지 확인
      if (!isHandled && todayHours.breakStartTime != null && todayHours.breakEndTime != null) {
        final breakStartParts = todayHours.breakStartTime!.split(':');
        final breakEndParts = todayHours.breakEndTime!.split(':');
        final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

        if (currentMinutes >= breakStartMinutes && currentMinutes < breakEndMinutes) {
          statusText = LocaleKeys.break_time.tr();
          hoursText = '${todayHours.breakEndTime!} 까지';
          isHandled = true;
        }
      }

      // 4. 영업 종료 (기본)
      if (!isHandled) {
        statusText = '영업 종료';

        // 마감 시간 이후면 내일 오픈 시간 표시
        if (todayHours.closeTime != null) {
          final closeParts = todayHours.closeTime!.split(':');
          final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

          if (currentMinutes > closeMinutes) {
            final tomorrow = DateTime.now().add(const Duration(days: 1));
            final tomorrowDay = _getDayOfWeekFromDateTime(tomorrow);
            final tomorrowHours = space.businessHours.firstWhere(
              (hours) => hours.dayOfWeek == tomorrowDay,
              orElse: () => BusinessHoursEntity(
                dayOfWeek: tomorrowDay,
                isClosed: true,
              ),
            );

            if (!tomorrowHours.isClosed && tomorrowHours.openTime != null) {
              hoursText = '내일 ${tomorrowHours.openTime!} 오픈';
            }
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            statusText,
            style: fontCompactSm(color: color),
          ),
          if (hoursText.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              width: 2,
              height: 2,
              decoration: const BoxDecoration(
                color: fore4,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              hoursText,
              style: fontCompactSm(color: fore2),
            ),
          ],
        ],
      ),
    );
  }

  DayOfWeek _getDayOfWeekFromDateTime(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return DayOfWeek.MONDAY;
      case 2:
        return DayOfWeek.TUESDAY;
      case 3:
        return DayOfWeek.WEDNESDAY;
      case 4:
        return DayOfWeek.THURSDAY;
      case 5:
        return DayOfWeek.FRIDAY;
      case 6:
        return DayOfWeek.SATURDAY;
      case 7:
        return DayOfWeek.SUNDAY;
      default:
        return DayOfWeek.MONDAY;
    }
  }

  String _formatTime24To12(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;

    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) {
      return '${LocaleKeys.am.tr()} 12:$minute';
    } else if (hour < 12) {
      return '${LocaleKeys.am.tr()} $hour:$minute';
    } else if (hour == 12) {
      return '${LocaleKeys.pm.tr()} 12:$minute';
    } else {
      return '${LocaleKeys.pm.tr()} ${hour - 12}:$minute';
    }
  }

  String getBusinessHours(String? start, String? end) {
    if (start == null || end == null) {
      return "";
    }
    return "$start ~ $end";
  }

  String getOpenCloseString(String? start, String? end) {
    if (start == null || end == null) {
      return LocaleKeys.openingHours.tr();
    }
    try {
      int startHour = int.parse(start.split(':')[0]);
      int endHour = int.parse(end.split(':')[0]);
      DateTime now = DateTime.now();
      int currentHour = now.hour;
      if (currentHour >= startHour && currentHour < endHour) {
        return LocaleKeys.open.tr();
      } else {
        return LocaleKeys.businessClosed.tr();
      }
    } catch (e) {
      return LocaleKeys.openingHours.tr();
    }
  }

  // ===================================================================
  // =================== 복원된 함수들 끝 =====================
  // ===================================================================

  Positioned buildBackArrowIconButton(BuildContext context) {
    return Positioned(
      top: 60,
      left: 28,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 10,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: DefaultImage(
              path: "assets/icons/img_icon_arrow.svg",
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
    );
  }

  void _showSirenCreateDialog() async {
    final sirenCubit = getIt<SirenCubit>();
    final profileCubit = getIt<ProfileCubit>();

    final locale = context.locale.languageCode;
    final isEnglish = locale == 'en';
    final spaceName = isEnglish && widget.space.nameEn?.isNotEmpty == true
        ? widget.space.nameEn!
        : widget.space.name ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SirenCreateDialog(
          spaceId: widget.space.id ?? '',
          spaceName: spaceName,
          onConfirm: (String message, int hours, int points) async {
            // 사이렌 생성
            final success = await sirenCubit.createSiren(
              spaceId: widget.space.id ?? '',
              message: message,
              days: hours, // hours를 그대로 전달 (cubit에서 변환)
            );

            if (success) {
              // 사이렌 생성 전 현재 잔액
              final currentBalance = profileCubit.state.userProfileEntity?.availableBalance ?? 0;

              // 차감된 잔액 계산 (서버 업데이트 타이밍 이슈 방지)
              final remainingBalance = currentBalance - points;

              // 프로필 다시 조회하여 최신 데이터 동기화
              await profileCubit.onGetUserProfile();

              // 성공 다이얼로그 표시
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (BuildContext successContext) {
                    return SirenPostSuccessDialog(
                      pointsUsed: points,
                      remainingPoints: remainingBalance,  // 클라이언트에서 계산한 차감 후 값
                    );
                  },
                );
              }
            } else {
              // 실패 시 에러 메시지 토스트
              Fluttertoast.showToast(
                msg: '포인트가 부족해!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: const Color(0xFFE8F4F8),
                textColor: Colors.black87,
              );
            }
          },
        );
      },
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return ShareDialog(
          spaceDetailEntity: widget.space,
          spaceEntity: widget.spaceEntity,
        );
      },
    );
  }

  void _showShareComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.coming_soon.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.share_coming_soon.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19BAFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      LocaleKeys.confirm.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
}

class HidingBanner extends StatefulWidget {
  const HidingBanner(
      {super.key, this.checkInStatus, this.onCheckIn, this.benefits = const [], this.currentGroupProgress, this.onComingSoon, this.onShare, this.currentGroup});
  final CheckInStatusEntity? checkInStatus;
  final Future<void> Function()? onCheckIn;
  final VoidCallback? onComingSoon;
  final VoidCallback? onShare;
  final List<BenefitEntity> benefits;
  final String? currentGroupProgress;
  final CurrentGroupEntity? currentGroup;

  @override
  State<HidingBanner> createState() => _HidingBannerState();
}

class _HidingBannerState extends State<HidingBanner> {
  bool _isProcessing = false;

  // 그룹 인원수에 따른 보너스 포인트 계산
  int getGroupBonusPoints(int groupSize) {
    switch (groupSize) {
      case 2: return 2;
      case 3: return 3;
      case 4: return 5;
      case 5: return 7;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = widget.checkInStatus == null;
    final bool isCheckedIn = widget.checkInStatus?.isCheckedIn ?? false;

    // Parse currentGroupProgress to get total
    final parts = (widget.currentGroupProgress ?? '').split('/');
    final int total = parts.length == 2 ? int.tryParse(parts[1]) ?? 5 : 5;
    
    // 매칭 완료 여부 판단 - 사용자가 그룹에서 빠졌는지 확인
    final profileCubit = getIt<ProfileCubit>();
    final myUserId = profileCubit.state.userProfileEntity?.id;
    
    // 그룹 멤버에 내가 있는지 확인
    final isInGroup = widget.currentGroup?.members.any(
      (member) => member.userId == myUserId
    ) ?? false;
    
    // 매칭 완료 = 포인트를 받았지만(보너스 포인트) 그룹에서 빠진 상태
    final isMatchingComplete = (widget.checkInStatus?.earnedPoints ?? 0) > 1 && !isInGroup;

    // SVG의 그라데이션 정의
    const gradient = LinearGradient(
      colors: [Color(0xFF72CCFF), Color(0xFFF9F395)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      height: 168,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: const Color(0xFF132E41), width: 1), // Black border
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 상단 반투명 흰색 박스
            Positioned(
              top: 15,
              left: 16,
              right: 16,
              child: Container(
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCheckedIn && isMatchingComplete) ...[
                            // 체크인도 하고 매칭도 완료된 상태
                            Text(
                              LocaleKeys.daily_benefit.tr(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const VerticalSpace(4),
                            Text(
                              LocaleKeys.come_tomorrow.tr(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ] else if (isCheckedIn) ...[
                            // 체크인만 완료된 상태
                            Text(
                              LocaleKeys.checkin_complete.tr(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const VerticalSpace(4),
                            Text(
                              context.locale.languageCode == 'en' 
                                ? LocaleKeys.checkin_success_get_sav.tr(args: [
                                    getGroupBonusPoints(total).toString(),
                                    total.toString()
                                  ])
                                : LocaleKeys.checkin_success_get_sav.tr(args: [
                                    total.toString(), 
                                    getGroupBonusPoints(total).toString()
                                  ]),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ] else ...[
                            // Debug logs for benefit description
                            Builder(
                              builder: (context) {
                                print('🔍 [HidingBanner] Locale: ${context.locale.languageCode}');
                                if (widget.benefits.isNotEmpty) {
                                  print('🔍 [HidingBanner] descriptionEn: "${widget.benefits.first.descriptionEn}"');
                                  print('🔍 [HidingBanner] descriptionEn.isNotEmpty: ${widget.benefits.first.descriptionEn.isNotEmpty}');
                                  print('🔍 [HidingBanner] description: "${widget.benefits.first.description}"');
                                }
                                return const SizedBox.shrink();
                              }
                            ),
                            Text(
                              widget.benefits.isNotEmpty
                                  ? (context.locale.languageCode == 'en' && widget.benefits.first.descriptionEn.isNotEmpty
                                      ? widget.benefits.first.descriptionEn
                                      : widget.benefits.first.description)
                                  : LocaleKeys.if_you_checkin_and_hide.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (widget.benefits.isEmpty) ...[
                              const VerticalSpace(4),
                              Text(
                                LocaleKeys.various_benefits.tr(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]
                          ]
                        ],
                      ),
              ),
            ),
            // 하단 버튼
            Positioned(
              bottom: 15,
              child: isLoading
                  ? const SizedBox(height: 45) // 로딩 중일 때 버튼 공간 확보
                  : isCheckedIn || true
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: widget.onComingSoon,
                              child: Container(
                                width: 150,
                                height: 45,
                                child: Center(
                                  child: SvgPicture.asset(
                                    context.locale.languageCode == 'en'
                                        ? 'assets/icons/icon_siren_en.svg'
                                        : 'assets/icons/icon_siren.svg',
                                  ),
                                ),
                              ),
                            ),
                            const HorizontalSpace(10),
                            GestureDetector(
                              onTap: widget.onShare,
                              child: Container(
                                width: 150,
                                height: 45,
                                child: Center(
                                  child: SvgPicture.asset(
                                    context.locale.languageCode == 'en'
                                        ? 'assets/icons/icon_share_en.svg'
                                        : 'assets/icons/icon_share.svg',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _isProcessing 
                              ? null 
                              : () async {
                                  print('🟢 Check-in button tapped!');
                                  if (widget.onCheckIn != null) {
                                    print('🟢 onCheckIn callback exists, calling it...');
                                    setState(() {
                                      _isProcessing = true;
                                    });
                                    try {
                                      await widget.onCheckIn!();
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                      }
                                    }
                                  } else {
                                    print('🔴 onCheckIn callback is null!');
                                  }
                                },
                          child: AnimatedOpacity(
                            opacity: _isProcessing ? 0.5 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 135,
                              height: 45,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/btn_detail_checkin.svg',
                                    ),
                                  ),
                                  if (_isProcessing)
                                    Container(
                                      width: 135,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(22.5),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF132E41)),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class HidingStatusBanner extends StatelessWidget {
  const HidingStatusBanner(
      {super.key,
      required this.currentGroupProgress,
      this.checkInUsersResponse,
      this.currentGroup,
      this.checkInStatus,
      required this.maxCapacity});

  final String currentGroupProgress;
  final CheckInUsersResponseEntity? checkInUsersResponse;
  final CurrentGroupEntity? currentGroup;
  final CheckInStatusEntity? checkInStatus;
  final int maxCapacity;

  @override
  Widget build(BuildContext context) {
    final parts = currentGroupProgress.split('/');
    final int progress = parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0;
    final int total = maxCapacity > 0 ? maxCapacity : 5; // 전달받은 maxCapacity 사용, 0이면 기본값 5

    print('🎯 [HidingStatusBanner] Using maxCapacity: $total (from SpaceEntity.maxCapacity)');

    // 현재 유저 ID 가져오기
    final currentUserId = getIt<ProfileCubit>().state.userProfileEntity?.id;
    print('🔍 [HidingStatusBanner] Current User ID: $currentUserId');
    print('🔍 [HidingStatusBanner] checkInUsersResponse: $checkInUsersResponse');
    print('🔍 [HidingStatusBanner] currentGroup: $currentGroup');
    print('🔍 [HidingStatusBanner] checkInUsersResponse?.users.length: ${checkInUsersResponse?.users.length}');
    print('🔍 [HidingStatusBanner] currentGroup?.members.length: ${currentGroup?.members.length}');

    final memberIds =
        currentGroup?.members.map((e) => e.userId).toSet() ?? {};
    final completedHiders = (checkInUsersResponse?.users ?? [])
        .where((user) => !memberIds.contains(user.userId))
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          left: BorderSide(color: const Color(0xFF132E41), width: 1),
          right: BorderSide(color: const Color(0xFF132E41), width: 1),
          bottom: BorderSide(color: const Color(0xFF132E41), width: 1),
        ),
      ),
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(15, 16, 15, 9), // Adjust for border
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8FF),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.matching_hiders.tr(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const VerticalSpace(10),
            () {
              // 매칭중인 하이더는 currentGroup.members를 사용해야 함
              var matchingUsers = (currentGroup?.members ?? []);
              
              print('🔍 [HidingStatusBanner] Using currentGroup.members for matching hiders');
              print('🔍 [HidingStatusBanner] Matching users count: ${matchingUsers.length}');
              
              // 디버깅: 매칭중인 멤버 정보 출력
              for (var member in matchingUsers) {
                print('🔍 [HidingStatusBanner] Matching Member: ${member.nickName} (${member.userId})');
              }
              
              return _buildPlayerAvatars(matchingUsers, maxCapacity: total, currentUserId: currentUserId);
            }(),
            const VerticalSpace(20),
            // Simplified progress bar
            SizedBox(
              height: 27,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress Bar Body
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13.5),
                    child: Row(
                      children: List.generate(total, (index) {
                        Color? segmentColor;
                        Gradient? segmentGradient;

                        // Case 1: Progress is 0, all segments are dark.
                        if (progress == 0) {
                          segmentColor = Colors.white;
                        }
                        // Case 2: Progress is full, all segments are solid blue.
                        else if (progress >= total) {
                          segmentColor = const Color(0xFF19BAFF);
                        }
                        // Case 3: Progress is partial (1 to total-1).
                        else {
                          if (index < progress - 1) {
                            // Filled segments are solid blue.
                            segmentColor = const Color(0xFF19BAFF);
                          } else if (index == progress - 1) {
                            // The last filled segment has a gradient.
                            segmentGradient = const LinearGradient(
                              colors: [
                                Color(0xFF19BAFF),
                                Color(0xBF19BAFF),
                                Color(0x8019BAFF),
                                Color(0x4019BAFF),
                                Color(0xFF19BAFF),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            );
                          } else {
                            // Unfilled segments are dark.
                            segmentColor =
                                Colors.white.withOpacity(0.8);
                          }
                        }
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: segmentColor,
                              gradient: segmentGradient,
                              border: index < total - 1
                                  ? Border(
                                      right: BorderSide(
                                        color:
                                            Colors.black.withOpacity(0.0),
                                        width: 1,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.5),
                      border: Border.all(color: const Color(0xFF132E41)),
                    ),
                  ),
                  // Text
                  Center(
                    child: Text(
                      LocaleKeys.more_to_get_sav.tr(args: [(total - progress).toString()]),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalSpace(20),
            if (completedHiders.isNotEmpty) ...[
              Text(
                LocaleKeys.completed_matching_hiders.tr(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const VerticalSpace(10),
              _buildPlayerAvatars(completedHiders,
                  useTransparentForEmpty: true),
              const VerticalSpace(20),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatars(List<CheckInUserEntity> members,
      {bool useTransparentForEmpty = false, int? maxCapacity, String? currentUserId}) {
    final int itemsPerRow = maxCapacity ?? 5;
    List<Widget> rows = [];
    
    // 실제 멤버가 있는지 확인
    final bool hasAnyMembers = members.isNotEmpty;

    for (int i = 0; i < members.length; i += itemsPerRow) {
      List<Widget> rowItems = [];
      int end =
          (i + itemsPerRow > members.length) ? members.length : (i + itemsPerRow);
      List<CheckInUserEntity> sublist = members.sublist(i, end);

      // Add avatars for actual members in the current row
      for (var member in sublist) {
        final isCurrentUser = currentUserId != null && member.userId == currentUserId;
        
        // profileImageUrl이 있으면 우선 사용, 없으면 기존 패턴 사용
        final imageUrl = (member.profileImageUrl?.isNotEmpty == true) 
            ? member.profileImageUrl!
            : '${appEnv.apiUrl}public/nft/user/${member.userId}/image';
            
        print('🔍 [_buildPlayerAvatars] Member: ${member.nickName} (${member.userId}), isActive: $isCurrentUser');
        print('🖼️ [_buildPlayerAvatars] Using image URL: $imageUrl');
        
        rowItems.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _PlayerAvatar(
              imagePath: imageUrl,
              name: member.nickName,
              userId: member.userId,
              isActive: isCurrentUser,
              hasAnyMembersInGroup: hasAnyMembers,
            ),
          ),
        );
      }

      // Add empty placeholder avatars to fill the remaining slots in the current row
      while (rowItems.length < itemsPerRow) {
        rowItems.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _PlayerAvatar(
              imagePath: ' ', // Empty path for placeholder
              name: '',
              showTransparentOnEmpty: useTransparentForEmpty,
              hasAnyMembersInGroup: hasAnyMembers,
            ),
          ),
        );
      }

      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: rowItems,
        ),
      ));
    }

    // If there are no members, show one row of empty placeholders
    if (rows.isEmpty) {
      List<Widget> emptyRow = [];
      for (int i = 0; i < itemsPerRow; i++) {
        emptyRow.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _PlayerAvatar(
              imagePath: '',
              name: '',
              showTransparentOnEmpty: useTransparentForEmpty,
              hasAnyMembersInGroup: false, // 멤버가 없으므로 false
            ),
          ),
        );
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: emptyRow,
      ));
    }

    return Column(children: rows);
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String imagePath;
  final String name;
  final String? userId;
  final bool isActive;
  final bool showTransparentOnEmpty;
  final bool hasAnyMembersInGroup;

  const _PlayerAvatar({
    required this.imagePath,
    required this.name,
    this.userId,
    this.isActive = false,
    this.showTransparentOnEmpty = false,
    this.hasAnyMembersInGroup = true, // 기본값 true로 설정 (기존 동작 유지)
  });

  @override
  Widget build(BuildContext context) {
    // 그룹에 실제 멤버가 있는 경우에만 이름 영역 높이 확보
    final bool reserveNameSpace = hasAnyMembersInGroup;
    final bool isClickable = name.isNotEmpty && userId != null && userId!.isNotEmpty;

    Widget avatarWidget = SizedBox(
      height: reserveNameSpace ? 80 : 50, // 멤버가 있으면 80, 없으면 50 (아바타만)
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: Colors.black, width: 1, style: BorderStyle.solid)
                  : Border.all(color: Colors.transparent, width: 0, style: BorderStyle.none),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00A3FF).withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: name.isNotEmpty
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: imagePath.startsWith('http')
                        ? NetworkImage(imagePath)
                        : AssetImage(imagePath) as ImageProvider,
                    backgroundColor: Colors.grey,
                  )
                : showTransparentOnEmpty
                    ? const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                      )
                    : SvgPicture.asset(
                        'assets/images/player_none.svg',
                        width: 50,
                        height: 50,
                      ),
          ),
          if (reserveNameSpace) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 22,
              child: name.isNotEmpty && !showTransparentOnEmpty
                  ? Text(
                      name,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );

    if (isClickable) {
      return GestureDetector(
        onTap: () {
          UserProfileScreen.push(context, userId: userId!);
        },
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int progress;
  final int total;

  const _ProgressBar({required this.progress, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.5),
        border: Border.all(color: Colors.black),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.5),
        child: Stack(
          children: [
            LinearProgressIndicator(
              value: progress / total,
              backgroundColor: Colors.white.withOpacity(0.8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF19BAFF)),
            ),
            Center(
              child: Text(
                "${total - progress}명만 더 모이면 SAV 획득!",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}