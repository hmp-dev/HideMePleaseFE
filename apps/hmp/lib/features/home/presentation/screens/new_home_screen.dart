import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/common/presentation/widgets/map_info_card.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/my_profile_screen.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? _currentLocationManager;
  PointAnnotation? _currentLocationAnnotation;
  List<SpaceEntity> nearbySpaces = [];
  List<SpaceEntity> recommendedSpaces = [];
  double currentLatitude = 37.5665;
  double currentLongitude = 126.9780;
  String? profilePartsString;
  
  static const String mapboxAccessToken = 
      'pk.eyJ1IjoiaXhwbG9yZXIiLCJhIjoiY21hbmRkN24xMHJoNDJscHI2cHg0MndteiJ9.UsGyNkHONIeWgivVmAgGbw';

  // 근처 사용자 데이터 (임시)
  final List<Map<String, dynamic>> nearbyUsers = [
    {'name': 'llovek', 'distance': '0.2 km', 'avatar': null},
    {'name': 'daks', 'distance': '0.3 km', 'avatar': null},
    {'name': 'sosw', 'distance': '0.4 km', 'avatar': null},
    {'name': 'findme', 'distance': '1.1 km', 'avatar': null},
    {'name': 'land', 'distance': '3.0 km', 'avatar': null},
    {'name': 'ppel', 'distance': '5.4 km', 'avatar': null},
    {'name': 'reena', 'distance': '7.0 km', 'avatar': null},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    MapboxOptions.setAccessToken(mapboxAccessToken);
    _initializeData();
    _loadProfileParts();
  }
  
  Future<void> _loadProfileParts() async {
    final prefs = await SharedPreferences.getInstance();
    final parts = prefs.getString('profilePartsString');
    if (parts != null && mounted) {
      setState(() {
        profilePartsString = parts;
      });
    }
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation();
    await _loadSpaces();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
      
      // 지도가 이미 생성되었다면 카메라 위치 업데이트
      _updateMapLocation();
    } catch (e) {
      // 위치 가져오기 실패: $e
    }
  }
  
  void _updateMapLocation() {
    if (mapboxMap != null) {
      mapboxMap!.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(currentLongitude, currentLatitude)),
          zoom: 16.0,
          pitch: 0,
        ),
      );
      // 마커도 업데이트
      _addCurrentLocationMarker();
    }
  }

  Future<void> _loadSpaces() async {
    final spaceCubit = getIt<SpaceCubit>();
    await spaceCubit.onFetchAllSpaceViewData();
    
    if (spaceCubit.state.spaceList.isNotEmpty) {
      setState(() {
        nearbySpaces = spaceCubit.state.spaceList.take(3).toList();
        recommendedSpaces = spaceCubit.state.spaceList.skip(3).take(3).toList();
      });
    }
  }

  Future<void> _addCurrentLocationMarkerImage() async {
    try {
      // 간단한 파란색 원형 마커 생성
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = 60.0;
      
      // 외부 원 (흰색 테두리)
      final outerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(size/2, size/2), size/2, outerPaint);
      
      // 내부 원 (파란색)
      final innerPaint = Paint()
        ..color = const Color(0xFF2CB3FF)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(size/2, size/2), size/2 - 4, innerPaint);
      
      // 중앙 점 (흰색)
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(size/2, size/2), 8, centerPaint);
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        await mapboxMap?.style.addStyleImage(
          'current_location_marker',
          1,
          MbxImage(data: byteData.buffer.asUint8List(), width: size.toInt(), height: size.toInt()),
          false,
          [],
          [],
          null,
        );
      }
    } catch (e) {
      print('❌ Failed to add current location marker image: $e');
    }
  }
  
  Future<void> _addCurrentLocationMarker() async {
    if (_currentLocationManager == null || mapboxMap == null) return;
    
    try {
      // 기존 마커가 있으면 삭제
      if (_currentLocationAnnotation != null) {
        await _currentLocationManager!.delete(_currentLocationAnnotation!);
        _currentLocationAnnotation = null;
      }
      
      // 새로운 마커 생성
      final markerOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(currentLongitude, currentLatitude)),
        iconImage: 'current_location_marker',
        iconSize: 0.5,
      );
      
      _currentLocationAnnotation = await _currentLocationManager!.create(markerOptions);
    } catch (e) {
      print('❌ Failed to add current location marker: $e');
    }
  }
  
  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    mapboxMap.gestures.updateSettings(GesturesSettings(
      doubleTapToZoomInEnabled: false,
      quickZoomEnabled: false,
      scrollEnabled: false,
      pitchEnabled: false,
      rotateEnabled: false,
    ));
    
    // 현재 위치 마커 매니저 초기화
    _currentLocationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    // 마커 이미지 등록
    await _addCurrentLocationMarkerImage();
    
    // 현재 위치로 카메라 설정
    _updateMapLocation();
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = getIt<ProfileCubit>();
    final profile = profileCubit.state.userProfileEntity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.10, 0.85, 1.0],
            colors: [
              Color(0x9923B0FF), // #23B0FF99 (상태바 영역)
              Color(0xFFEAF8FF), // 라이트 블루 (메인 배경)
              Colors.white,      // 흰색 (중간)
              Color(0xff23B0FF), // #23B0FF (하단)
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 헤더 섹션
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 사용자 정보
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          // 프로필 아바타
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF132E41), width: 2),
                            ),
                            child: ClipOval(
                              child: (profilePartsString != null && profilePartsString!.isNotEmpty) ||
                                     (profile != null && 
                                      profile.profilePartsString != null && 
                                      profile.profilePartsString!.isNotEmpty)
                                  ? ProfileAvatarWidget(
                                      profilePartsString: profilePartsString ?? profile!.profilePartsString!,
                                      size: 54,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.person, size: 30),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 사용자 이름과 통계
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile != null ? profile.nickName ?? 'User' : 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStatItem(Icons.home, '0'),
                                  const SizedBox(width: 8),
                                  _buildStatItem(Icons.search, '0'),
                                  const SizedBox(width: 8),
                                  _buildStatItem(Icons.location_on, '0'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 알림 버튼
                    Stack(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/icons/ico_bell.png',
                            width: 28,
                            height: 28,
                          ),
                          iconSize: 28,
                          onPressed: () {},
                        ),
                        if (false) ...[
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),

              // 환영 메시지
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Welcome! Hide Here!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 지도 프리뷰 섹션
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFF132E41), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      MapWidget(
                        onMapCreated: _onMapCreated,
                        styleUri: 'mapbox://styles/ixplorer/cmf3a35jy00u501rkdf9k9lme',
                      ),
                      // 지도 위 오버레이 (선택적)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /*const SizedBox(height: 20),

              // 근처 사용자 슬라이더
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: nearbyUsers.length,
                  itemBuilder: (context, index) {
                    final user = nearbyUsers[index];
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 4),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: index < 3 ? const Color(0xFF00A3FF) : const Color(0xFFFF00FF),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['name'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user['distance'],
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFF00A3FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              */
              const SizedBox(height: 24),

              // NEW! 새로 숨을 곳이 생겼어! 섹션
              _buildSpaceSection(
                title: LocaleKeys.new_hiding_places.tr(),
                spaces: nearbySpaces,
                showCategoryTag: true,
              ),

              const SizedBox(height: 24),

              // 근처 이런 곳에 숨어봐! 섹션
              _buildSpaceSection(
                title: LocaleKeys.nearby_hiding_places.tr(),
                spaces: recommendedSpaces,
                showCategoryTag: false,
              ),

              const SizedBox(height: 130), // 바텀바 공간
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceSection({
    required String title,
    required List<SpaceEntity> spaces,
    bool showCategoryTag = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: spaces.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.loading_nearby_spaces.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: spaces.length,
                  itemBuilder: (context, index) {
                    final space = spaces[index];
                    return Container(
                      width: MediaQuery.of(context).size.width - 40, // 화면 너비 - 좌우 패딩
                      margin: const EdgeInsets.only(right: 12),
                      child: MapInfoCard(
                        space: space,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}