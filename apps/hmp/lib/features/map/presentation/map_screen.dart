import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  double currentZoom = 12.0;

  bool isLoadingMarkers = false;
  bool markersAdded = false; // 마커 추가 중복 방지
  double currentLatitude = 37.5665; // 서울 시청 기본값
  double currentLongitude = 126.9780;
  
  // 마커와 매장 정보를 매핑하기 위한 맵
  Map<String, dynamic> markerSpaceMap = {};
  
  // 인포카드 관련 상태
  SpaceEntity? selectedSpace;
  bool showInfoCard = false;
  
  // Mapbox 토큰
  static const String mapboxAccessToken = 
      'pk.eyJ1IjoiaXhwbG9yZXIiLCJhIjoiY21hbmRkN24xMHJoNDJscHI2cHg0MndteiJ9.UsGyNkHONIeWgivVmAgGbw';

  PointAnnotationManager? _pointAnnotationManager; // 전역 매니저 선언

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(mapboxAccessToken);
    // 현재 위치 가져오기 및 매장 데이터 로드
    _initializeLocation();
  }

  // 현재 위치 초기화 및 매장 로드
  void _initializeLocation() async {
    try {
      final locationCubit = getIt<EnableLocationCubit>();
      
      print('🌍 Initial location state:');
      print('   📍 LocationCubit lat: ${locationCubit.state.latitude}');
      print('   📍 LocationCubit lng: ${locationCubit.state.longitude}');
      print('   📍 Default lat: $currentLatitude');
      print('   📍 Default lng: $currentLongitude');
      
      // 현재 위치 업데이트
      if (locationCubit.state.latitude != 0 && locationCubit.state.longitude != 0) {
        currentLatitude = locationCubit.state.latitude;
        currentLongitude = locationCubit.state.longitude;
        print('✅ Using location from LocationCubit');
      } else {
        print('⚠️ Using default Seoul location');
      }
      
      print('🎯 Final location for API call: $currentLatitude, $currentLongitude');
      
      // 현재 위치 기준 매장 로드
      await _loadNearbySpaces(currentLatitude, currentLongitude);
    } catch (e) {
      print('Error initializing location: $e');
      // 기본 위치로 매장 로드
      await _loadNearbySpaces(currentLatitude, currentLongitude);
    }
  }

  // 특정 위치 기준 가까운 매장 전체 로드
  Future<void> _loadNearbySpaces(double latitude, double longitude) async {
    final spaceCubit = getIt<SpaceCubit>();
    
    try {
      print('🌍 지도용 전체 매장 로드 시작');
      print('📍 요청 위치: lat=$latitude, lng=$longitude');
      print('🔄 로드 전 매장 수: ${spaceCubit.state.spaceList.length}');
      
      // 기존 데이터 클리어하고 강제로 전체 매장 로드
      print('🧹 기존 매장 데이터 클리어');
      
      // 지도 전용 메서드로 전체 매장 로드 (page=999로 전체 데이터 요청)
      print('🚀 onGetAllSpacesForMap 호출 시작');
      await spaceCubit.onGetAllSpacesForMap(
        latitude: latitude,
        longitude: longitude,
      );
      print('🚀 onGetAllSpacesForMap 호출 완료');
      
      print('✅ 로드 완료 - 총 ${spaceCubit.state.spaceList.length}개 매장');
      print('📊 상태: ${spaceCubit.state.submitStatus}');
      
      if (spaceCubit.state.errorMessage.isNotEmpty) {
        print('⚠️ 오류 메시지: ${spaceCubit.state.errorMessage}');
      }
      
      // 처음 5개 매장의 정보 확인
      for (int i = 0; i < math.min(5, spaceCubit.state.spaceList.length); i++) {
        final space = spaceCubit.state.spaceList[i];
        print('🏪 매장 ${i + 1}: ${space.name}');
        print('   📍 위치: lat=${space.latitude}, lng=${space.longitude}');
        print('   🏷️ 카테고리: ${space.category}');
        print('   🔥 핫: ${space.hot}');
      }
      
    } catch (e) {
      print('❌ 매장 로드 중 오류: $e');
      print('❌ 스택 트레이스: ${StackTrace.current}');
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    
    // 모든 UI 요소 비활성화 (순수 지도만 표시)
    _disableAllMapUI();
    
    // 초기 카메라 위치 설정
    mapboxMap.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(currentLongitude, currentLatitude)),
        zoom: currentZoom,
      ),
    );
    
    // 현재 위치 표시 설정
    _setupLocationDisplay();
  }

  // 모든 맵박스 UI 요소 비활성화
  void _disableAllMapUI() async {
    if (mapboxMap == null) return;
    
    try {
      // 나침반 비활성화
      await mapboxMap!.compass.updateSettings(CompassSettings(enabled: false));
      
      // 스케일바 비활성화
      await mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
      
      // 로고 비활성화
      await mapboxMap!.logo.updateSettings(LogoSettings(enabled: false));
      
      // 어트리뷰션 비활성화
      await mapboxMap!.attribution.updateSettings(AttributionSettings(enabled: false));
      
      print('✅ All map UI elements disabled - pure map view');
    } catch (e) {
      print('❌ Error disabling map UI elements: $e');
    }
  }

  // 현재 위치 표시 설정 (비활성화하고 커스텀 마커 사용)
  void _setupLocationDisplay() async {
    if (mapboxMap == null) return;
    
    try {
      // 기본 위치 표시 비활성화 (마커와 겹치는 문제 해결)
      await mapboxMap!.location.updateSettings(
        LocationComponentSettings(
          enabled: false, // 기본 위치 표시 비활성화
        ),
      );
      
      print('✅ Default location display disabled, using custom marker');
    } catch (e) {
      print('❌ Error setting up location display: $e');
    }
  }

  // 모든 마커(매장+현재위치) 추가
  Future<void> _addAllMarkers(List<SpaceEntity> spaces) async {
    if (mapboxMap == null) return;

    print('🔍 _addAllMarkers 시작 - 총 ${spaces.length}개 매장 데이터 받음');

    // 매니저가 없으면 생성, 있으면 기존 마커 모두 삭제
    _pointAnnotationManager ??= await mapboxMap!.annotations.createPointAnnotationManager();
    await _pointAnnotationManager!.deleteAll();
    print('✅ 기존 마커 모두 삭제 완료');

    // 매장 마커 이미지 먼저 등록
    await _addMarkerImage();

    // 매장 마커들
    List<PointAnnotationOptions> markers = [];
    markerSpaceMap.clear();
    
    int validSpaceCount = 0;
    int invalidSpaceCount = 0;
    
    for (final space in spaces) {
      if (space.latitude != 0 && space.longitude != 0) {
        validSpaceCount++;
        final markerId = '${space.id}_${space.latitude}_${space.longitude}';
        
        // 카테고리에 따른 마커 아이콘 선택
        final markerIcon = _getMarkerIconForCategory(space.category);
        
        markers.add(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(space.longitude, space.latitude)),
            iconImage: markerIcon,
            iconSize: 0.6, // 1.1의 70% = 0.77
          ),
        );
        markerSpaceMap[markerId] = space;
        
        if (validSpaceCount <= 5) {
          print('✅ 마커 추가: ${space.name} (${space.category}) - ${markerIcon}');
          print('   📍 위치: (${space.latitude}, ${space.longitude})');
        }
      } else {
        invalidSpaceCount++;
        if (invalidSpaceCount <= 3) {
          print('⚠️ 위치 정보 없음: ${space.name} (lat=${space.latitude}, lng=${space.longitude})');
        }
      }
    }
    
    print('📊 마커 생성 결과:');
    print('   ✅ 유효한 위치 정보 매장: ${validSpaceCount}개');
    print('   ❌ 위치 정보 없는 매장: ${invalidSpaceCount}개');
    print('   🗺️ 실제 생성할 마커 수: ${markers.length}개');
    
    if (markers.isNotEmpty) {
      await _pointAnnotationManager!.createMulti(markers);
      print('🎉 지도에 ${markers.length}개 매장 마커 추가 완료!');
      print('📍 마커 매핑 정보: ${markerSpaceMap.length}개 저장');
    } else {
      print('❌ 추가할 매장 마커 없음 - 유효한 위치 정보가 있는 매장이 없습니다');
    }

    // 현재 위치 마커 이미지 등록
    await _addCurrentLocationMarkerImage();
    // 현재 위치 마커(항상 마지막에 추가)
    final currentLocationMarker = PointAnnotationOptions(
      geometry: Point(coordinates: Position(currentLongitude, currentLatitude)),
      iconImage: 'current_location_marker',
      iconSize: 0.45, // 현재 위치는 더 크게 (원래 0.4에서 0.6으로 증가)
    );
    await _pointAnnotationManager!.create(currentLocationMarker);
    print('📍 Added current location marker at $currentLatitude, $currentLongitude');
  }

  // 마커 이미지 생성 (제공된 SVG 디자인 기반)
  Future<Uint8List> _createFallbackMarker() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 40.0;
    
    // 파란색 원형 마커
    final paint = Paint()
      ..color = const Color(0xFF00A3FF)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size/2, size/2), size/2 - 2, paint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  // 색상을 지정한 폴백 마커 생성
  Future<Uint8List> _createFallbackMarkerWithColor(Color color) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 32.0;
    
    // 지정된 색상의 원형 마커
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size/2, size/2), size/2 - 2, paint);
    
    // 흰색 테두리 추가
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(Offset(size/2, size/2), size/2 - 2, borderPaint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  // 인포카드 위젯 생성
  Widget _buildInfoCard(SpaceEntity space) {
    return Positioned(
      bottom: 10, // 지도 하단에 딱 붙임
      left: 10,
      right: 10,
      child: AnimatedOpacity(
        opacity: showInfoCard ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () async {
            // 인포카드 클릭 시 상세 화면으로 이동
            final spaceCubit = getIt<SpaceCubit>();
            await spaceCubit.onGetSpaceDetailBySpaceId(spaceId: space.id);
            SpaceDetailScreen.push(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 매장 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      child: space.image.isNotEmpty
                          ? Image.network(
                              space.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[700],
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[700],
                              child: const Icon(
                                Icons.store,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 매장 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 카테고리와 상세보기를 같은 줄에 배치
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 카테고리
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(space.category),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                space.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10, // 12에서 10으로 감소
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                            // 상세보기
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '상세보기',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 매장명
                        Text(
                          space.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pretendard',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // 운영 상태
                        Text(
                          '영업 중',
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 혜택 정보
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: Colors.blue[300],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                space.benefitDescription.isNotEmpty 
                                    ? space.benefitDescription 
                                    : '혜택 정보 없음',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                  fontFamily: 'Pretendard',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 카테고리별 색상 반환
  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'CAFE':
        return const Color(0xFF8B4513);
      case 'MEAL':
        return const Color(0xFFFF6347);
      case 'PUB':
        return const Color(0xFF32CD32);
      case 'MUSIC':
        return const Color(0xFF9370DB);
      case 'BAR':
        return const Color(0xFFFF1493);
      case 'COWORKING':
        return const Color(0xFF4169E1);
      case 'WALKERHILL':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF00A3FF);
    }
  }

  // 카테고리에 따른 마커 아이콘 이름 반환
  String _getMarkerIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'CAFE':
        return 'marker_CAFE';
      case 'MEAL':
        return 'marker_MEAL';
      case 'PUB':
        return 'marker_PUB';
      case 'MUSIC':
        return 'marker_MUSIC';
      case 'BAR':
        return 'marker_BAR';
      case 'COWORKING':
        return 'marker_COWORKING';
      case 'WALKERHILL':
        return 'marker_WALKERHILL';
      case 'ETC':
      default:
        return 'marker_ETC';
    }
  }

  void _onStyleLoadedCallback(StyleLoadedEventData data) {
    print('🗺️ Map style loaded');
    
    // 지도 언어를 한국어로 설정
    _setMapLanguageToKorean();
    
    // 스타일이 로드된 후 전체 매장 데이터 로드
    print('🚀 StyleLoaded: 전체 매장 데이터 로드 시작');
    _loadNearbySpaces(currentLatitude, currentLongitude);
  }

  // 지도 언어를 한국어로 설정
  void _setMapLanguageToKorean() async {
    if (mapboxMap == null) return;
    
    try {
      // 한국어 로케일 설정
      await mapboxMap!.style.setStyleImportConfigProperty(
        'basemap',
        'locale',
        'ko',
      );
      print('✅ Map language set to Korean');
    } catch (e) {
      print('❌ Error setting map language to Korean: $e');
      // 대안 방법: 스타일 레이어의 텍스트 필드 설정
      try {
        // 라벨 레이어들의 언어 설정 시도
        await _updateTextLayersForKorean();
      } catch (e2) {
        print('❌ Alternative language setting also failed: $e2');
      }
    }
  }

  // 텍스트 레이어들을 한국어로 업데이트
  Future<void> _updateTextLayersForKorean() async {
    if (mapboxMap == null) return;
    
    try {
      // 일반적인 라벨 레이어들에 대해 한국어 텍스트 필드 설정
      final commonLabelLayers = [
        'country-label',
        'state-label', 
        'place-city-label',
        'place-town-label',
        'poi-label',
        'road-label',
      ];
      
      for (final layerId in commonLabelLayers) {
        try {
          await mapboxMap!.style.setStyleLayerProperty(
            layerId,
            'text-field',
            ['coalesce', ['get', 'name_ko'], ['get', 'name_kr'], ['get', 'name']],
          );
        } catch (e) {
          // 레이어가 존재하지 않을 수 있으므로 무시
          print('Layer $layerId not found or failed to update: $e');
        }
      }
      
      print('✅ Updated text layers for Korean language');
    } catch (e) {
      print('❌ Error updating text layers: $e');
    }
  }

  void _onMapTapListener(MapContentGestureContext context) async {
    print('Map tapped at: ${context.point}');
    
    // 탭한 위치 근처에 마커가 있는지 확인 (직접 지리 좌표 사용)
    final tappedLat = context.point.coordinates.lat.toDouble();
    final tappedLng = context.point.coordinates.lng.toDouble();
    await _checkMarkerNearGeoCoordinates(tappedLat, tappedLng);
    
    // 지도 중심점 확인 및 매장 재로드
    await _checkAndUpdateLocation();
  }

  // 탭한 위치 근처에 마커가 있는지 확인하고 상세화면으로 이동
  Future<void> _checkMarkerNearGeoCoordinates(double tappedLat, double tappedLng) async {
    print('🔍 Checking markers near tap: $tappedLat, $tappedLng');
    print('📍 Total markers in map: ${markerSpaceMap.length}');
    
    try {
      // 매핑된 매장 정보에서 가까운 마커 찾기
      dynamic tappedSpace;
      double minDistance = double.infinity;
      const tapThreshold = 0.005; // 약 500m 정도의 허용 거리 (더 크게 설정)
      
      for (final entry in markerSpaceMap.entries) {
        final parts = entry.key.split('_');
        if (parts.length >= 3) {
          final markerLat = double.tryParse(parts[1]) ?? 0.0;
          final markerLng = double.tryParse(parts[2]) ?? 0.0;
          
          // 거리 계산 (간단한 유클리드 거리)
          final distance = math.sqrt(
            math.pow(tappedLat - markerLat, 2) + math.pow(tappedLng - markerLng, 2)
          );
          
          print('📏 Distance to ${entry.value.name}: $distance (threshold: $tapThreshold)');
          
          if (distance < tapThreshold && distance < minDistance) {
            minDistance = distance;
            tappedSpace = entry.value;
            print('✅ Found closer marker: ${tappedSpace.name} at distance $distance');
          }
        }
      }
      
      if (tappedSpace != null) {
        print('🎯 Marker tapped! Found space: ${tappedSpace.name}');
        
        // 인포카드 표시
        setState(() {
          selectedSpace = tappedSpace;
          showInfoCard = true;
        });
      } else {
        print('❌ No marker found near tap location');
        // 마커가 아닌 곳을 클릭하면 인포카드 숨김
        if (showInfoCard) {
          setState(() {
            showInfoCard = false;
            selectedSpace = null;
          });
        }
      }
    } catch (e) {
      print('Error checking marker near tap: $e');
    }
  }

  // 현재 지도 중심점 확인 및 필요시 매장 재로드
  Future<void> _checkAndUpdateLocation() async {
    if (mapboxMap == null) return;
    
    try {
      final cameraState = await mapboxMap!.getCameraState();
      final center = cameraState.center;
      
      final newLatitude = center.coordinates.lat.toDouble();
      final newLongitude = center.coordinates.lng.toDouble();
      
      // 이전 위치와 충분히 차이가 날 때만 새로 로드 (약 1km 이상)
      const threshold = 0.01; // 약 1km
      if ((newLatitude - currentLatitude).abs() > threshold ||
          (newLongitude - currentLongitude).abs() > threshold) {
        
        currentLatitude = newLatitude;
        currentLongitude = newLongitude;
        
        print('Map center moved to: $currentLatitude, $currentLongitude');
        
        // 새 위치 기준으로 매장 로드
        await _loadNearbySpaces(currentLatitude, currentLongitude);
      }
    } catch (e) {
      print('Error checking location: $e');
    }
  }

  // 매장 마커들을 지도에 추가 (효율적인 방식 - 매장 목록에서 바로 위치 정보 사용)
  void _addSpaceMarkersEfficiently() async {
    if (mapboxMap == null || isLoadingMarkers) return;

    setState(() {
      isLoadingMarkers = true;
    });

    final spaceCubit = getIt<SpaceCubit>();
    final spaceState = spaceCubit.state;

    try {
      print('🔍 Starting marker creation process...');
      print('📊 Total spaces in state: ${spaceState.spaceList.length}');
      
      // 매장 목록의 첫 번째 몇 개 확인
      for (int i = 0; i < math.min(5, spaceState.spaceList.length); i++) {
        final space = spaceState.spaceList[i];
        print('🏪 Space ${i + 1}: ${space.name} - lat: ${space.latitude}, lng: ${space.longitude}');
      }

      // 포인트 어노테이션 매니저 생성
      final pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
      print('✅ Point annotation manager created');
      
      // 마커 이미지 등록
      await _addMarkerImage();

      List<PointAnnotationOptions> markers = [];
      markerSpaceMap.clear(); // 기존 매핑 클리어

      int validCoordinateCount = 0;
      int invalidCoordinateCount = 0;

      // 매장 목록에서 바로 위치 정보를 가져와서 마커 추가 (API 호출 없음)
      for (final space in spaceState.spaceList) {
        // 위치 정보가 있는 경우에만 마커 추가
        if (space.latitude != 0 && space.longitude != 0) {
          validCoordinateCount++;
          final markerId = '${space.id}_${space.latitude}_${space.longitude}';
          
          markers.add(
            PointAnnotationOptions(
              geometry: Point(coordinates: Position(space.longitude, space.latitude)),
              iconImage: 'blue_tick_marker', // 커스텀 이미지 사용
              iconSize: 1.0, // 아이콘 크기
            ),
          );
          
          // 마커와 매장 정보 매핑 저장
          markerSpaceMap[markerId] = space;
          
          if (validCoordinateCount <= 3) {
            print('✅ Added marker for ${space.name} at ${space.latitude}, ${space.longitude}');
          }
        } else {
          invalidCoordinateCount++;
          if (invalidCoordinateCount <= 3) {
            print('⚠️ No coordinates for ${space.name} (lat: ${space.latitude}, lng: ${space.longitude})');
          }
        }
      }

      print('📍 Valid coordinates: $validCoordinateCount, Invalid: $invalidCoordinateCount');

      // 마커들을 지도에 추가
      if (markers.isNotEmpty) {
        await pointAnnotationManager.createMulti(markers);
        print('🗺️ Added ${markers.length} markers to map efficiently');
        print('📊 Total mapped markers: ${markerSpaceMap.length}');
      } else {
        print('❌ No markers to add - no spaces with valid coordinates found');
        print('🔍 SpaceState details:');
        print('   - Submit status: ${spaceState.submitStatus}');
        print('   - Space list length: ${spaceState.spaceList.length}');
        print('   - Error message: ${spaceState.errorMessage}');
      }
    } catch (e) {
      print('❌ Error adding markers: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    } finally {
      setState(() {
        isLoadingMarkers = false;
      });
    }
  }

  // 매장 마커들을 지도에 추가 (메인 메서드)
  void _addSpaceMarkers() {
    _addSpaceMarkersEfficiently();
  }

  // 카테고리별 마커 이미지들을 지도에 등록
  Future<void> _addMarkerImage() async {
    final categoryMarkers = {
      'CAFE': 'assets/icons/marker_cafe.png',
      'MEAL': 'assets/icons/marker_meal.png',
      'PUB': 'assets/icons/marker_pub.png',
      'MUSIC': 'assets/icons/marker_music.png',
      'BAR': 'assets/icons/marker_bar.png',
      'COWORKING': 'assets/icons/marker_cafe.png', // 카페 아이콘 재사용
      'WALKERHILL': 'assets/icons/marker_cafe.png', // 카페 아이콘 재사용
      'ETC': 'assets/icons/marker_cafe.png', // 기본 카페 아이콘 사용
    };

    try {
      print('🖼️ Android 마커 이미지 로드 시작...');
      
      for (final entry in categoryMarkers.entries) {
        final category = entry.key;
        final assetPath = entry.value;
        
        try {
          print('📱 $category 마커 로드 시도: $assetPath');
          
          // PNG 파일에서 마커 이미지 로드 - Android 호환성 개선
          final ByteData? imageData = await rootBundle.load(assetPath).catchError((error) {
            print('❌ PNG 파일 로드 실패 ($category): $error');
            return null;
          });
          
          if (imageData != null) {
            final Uint8List imageBytes = imageData.buffer.asUint8List();
            
            // 이미지 바이트 검증
            if (imageBytes.isNotEmpty) {
              // PNG 파일을 Flutter Image로 디코딩하여 실제 크기 확인
              final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
              final ui.FrameInfo frameInfo = await codec.getNextFrame();
              final ui.Image image = frameInfo.image;
              
              print('📏 $category 이미지 실제 크기: ${image.width}x${image.height}');
              
              final mbxImage = MbxImage(
                data: imageBytes,
                width: image.width, // 실제 이미지 크기 사용
                height: image.height, // 실제 이미지 크기 사용
              );
              
              await mapboxMap!.style.addStyleImage(
                'marker_$category',
                1.0, // scale
                mbxImage,
                false, // sdf
                [], // stretchX
                [], // stretchY
                null, // content
              );
              
              // 메모리 정리
              image.dispose();
              
              print('✅ $category 마커 이미지 성공적으로 추가됨 (${image.width}x${image.height})');
            } else {
              print('⚠️ $category PNG 파일이 비어있음 - 폴백 사용');
              await _addFallbackMarkerForCategory(category);
            }
          } else {
            print('⚠️ $category PNG 파일 로드 실패 - 폴백 사용');
            await _addFallbackMarkerForCategory(category);
          }
        } catch (e) {
          print('❌ $category 마커 처리 중 오류 발생: $e');
          print('🔄 폴백 마커로 대체 - $category');
          await _addFallbackMarkerForCategory(category);
        }
      }
      
      print('🎉 모든 카테고리 마커 이미지 처리 완료');
    } catch (e) {
      print('❌ 전체 마커 이미지 로드 중 오류: $e');
    }
  }

  // 폴백 마커 생성 (카테고리별 색상)
  Future<void> _addFallbackMarkerForCategory(String category) async {
    try {
      print('🎨 $category용 폴백 마커 생성 중...');
      
      final categoryColors = {
        'CAFE': const Color(0xFF8B4513), // 갈색
        'MEAL': const Color(0xFFFF6347), // 토마토색
        'PUB': const Color(0xFF32CD32),  // 라임그린
        'MUSIC': const Color(0xFF9370DB), // 보라색
        'BAR': const Color(0xFFFF1493),  // 딥핑크
        'COWORKING': const Color(0xFF4169E1), // 로얄블루
        'WALKERHILL': const Color(0xFFFFD700), // 골드
        'ETC': const Color(0xFF00A3FF),  // 기본 파란색
      };

      final color = categoryColors[category] ?? const Color(0xFF00A3FF);
      final Uint8List imageData = await _createFallbackMarkerWithColor(color);
      
      final mbxImage = MbxImage(
        data: imageData,
        width: 32,
        height: 32,
      );
      
      await mapboxMap!.style.addStyleImage(
        'marker_$category',
        1.0,
        mbxImage,
        false,
        [],
        [],
        null,
      );
      
      print('✅ $category 폴백 마커 생성 완료 (색상: ${color.value.toRadixString(16)})');
    } catch (e) {
      print('❌ $category 폴백 마커 생성 중 오류: $e');
    }
  }

  // 마커 이미지 생성 (제공된 SVG 디자인 기반)
  Future<Uint8List> _createMarkerImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 32.0;
    
    // SVG viewBox 0 0 20 21을 32x32로 스케일링
    final scaleX = size / 20.0;
    final scaleY = size / 21.0;
    final scale = math.min(scaleX, scaleY);
    
    canvas.scale(scale);
    
    // 파란색 배경 (별 모양) 그리기
    final backgroundPaint = Paint()
      ..color = const Color(0xFF00A3FF)
      ..style = PaintingStyle.fill;
    
    // SVG path를 Flutter Path로 변환 (별 모양 배경)
    final backgroundPath = Path();
    backgroundPath.moveTo(8.89425, 3.48856);
    backgroundPath.cubicTo(9.48753, 2.83715, 10.5124, 2.83715, 11.1057, 3.48856);
    backgroundPath.lineTo(11.8686, 4.32625);
    backgroundPath.cubicTo(12.1684, 4.65547, 12.5993, 4.83397, 13.0442, 4.81318);
    backgroundPath.lineTo(14.176, 4.76029);
    backgroundPath.cubicTo(15.056, 4.71915, 15.7809, 5.44392, 15.7397, 6.32404);
    backgroundPath.lineTo(15.6868, 7.45581);
    backgroundPath.cubicTo(15.666, 7.90061, 15.8445, 8.33154, 16.1737, 8.63137);
    backgroundPath.lineTo(17.0114, 9.39425);
    backgroundPath.cubicTo(17.6629, 9.98753, 17.6629, 11.0124, 17.0114, 11.6057);
    backgroundPath.lineTo(16.1737, 12.3686);
    backgroundPath.cubicTo(15.8445, 12.6684, 15.666, 13.0993, 15.6868, 13.5442);
    backgroundPath.lineTo(15.7397, 14.676);
    backgroundPath.cubicTo(15.7809, 15.556, 15.056, 16.2809, 14.176, 16.2397);
    backgroundPath.lineTo(13.0442, 16.1868);
    backgroundPath.cubicTo(12.5993, 16.166, 12.1684, 16.3445, 11.8686, 16.6737);
    backgroundPath.lineTo(11.1057, 17.5114);
    backgroundPath.cubicTo(10.5124, 18.1629, 9.48753, 18.1629, 8.89425, 17.5114);
    backgroundPath.lineTo(8.13137, 16.6737);
    backgroundPath.cubicTo(7.83154, 16.3445, 7.40061, 16.166, 6.95581, 16.1868);
    backgroundPath.lineTo(5.82403, 16.2397);
    backgroundPath.cubicTo(4.94392, 16.2809, 4.21915, 15.556, 4.26029, 14.676);
    backgroundPath.lineTo(4.31318, 13.5442);
    backgroundPath.cubicTo(4.33397, 13.0993, 4.15547, 12.6684, 3.82625, 12.3686);
    backgroundPath.lineTo(2.98856, 11.6057);
    backgroundPath.cubicTo(2.33715, 11.0124, 2.33715, 9.98753, 2.98856, 9.39425);
    backgroundPath.lineTo(3.82625, 8.63137);
    backgroundPath.cubicTo(4.15547, 8.33154, 4.33397, 7.90061, 4.31318, 7.45581);
    backgroundPath.lineTo(4.26029, 6.32403);
    backgroundPath.cubicTo(4.21915, 5.44392, 4.94392, 4.71915, 5.82404, 4.76029);
    backgroundPath.lineTo(6.95581, 4.81318);
    backgroundPath.cubicTo(7.40061, 4.83397, 7.83154, 4.65547, 8.13137, 4.32625);
    backgroundPath.close();
    
    canvas.drawPath(backgroundPath, backgroundPaint);
    
    // 흰색 체크마크 그리기
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // 체크마크 path
    final checkPath = Path();
    checkPath.moveTo(12.7376, 8.91304);
    checkPath.cubicTo(12.972, 9.14736, 12.972, 9.52725, 12.7376, 9.76157);
    checkPath.lineTo(10.0376, 12.4616);
    checkPath.cubicTo(9.80333, 12.6959, 9.42343, 12.6959, 9.18912, 12.4616);
    checkPath.lineTo(7.38911, 10.6616);
    checkPath.cubicTo(7.1548, 10.4273, 7.1548, 10.0474, 7.38911, 9.81304);
    checkPath.cubicTo(7.62343, 9.57873, 8.00333, 9.57873, 8.23764, 9.81304);
    checkPath.lineTo(9.61338, 11.1888);
    checkPath.lineTo(11.8891, 8.91304);
    checkPath.cubicTo(12.1234, 8.67873, 12.5033, 8.67873, 12.7376, 8.91304);
    checkPath.close();
    
    canvas.drawPath(checkPath, checkPaint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  // 특정 매장으로 이동
  void _moveToSpace(SpaceDetailEntity space) {
    if (mapboxMap != null && space.latitude != 0 && space.longitude != 0) {
      mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(space.longitude, space.latitude)),
          zoom: 16.0,
        ),
        MapAnimationOptions(duration: 2000),
      );
      currentZoom = 16.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '매장 지도',
          style: TextStyle(fontFamily: 'Pretendard'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              markersAdded = false; // 마커 추가 플래그 리셋
              _loadNearbySpaces(currentLatitude, currentLongitude);
            },
          ),
        ],
      ),
      body: BlocListener<SpaceCubit, SpaceState>(
        bloc: getIt<SpaceCubit>(),
        listener: (context, state) {
          print('🔄 BlocListener triggered - Status: ${state.submitStatus}, Spaces: ${state.spaceList.length}');
          // 데이터가 로드되면 마커 추가 (중복 방지)
          if (state.submitStatus == RequestStatus.success && state.spaceList.isNotEmpty && !markersAdded) {
            print('✅ BlocListener: Adding markers for ${state.spaceList.length} spaces');
            markersAdded = true; // 중복 방지 플래그 설정
            _addAllMarkers(state.spaceList);
          } else if (state.submitStatus == RequestStatus.success && state.spaceList.isEmpty) {
            print('⚠️ BlocListener: Success but no spaces found');
          } else if (state.submitStatus == RequestStatus.failure) {
            print('❌ BlocListener: Failed to load spaces - ${state.errorMessage}');
          }
        },
        child: Stack(
          children: [
            // Mapbox 지도
            MapWidget(
              key: const ValueKey("mapWidget"),
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: _onStyleLoadedCallback,
              onTapListener: _onMapTapListener,
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(126.9780, 37.5665)),
                zoom: currentZoom,
              ),
              styleUri: 'mapbox://styles/ixplorer/cmbhjhxbr00b401sn9glq0y9l', // 커스텀 스타일 적용
            ),

            // 마커 로딩 상태 표시
            if (isLoadingMarkers)
              Positioned(
                top: 100,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(width: 16),
                      Text(
                        '매장 위치 정보를 불러오는 중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 매장 목록 바텀뷰 숨김 (지도 전용 화면)
            // DraggableScrollableSheet 제거됨
            
            // 지도 컨트롤 버튼들 (가장 위에 표시되도록 맨 마지막에 배치)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _moveToCurrentLocation,
                child: Container(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/mlocation.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ),
            ),

            // 인포카드 (선택된 매장이 있을 때만 표시)
            if (showInfoCard && selectedSpace != null)
              _buildInfoCard(selectedSpace!),
          ],
        ),
      ),
    );
  }

  void _moveToCurrentLocation() async {
    try {
      final locationCubit = getIt<EnableLocationCubit>();
      double targetLat = currentLatitude;
      double targetLng = currentLongitude;
      if (locationCubit.state.latitude != 0 && locationCubit.state.longitude != 0) {
        targetLat = locationCubit.state.latitude;
        targetLng = locationCubit.state.longitude;
      }
      mapboxMap?.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(targetLng, targetLat)),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 2000),
      );
      currentZoom = 15.0;
      currentLatitude = targetLat;
      currentLongitude = targetLng;
      markersAdded = false; // 마커 추가 플래그 리셋
      await _loadNearbySpaces(currentLatitude, currentLongitude);
    } catch (e) {
      print('Error moving to current location: $e');
    }
  }

  @override
  void dispose() {
    mapboxMap?.dispose();
    super.dispose();
  }

  // 현재 위치 마커 이미지를 지도에 등록
  Future<void> _addCurrentLocationMarkerImage() async {
    try {
      print('📍 현재 위치 마커 이미지 로드 시작...');
      
      // PNG 파일에서 현재 위치 마커 이미지 로드 - Android 호환성 개선
      final ByteData? imageData = await rootBundle.load('assets/icons/clocation.png').catchError((error) {
        print('❌ 현재 위치 PNG 파일 로드 실패: $error');
        return null;
      });
      
      if (imageData != null) {
        final Uint8List imageBytes = imageData.buffer.asUint8List();
        
        // 이미지 바이트 검증
        if (imageBytes.isNotEmpty) {
          // PNG 파일을 Flutter Image로 디코딩하여 실제 크기 확인
          final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image image = frameInfo.image;
          
          print('📏 현재 위치 이미지 실제 크기: ${image.width}x${image.height}');
          
          final mbxImage = MbxImage(
            data: imageBytes,
            width: image.width, // 실제 이미지 크기 사용
            height: image.height, // 실제 이미지 크기 사용
          );
          
          await mapboxMap!.style.addStyleImage(
            'current_location_marker',
            1.0, // scale
            mbxImage,
            false, // sdf
            [], // stretchX
            [], // stretchY
            null, // content
          );
          
          // 메모리 정리
          image.dispose();
          
          print('✅ 현재 위치 마커 이미지 성공적으로 추가됨 (${image.width}x${image.height})');
        } else {
          print('⚠️ 현재 위치 PNG 파일이 비어있음 - 폴백 사용');
          await _addFallbackCurrentLocationMarker();
        }
      } else {
        print('⚠️ 현재 위치 PNG 파일 로드 실패 - 폴백 사용');
        await _addFallbackCurrentLocationMarker();
      }
    } catch (e) {
      print('❌ 현재 위치 마커 이미지 로드 중 오류: $e');
      // 폴백으로 기본 마커 이미지 생성
      await _addFallbackCurrentLocationMarker();
    }
  }

  // 폴백 현재 위치 마커 이미지 생성
  Future<void> _addFallbackCurrentLocationMarker() async {
    try {
      final Uint8List imageData = await _createCurrentLocationMarker();
      
      final mbxImage = MbxImage(
        data: imageData,
        width: 40,
        height: 40,
      );
      
      await mapboxMap!.style.addStyleImage(
        'current_location_marker',
        1.0,
        mbxImage,
        false,
        [],
        [],
        null,
      );
      
      print('✅ Added fallback current location marker image');
    } catch (e) {
      print('❌ Error adding fallback current location marker: $e');
    }
  }

  // 현재 위치 마커 이미지 생성 (폴백용)
  Future<Uint8List> _createCurrentLocationMarker() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 40.0;
    
    // 흰색 원형 배경
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size/2, size/2), size/2 - 2, backgroundPaint);
    
    // 파란색 위치 아이콘
    final iconPaint = Paint()
      ..color = const Color(0xFF00A3FF)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size/2, size/2), size/3, iconPaint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
}