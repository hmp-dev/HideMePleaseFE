import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/common/presentation/widgets/map_info_card.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/my_profile_screen.dart';
import 'package:http/http.dart' as http;
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
  PointAnnotationManager? _spaceMarkerManager;
  List<PointAnnotation> _spaceMarkers = [];
  List<SpaceEntity> nearbySpaces = [];
  List<SpaceEntity> recommendedSpaces = [];
  List<SpaceEntity> allSpaces = [];
  double currentLatitude = 37.5665;
  double currentLongitude = 126.9780;
  String? profilePartsString;
  bool _isUsingProfileImage = false; // 프로필 이미지 사용 여부 추적
  static const double NEARBY_RADIUS_KM = 5.0; // 5km 반경
  
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
      // 새 위치 기준으로 매장 마커 업데이트
      if (allSpaces.isNotEmpty) {
        _addSpaceMarkers();
      }
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
        allSpaces = spaceCubit.state.spaceList;
        nearbySpaces = spaceCubit.state.spaceList.take(3).toList();
        recommendedSpaces = spaceCubit.state.spaceList.skip(3).take(3).toList();
      });
      // 매장 마커 추가
      _addSpaceMarkers();
    }
  }

  // 5km 이내 매장 필터링
  List<SpaceEntity> _filterNearbySpaces() {
    return allSpaces.where((space) {
      if (space.latitude == null || space.longitude == null) return false;
      
      final distance = calculateDistanceInMeters(
        currentLatitude,
        currentLongitude,
        space.latitude!,
        space.longitude!,
      );
      
      return distance <= (NEARBY_RADIUS_KM * 1000); // 5km = 5000m
    }).toList();
  }
  
  // 매장 카테고리별 PNG 아이콘 이미지 등록
  Future<void> _addSpaceMarkerImages() async {
    try {
      // 카테고리별 PNG 아이콘 파일 경로 (맵스크린과 동일)
      final categoryIcons = {
        'CAFE': 'assets/icons/marker_cafe.png',
        'MEAL': 'assets/icons/marker_meal.png',
        'BAKERY': 'assets/icons/marker_bakery.png',
        'PUB': 'assets/icons/marker_pub.png',
        'BAR': 'assets/icons/marker_bar.png',
        'ETC': 'assets/icons/marker_etc.png',
      };
      
      for (final entry in categoryIcons.entries) {
        try {
          print('🔍 [HomeScreen] Loading marker PNG: ${entry.value}');
          final ByteData data = await rootBundle.load(entry.value);
          print('✅ [HomeScreen] Successfully loaded PNG for ${entry.key}: ${data.lengthInBytes} bytes');
          
          await mapboxMap?.style.addStyleImage(
            'marker_${entry.key}',
            1,
            MbxImage(
              data: data.buffer.asUint8List(),
              width: 32,
              height: 32,
            ),
            false,
            [],
            [],
            null,
          );
          print('✅ [HomeScreen] Added style image for marker_${entry.key}');
        } catch (e) {
          // PNG 파일이 없으면 기본 마커 생성
          print('⚠️ [HomeScreen] PNG file not found for ${entry.key}: ${entry.value}, error: $e');
          print('🔄 [HomeScreen] Creating default marker for ${entry.key}');
          final markerData = await _createDefaultMarkerImage(_getCategoryColor(entry.key));
          await mapboxMap?.style.addStyleImage(
            'marker_${entry.key}',
            1,
            MbxImage(data: markerData, width: 32, height: 32),
            false,
            [],
            [],
            null,
          );
        }
      }
    } catch (e) {
      print('❌ Failed to add space marker images: $e');
    }
  }
  
  // 카테고리별 색상 가져오기
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'CAFE':
        return const Color(0xFF8B4513); // 갈색
      case 'MEAL':
        return const Color(0xFFFF6347); // 토마토색
      case 'BAKERY':
        return const Color(0xFFFFA500); // 오렌지
      case 'PUB':
        return const Color(0xFF32CD32); // 라임그린
      case 'BAR':
        return const Color(0xFFFF1493); // 딥핑크
      default:
        return const Color(0xFF00A3FF); // 기본 파란색
    }
  }
  
  // 기본 원형 마커 이미지 생성 (PNG가 없을 때 대체용)
  Future<Uint8List> _createDefaultMarkerImage(Color backgroundColor) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 32.0;
    const center = Offset(size / 2, size / 2);
    const radius = size / 2;
    
    // 외부 원 (검은색 테두리)
    final borderPaint = Paint()
      ..color = const Color(0xFF132E41)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, borderPaint);
    
    // 내부 원 (카테고리 색상)
    final innerPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, innerPaint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
  
  // 프로필 이미지를 URL에서 로드하여 Uint8List로 변환
  Future<Uint8List?> _loadProfileImageFromUrl(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        print('⚠️ [HomeScreen] Profile image URL is empty');
        return null;
      }

      print('📥 [HomeScreen] Loading profile image from: $imageUrl');
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        print('✅ [HomeScreen] Profile image loaded successfully');
        return response.bodyBytes;
      } else {
        print('❌ [HomeScreen] Failed to load profile image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ [HomeScreen] Error loading profile image: $e');
      return null;
    }
  }
  
  // 프로필 이미지를 원형으로 마스킹하고 테두리 추가
  Future<Uint8List> _createCircularProfileMarker(Uint8List imageBytes) async {
    try {
      // 원본 이미지 디코딩
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // 마커 크기 설정 - 더 큰 크기로 설정하여 품질 향상
      const size = 80.0; // 40에서 80으로 증가하여 이미지 품질 개선
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 흰색 배경 원 그리기
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, backgroundPaint);

      // 클리핑 패스 설정 (원형)
      final path = Path()
        ..addOval(Rect.fromLTWH(3, 3, size - 6, size - 6));
      canvas.clipPath(path);

      // 프로필 이미지를 원형 영역에 맞게 그리기
      final srcRect = Rect.fromLTWH(
        0, 
        0, 
        originalImage.width.toDouble(), 
        originalImage.height.toDouble()
      );
      final dstRect = Rect.fromLTWH(3, 3, size - 6, size - 6);
      
      // 안티앨리어싱을 위한 Paint 설정
      final imagePaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;
      
      canvas.drawImageRect(originalImage, srcRect, dstRect, imagePaint);

      // 흰색 테두리 그리기
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..isAntiAlias = true;
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 3, borderPaint);

      // 이미지 생성
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      // 리소스 정리
      originalImage.dispose();
      
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print('❌ [HomeScreen] Error creating circular profile marker: $e');
      rethrow;
    }
  }
  
  // 현재 위치 마커를 프로필 이미지로 업데이트
  Future<void> refreshCurrentLocationMarker() async {
    try {
      print('🔄 [HomeScreen] 현재 위치 마커 새로고침 중...');
      
      // 플래그 초기화
      _isUsingProfileImage = false;
      
      // 기존 마커 이미지 제거
      await mapboxMap?.style.removeStyleImage('current_location_marker');
      
      // 새로운 마커 이미지 추가
      await _addCurrentLocationMarkerImage();
      
      // 현재 위치 마커 다시 그리기
      if (_currentLocationAnnotation != null && _currentLocationManager != null) {
        await _currentLocationManager!.delete(_currentLocationAnnotation!);
        _currentLocationAnnotation = null;
        await _addCurrentLocationMarker();
      }
      
      print('✅ [HomeScreen] 현재 위치 마커 새로고침 완료');
    } catch (e) {
      print('❌ [HomeScreen] 현재 위치 마커 새로고침 실패: $e');
    }
  }
  
  // 매장 마커 추가
  Future<void> _addSpaceMarkers() async {
    if (_spaceMarkerManager == null || mapboxMap == null) return;
    
    try {
      // 기존 마커들 삭제
      for (final marker in _spaceMarkers) {
        await _spaceMarkerManager!.delete(marker);
      }
      _spaceMarkers.clear();
      
      // 5km 이내 매장들만 필터링
      final nearbySpaces = _filterNearbySpaces();
      
      // 새로운 마커들 생성
      for (final space in nearbySpaces) {
        if (space.latitude == null || space.longitude == null) continue;
        
        final category = space.category?.toUpperCase() ?? 'ETC';
        print('🏪 [HomeScreen] Creating marker for space: ${space.name}, category: $category');
        
        final markerOptions = PointAnnotationOptions(
          geometry: Point(coordinates: Position(space.longitude!, space.latitude!)),
          iconImage: 'marker_$category',
          iconSize: 0.5,
        );
        
        final marker = await _spaceMarkerManager!.create(markerOptions);
        _spaceMarkers.add(marker);
        print('✅ [HomeScreen] Created marker for ${space.name} at (${space.latitude}, ${space.longitude})');
      }
      
      print('✅ Added ${_spaceMarkers.length} space markers within 5km');
    } catch (e) {
      print('❌ Failed to add space markers: $e');
    }
  }
  
  Future<void> _addCurrentLocationMarkerImage() async {
    try {
      print('📍 [HomeScreen] 현재 위치 마커 이미지 로드 시작...');
      
      // 먼저 프로필 이미지를 시도
      try {
        final profileCubit = getIt<ProfileCubit>();
        print('🔍 [HomeScreen] ProfileCubit 상태 확인...');
        print('📊 [HomeScreen] ProfileCubit state: ${profileCubit.state}');
        print('👤 [HomeScreen] User profile: ${profileCubit.state.userProfileEntity}');
        
        // ProfileCubit이 초기화되지 않았으면 초기화 시도
        if (profileCubit.state.userProfileEntity.id.isEmpty) {
          print('⚠️ [HomeScreen] ProfileCubit이 아직 초기화되지 않음, init() 호출 시도...');
          await profileCubit.init();
          await Future.delayed(const Duration(milliseconds: 500)); // 초기화 대기
        }
        
        // 사용자 ID를 확인하여 API를 통한 이미지 로드 (우선순위 1)
        final userId = profileCubit.state.userProfileEntity.id;
        print('👤 [HomeScreen] User ID: ${userId.isNotEmpty ? userId : "ID가 비어있음"}');
        
        if (userId.isNotEmpty) {
          // API를 통해 고품질 프로필 이미지 로드
          final apiImageUrl = 'http://dev-api.hidemeplease.xyz/v1/public/nft/user/$userId/image';
          print('🌐 [HomeScreen] API 프로필 이미지 URL: $apiImageUrl');
          
          try {
            final profileImageBytes = await _loadProfileImageFromUrl(apiImageUrl);
            
            if (profileImageBytes != null) {
              // 프로필 이미지를 원형 마커로 변환
              final circularMarkerBytes = await _createCircularProfileMarker(profileImageBytes);
              
              // 이미지 크기 확인
              final ui.Codec codec = await ui.instantiateImageCodec(circularMarkerBytes);
              final ui.FrameInfo frameInfo = await codec.getNextFrame();
              final ui.Image image = frameInfo.image;
              
              print('📏 [HomeScreen] API 프로필 마커 크기: ${image.width}x${image.height}');
              
              final mbxImage = MbxImage(
                data: circularMarkerBytes,
                width: image.width,
                height: image.height,
              );
              
              await mapboxMap?.style.addStyleImage(
                'current_location_marker',
                1,
                mbxImage,
                false,
                [],
                [],
                null,
              );
              
              image.dispose();
              print('✅ [HomeScreen] API 프로필 이미지 마커 성공적으로 추가됨');
              _isUsingProfileImage = true; // 프로필 이미지 사용 플래그 설정
              return; // 성공적으로 프로필 이미지를 추가했으므로 종료
            }
          } catch (e) {
            print('⚠️ [HomeScreen] API 프로필 이미지 로드 실패: $e');
          }
        }
        
        // profilePartsString이 없으면 URL 기반 이미지 시도 (우선순위 2)
        final profileImageUrl = profileCubit.state.userProfileEntity.finalProfileImageUrl;
        print('🖼️ [HomeScreen] Profile image URL: ${profileImageUrl.isNotEmpty ? profileImageUrl : "URL이 비어있음"}');
        
        if (profileImageUrl.isNotEmpty) {
          print('👤 [HomeScreen] 프로필 이미지 URL 발견: $profileImageUrl');
          final profileImageBytes = await _loadProfileImageFromUrl(profileImageUrl);
          
          if (profileImageBytes != null) {
            // 프로필 이미지를 원형 마커로 변환
            final circularMarkerBytes = await _createCircularProfileMarker(profileImageBytes);
            
            // 이미지 크기 확인
            final ui.Codec codec = await ui.instantiateImageCodec(circularMarkerBytes);
            final ui.FrameInfo frameInfo = await codec.getNextFrame();
            final ui.Image image = frameInfo.image;
            
            print('📏 [HomeScreen] 프로필 마커 크기: ${image.width}x${image.height}');
            
            final mbxImage = MbxImage(
              data: circularMarkerBytes,
              width: image.width,
              height: image.height,
            );
            
            await mapboxMap?.style.addStyleImage(
              'current_location_marker',
              1,
              mbxImage,
              false,
              [],
              [],
              null,
            );
            
            image.dispose();
            print('✅ [HomeScreen] 프로필 이미지 마커 성공적으로 추가됨');
            _isUsingProfileImage = true; // 프로필 이미지 사용 플래그 설정
            return; // 성공적으로 프로필 이미지를 추가했으므로 종료
          }
        }
      } catch (e) {
        print('⚠️ [HomeScreen] 프로필 이미지 로드 실패, 기본 마커 사용: $e');
      }
      
      // 프로필 이미지가 없거나 실패한 경우 기본 마커 사용
      _isUsingProfileImage = false; // 기본 마커 사용 플래그 설정
      print('🔄 [HomeScreen] 기본 파란색 원형 마커 생성 중...');
      
      // 간단한 파란색 원형 마커 생성
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = 80.0; // 60에서 80으로 크기 증가
      
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
        print('✅ [HomeScreen] 기본 현재 위치 마커 성공적으로 추가됨');
      }
    } catch (e) {
      print('❌ [HomeScreen] Failed to add current location marker image: $e');
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
      
      // 마커 타입에 따라 iconSize 조정
      // 80x80 이미지를 40x40 크기로 표시하기 위해 0.5 스케일 사용
      final double markerIconSize = _isUsingProfileImage ? 0.5 : 0.45;
      print('🎯 [HomeScreen] 마커 iconSize 설정: ${_isUsingProfileImage ? "프로필 이미지" : "기본 마커"} - $markerIconSize');
      
      // 새로운 마커 생성
      final markerOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(currentLongitude, currentLatitude)),
        iconImage: 'current_location_marker',
        iconSize: markerIconSize,
      );
      
      _currentLocationAnnotation = await _currentLocationManager!.create(markerOptions);
      print('✅ [HomeScreen] 현재 위치 마커 업데이트 완료: $currentLatitude, $currentLongitude');
    } catch (e) {
      print('❌ [HomeScreen] Failed to add current location marker: $e');
    }
  }
  
  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    mapboxMap.attribution.updateSettings(AttributionSettings(enabled: false));
    mapboxMap.gestures.updateSettings(GesturesSettings(
      doubleTapToZoomInEnabled: false,
      quickZoomEnabled: false,
      scrollEnabled: false,
      pitchEnabled: false,
      rotateEnabled: false,
    ));
    
    // 매장 마커 매니저 초기화 (먼저 생성)
    _spaceMarkerManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    // 현재 위치 마커 매니저 초기화 (나중에 생성하여 위에 표시)
    _currentLocationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    // 마커 이미지 등록
    await _addSpaceMarkerImages();
    await _addCurrentLocationMarkerImage();
    
    // 현재 위치로 카메라 설정
    _updateMapLocation();
    
    // 매장 마커 추가
    if (allSpaces.isNotEmpty) {
      _addSpaceMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = getIt<ProfileCubit>();
    final profile = profileCubit.state.userProfileEntity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 그라데이션 배경 (전체 화면)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.15, 0.85, 1.0],
                colors: [
                  Color(0x9923B0FF), // #23B0FF99 (상태바 영역)
                  Color(0xFFEAF8FF), // 라이트 블루 (메인 배경)
                  Color(0xFFEAF8FF),      // 흰색 (중간)
                  Color(0xff23B0FF), // #23B0FF (하단)
                ],
              ),
            ),
          ),
          // 컨텐츠
          SingleChildScrollView(
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
                                  fontFamily: 'LINESeedKR',
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStatItem('assets/icons/icon_home_friends.png', '0'),
                                  const SizedBox(width: 8),
                                  _buildStatItem('assets/icons/icon_home_checkin.png', '0'),
                                  const SizedBox(width: 8),
                                  _buildStatItem('assets/icons/icon_home_sav.png', '0'),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF132E41).withOpacity(0.9),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 지도 프리뷰 섹션
              Container(
                height: 120,
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

              SizedBox(height: MediaQuery.of(context).padding.bottom + 100), // 바텀바 공간
            ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String iconPath, String value) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 14,
          height: 14,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontFamily: 'LINESeedKR',
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF132E41),
              fontFamily: 'LINESeedKR',
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: spaces.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.loading_nearby_spaces.tr(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'LINESeedKR',
                    ),
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