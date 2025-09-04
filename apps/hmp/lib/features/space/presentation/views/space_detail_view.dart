import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/app/core/helpers/map_utils.dart';
import 'package:mobile/app/core/services/live_activity_service.dart';
import 'package:mobile/app/core/services/safe_nfc_service.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';
import 'package:mobile/features/space/domain/entities/check_in_status_entity.dart';
import 'package:mobile/features/space/domain/entities/check_in_user_entity.dart';
import 'package:mobile/features/space/domain/entities/check_in_users_response_entity.dart';
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

class SpaceDetailView extends StatefulWidget {
  const SpaceDetailView({super.key, required this.space, this.spaceEntity});

  final SpaceDetailEntity space;
  final SpaceEntity? spaceEntity;

  @override
  State<SpaceDetailView> createState() => _SpaceDetailViewState();
}

class _SpaceDetailViewState extends State<SpaceDetailView> with RouteAware {
  late final SpaceRepository _spaceRepository;
  late final LiveActivityService _liveActivityService;
  List<Marker> allMarkers = [];
  late GoogleMapController _controller;
  String? _distanceInKm;
  CheckInStatusEntity? _checkInStatus;
  CheckInUsersResponseEntity? _checkInUsersResponse;
  CurrentGroupEntity? _currentGroup;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5518911, 126.9917937),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _spaceRepository = getIt<SpaceRepository>();
    _liveActivityService = getIt<LiveActivityService>();
    _calculateDistance();
    _fetchCheckInStatus();
    _fetchCheckInUsers();
    _fetchCurrentGroup();
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
            if (widget.space.checkInCount > 0)
              BuildHidingCountWidget(hidingCount: widget.space.checkInCount),
          ],
        ),
        // // 새로 추가된 타이틀 영역 (주석 처리)
        buildTitleRow(widget.space),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
          child: Text(
            widget.space.name,
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
                widget.space.introduction.length > 90
                    ? '${widget.space.introduction.substring(0, 90)}...'
                    : widget.space.introduction,
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
                  );
                },
              ),
              HidingStatusBanner(
                currentGroupProgress: widget.space.currentGroupProgress,
                checkInUsersResponse: _checkInUsersResponse,
                currentGroup: _currentGroup,
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
                          path: "assets/icons/map_navi.png",
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
                        widget.space.address,
                        style: fontCompactSmBold(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const HorizontalSpace(10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                                ClipboardData(text: widget.space.address))
                            .then((_) {
                          Fluttertoast.showToast(
                            msg: LocaleKeys.address_copied.tr(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[800],
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
                if (todayHours != null && !todayHours.isClosed) ...[
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
                        '${todayHours.openTime ?? ''} ~ ${todayHours.closeTime ?? ''}',
                        style: fontCompactSmBold(),
                      ),
                    ],
                  ),
                  if (todayHours.breakStartTime != null &&
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

  Future<void> _handleCheckIn() async {
    print('🔵 _handleCheckIn called');
    print('🔵 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    
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
        
        // 여기서는 실제 spaceId를 사용하지 않고 현재 공간으로 체크인
        // (space_detail_view는 이미 특정 공간에 있으므로)
        await _proceedWithCheckIn();
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
    ('✅ Check-in button tapped - Simulating NFC scan...').log();
    Timer? debugTimer;

    final dialogCompleter = Completer<void>();

    print('🤖 Showing NFC scan dialog...');
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
        _proceedWithCheckIn();
      }
    });
  }

  Future<void> _proceedWithCheckIn() async {
    // Ensure the function is called on a mounted widget
    if (!mounted) return;

    // Short delay to allow the NFC modal to dismiss smoothly
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      final spaceCubit = getIt<SpaceCubit>();
      final benefits = spaceCubit.state.benefitsGroupEntity.benefits;
      final benefitDescription =
          benefits.isNotEmpty ? benefits.first.description : LocaleKeys.no_benefits_registered.tr();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CheckinEmployDialog(
            benefitDescription: benefitDescription,
            spaceName: widget.space.name,
            onConfirm: () async {
              try {
                final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                ('📍 Current location for check-in: ${position.latitude}, ${position.longitude}')
                    .log();

                print('📡 Calling check-in API with parameters:');
                print('   spaceId: ${widget.space.id}');
                print('   latitude: ${position.latitude}');
                print('   longitude: ${position.longitude}');
                
                // 체크인 API 호출 - 실패 시 에러 throw됨
                try {
                  await spaceCubit.onCheckInWithNfc(
                    spaceId: widget.space.id,
                    latitude: position.latitude,
                    longitude: position.longitude,
                  );
                  print('✅ Check-in API successful');
                } catch (checkInError) {
                  print('❌ Check-in API failed: $checkInError');
                  if (mounted) {
                    Navigator.of(context).pop(); // Close employ dialog
                    // 체크인 실패 다이얼로그 표시
                    showDialog(
                      context: context,
                      builder: (context) => CheckinFailDialog(
                        customErrorMessage: checkInError.toString(),
                      ),
                    );
                  }
                  return; // 체크인 실패 시 여기서 종료
                }
                
                print('🎯 Check-in successful, starting Live Activity...');
                
                // 체크인 성공 시에만 Live Activity 시작
                try {
                  final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
                  final checkInUsersResponse = await spaceRemoteDataSource.getCheckInUsers(
                    spaceId: widget.space.id,
                  );
                  
                  // 현재 체크인한 인원 수 계산
                  final currentUsers = checkInUsersResponse.currentGroup?.members?.length ?? 1;
                  final remainingUsers = 5 - currentUsers; // 최대 5명 기준
                  
                  print('📊 Check-in users - Current: $currentUsers, Remaining: $remainingUsers');
                  
                  // Live Activity 시작 (실제 체크인 데이터 사용)
                  final liveActivityService = getIt<LiveActivityService>();
                  await liveActivityService.startCheckInActivity(
                    spaceName: widget.space.name,
                    currentUsers: currentUsers,
                    remainingUsers: remainingUsers,
                    spaceId: widget.space.id,  // 폴링을 위한 spaceId 전달
                  );
                } catch (e) {
                  print('❌ Failed to fetch check-in users or start Live Activity: $e');
                  // 에러 발생 시 기본값으로 Live Activity 시작
                  try {
                    final liveActivityService = getIt<LiveActivityService>();
                    await liveActivityService.startCheckInActivity(
                      spaceName: widget.space.name,
                      currentUsers: 1,  // 본인만 체크인한 것으로 표시
                      remainingUsers: 4,  // 4명이 더 필요한 것으로 표시
                      spaceId: widget.space.id,
                    );
                  } catch (liveActivityError) {
                    print('❌ Failed to start Live Activity: $liveActivityError');
                  }
                }
                
                // 라이브 액티비티 업데이트 - 사장님 확인 완료 상태로 변경
                try {
                  print('📱 Updating Live Activity with isConfirmed = true');
                  await _liveActivityService.updateCheckInActivity(
                    isConfirmed: true,
                  );
                  print('✅ Live Activity updated successfully');
                } catch (e) {
                  print('❌ Failed to update Live Activity: $e');
                }

                if (mounted) {
                  Navigator.of(context).pop(); // Close employ dialog
                  await showDialog(
                    context: context,
                    builder: (context) => CheckinSuccessDialog(
                      spaceName: widget.space.name,
                      benefitDescription: benefitDescription,
                    ),
                  );
                  // 다이얼로그가 닫힌 후 데이터 새로고침
                  _fetchCheckInStatus();
                  _fetchCheckInUsers();
                  _fetchCurrentGroup();
                }
              } catch (e) {
                ('❌ Check-in error: $e').log();
                ('❌ Error type: ${e.runtimeType}').log();
                
                if (mounted) {
                  Navigator.of(context).pop(); // Close employ dialog
                  
                  // 서버 에러 메시지 파싱
                  String errorMessage = '체크인 중 오류가 발생했습니다';
                  
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => CheckinFailDialog(
                      customErrorMessage: errorMessage,
                    ),
                  );
                }
              }
            },
          );
        },
      );
    }
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
                    (spaceDetailEntity.category.toLowerCase() == "walkerhill")
                        ? DefaultImage(
                            path: "assets/icons/walkerhill.png",
                            width: 16,
                            height: 16,
                          )
                        : DefaultImage(
                            path:
                                "assets/icons/ic_space_category_${spaceDetailEntity.category.toLowerCase()}.svg",
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
      String statusText;
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

            if (currentMinutes >= breakStartMinutes &&
                currentMinutes < breakEndMinutes) {
              statusText = LocaleKeys.break_time.tr();
              hoursText = '${_formatTime24To12(todayHours.breakEndTime!)} ${LocaleKeys.reopens_at.tr()}';
            } else {
              hoursText = '${_formatTime24To12(todayHours.closeTime!)} ${LocaleKeys.closes_at.tr()}';
            }
          } else {
            hoursText = '${_formatTime24To12(todayHours.closeTime!)} ${LocaleKeys.closes_at.tr()}';
          }
        }
      } else {
        // Closed
        statusText = LocaleKeys.business_end.tr();

        // Find next business day
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
          hoursText = '${LocaleKeys.tomorrow.tr()} ${_formatTime24To12(tomorrowHours.openTime!)} ${LocaleKeys.opens_at.tr()}';
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
                        path:
                            "assets/icons/ic_space_category_${spaceDetailEntity.category.toLowerCase()}.svg",
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
    String statusText;
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

          if (currentMinutes >= breakStartMinutes &&
              currentMinutes < breakEndMinutes) {
            statusText = LocaleKeys.break_time.tr();
            hoursText = '${_formatTime24To12(todayHours.breakEndTime!)} ${LocaleKeys.reopens_at.tr()}';
          } else {
            hoursText = '${_formatTime24To12(todayHours.closeTime!)} ${LocaleKeys.closes_at.tr()}';
          }
        } else {
          hoursText = '${_formatTime24To12(todayHours.closeTime!)} 마감';
        }
      }
    } else {
      statusText = '영업 종료';

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
        hoursText = '내일 ${_formatTime24To12(tomorrowHours.openTime!)} 오픈';
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
      top: 40,
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
}

