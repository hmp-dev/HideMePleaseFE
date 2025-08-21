import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/map_utils.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/widgets/build_hiding_count_widget.dart';
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
  List<Marker> allMarkers = [];
  late GoogleMapController _controller;
  String? _distanceInKm;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5518911, 126.9917937),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _calculateDistance();
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
            if (widget.space.hidingCount > 0)
              BuildHidingCountWidget(hidingCount: widget.space.hidingCount),
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
                widget.space.introduction,
                style: fontTitle05(),
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: GoogleMap(
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
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                indoorViewEnabled: true,
                onTap: (argument) {
                  MapUtils.openMap(widget.space.latitude, widget.space.longitude);
                },
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    LocaleKeys.location.tr(),
                    style: fontCompactSm(),
                  ),
                  const HorizontalSpace(10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      widget.space.address,
                      style: fontCompactSmBold(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerticalSpace(30),
              SpaceBenefitListWidget(spaceDetailEntity: widget.space),
              const VerticalSpace(30),
            ],
          ),
        ),
      ],
    );
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
                style: fontCompactSm(),
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
              '나에게서 $_distanceInKm' 'km',
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
        return (text: '임시 휴무', color: Colors.red[300]!);
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
        statusText = '영업 중';
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
              statusText = '휴게시간';
              hoursText = '${_formatTime24To12(todayHours.breakEndTime!)} 재오픈';
            } else {
              hoursText = '${_formatTime24To12(todayHours.closeTime!)} 마감';
            }
          } else {
            hoursText = '${_formatTime24To12(todayHours.closeTime!)} 마감';
          }
        }
      } else {
        // Closed
        statusText = '영업 종료';

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
          hoursText = '내일 ${_formatTime24To12(tomorrowHours.openTime!)} 오픈';
        }
      }

      // Combine the texts
      final combinedText = hoursText.isNotEmpty ? '$statusText • $hoursText' : statusText;

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
              '임시 휴무',
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
            statusText = '휴게시간';
            hoursText = '${_formatTime24To12(todayHours.breakEndTime!)} 재오픈';
          } else {
            hoursText = '${_formatTime24To12(todayHours.closeTime!)} 마감';
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
      return '오전 12:$minute';
    } else if (hour < 12) {
      return '오전 $hour:$minute';
    } else if (hour == 12) {
      return '오후 12:$minute';
    } else {
      return '오후 ${hour - 12}:$minute';
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