class HidingBanner extends StatelessWidget {
  const HidingBanner(
      {super.key, this.checkInStatus, this.onCheckIn, this.benefits = const []});
  final CheckInStatusEntity? checkInStatus;
  final VoidCallback? onCheckIn;
  final List<BenefitEntity> benefits;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = checkInStatus == null;
    final bool isCheckedIn = checkInStatus?.isCheckedIn ?? false;

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
                          if (isCheckedIn) ...[
                            Text(
                              LocaleKeys.checkin_complete.tr(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const VerticalSpace(4),
                            Text(
                              LocaleKeys.checkin_success_get_sav.tr(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ] else ...[
                            Text(
                              benefits.isNotEmpty
                                  ? benefits.first.description
                                  : LocaleKeys.if_you_checkin_and_hide.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (benefits.isEmpty) ...[
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
                  : isCheckedIn
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement siren action
                              },
                              child: Container(
                                width: 150,
                                height: 45,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/icon_siren.svg',
                                  ),
                                ),
                              ),
                            ),
                            const HorizontalSpace(10),
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement share action
                              },
                              child: Container(
                                width: 150,
                                height: 45,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/icon_share.svg',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            print('🟢 Check-in button tapped!');
                            if (onCheckIn != null) {
                              print('🟢 onCheckIn callback exists, calling it...');
                              onCheckIn!();
                            } else {
                              print('🔴 onCheckIn callback is null!');
                            }
                          },
                          child: Container(
                            width: 135,
                            height: 45,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/btn_detail_checkin.svg',
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
      this.currentGroup});

  final String currentGroupProgress;
  final CheckInUsersResponseEntity? checkInUsersResponse;
  final CurrentGroupEntity? currentGroup;

  @override
  Widget build(BuildContext context) {
    final parts = currentGroupProgress.split('/');
    final int progress = parts.length == 2 ? int.tryParse(parts[0]) ?? 0 : 0;
    final int total = parts.length == 2 ? int.tryParse(parts[1]) ?? 5 : 5;

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
            _buildPlayerAvatars(
                (checkInUsersResponse?.users ?? []).take(5).toList()),
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
                                const Color(0xFF19BAFF).withOpacity(0.8);
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
      {bool useTransparentForEmpty = false}) {
    const int itemsPerRow = 5;
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
        rowItems.add(
          _PlayerAvatar(
            imagePath: '${appEnv.apiUrl}public/nft/user/${member.userId}/image',
            name: member.nickName,
            isActive: true, // TODO: Check if this is the current user
            hasAnyMembersInGroup: hasAnyMembers,
          ),
        );
      }

      // Add empty placeholder avatars to fill the remaining slots in the current row
      while (rowItems.length < itemsPerRow) {
        rowItems.add(
          _PlayerAvatar(
            imagePath: ' ', // Empty path for placeholder
            name: '',
            showTransparentOnEmpty: useTransparentForEmpty,
            hasAnyMembersInGroup: hasAnyMembers,
          ),
        );
      }

      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowItems,
        ),
      ));
    }

    // If there are no members, show one row of empty placeholders
    if (rows.isEmpty) {
      List<Widget> emptyRow = [];
      for (int i = 0; i < itemsPerRow; i++) {
        emptyRow.add(
          _PlayerAvatar(
            imagePath: '',
            name: '',
            showTransparentOnEmpty: useTransparentForEmpty,
            hasAnyMembersInGroup: false, // 멤버가 없으므로 false
          ),
        );
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: emptyRow,
      ));
    }

    return Column(children: rows);
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isActive;
  final bool showTransparentOnEmpty;
  final bool hasAnyMembersInGroup;

  const _PlayerAvatar({
    required this.imagePath,
    required this.name,
    this.isActive = false,
    this.showTransparentOnEmpty = false,
    this.hasAnyMembersInGroup = true, // 기본값 true로 설정 (기존 동작 유지)
  });

  @override
  Widget build(BuildContext context) {
    // 그룹에 실제 멤버가 있는 경우에만 이름 영역 높이 확보
    final bool reserveNameSpace = hasAnyMembersInGroup;
    
    return SizedBox(
      height: reserveNameSpace ? 80 : 50, // 멤버가 있으면 80, 없으면 50 (아바타만)
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: const Color(0xFF00A3FF), width: 1)
                  : null,
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