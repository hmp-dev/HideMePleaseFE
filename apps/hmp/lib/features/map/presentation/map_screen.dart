import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';
import 'package:mobile/features/space/presentation/cubit/event_category_cubit.dart';
import 'package:mobile/features/map/domain/entities/unified_category_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/app/theme/theme.dart';

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
  bool isMapInitialized = false; // 지도 초기화 완료 상태
  bool isMapStyleLoaded = false; // 지도 스타일 로드 완료 상태
  double currentLatitude = 37.5665; // 서울 시청 기본값
  double currentLongitude = 126.9780;
  double userActualLatitude = 37.5665; // 사용자의 실제 현재 위치
  double userActualLongitude = 126.9780;
  
  // 마커와 매장 정보를 매핑하기 위한 맵
  Map<String, dynamic> markerSpaceMap = {};
  
  // 인포카드 관련 상태
  SpaceEntity? selectedSpace;
  bool showInfoCard = false;

  // 카테고리 필터링 관련 상태
  UnifiedCategoryEntity? selectedCategory; // 통합 카테고리 선택
  List<SpaceEntity> allSpaces = []; // 모든 매장 데이터 저장
  List<SpaceEntity> filteredSpaces = []; // 필터된 매장 데이터
  List<UnifiedCategoryEntity> unifiedCategories = []; // 통합 카테고리 리스트
  
  
  // 검색 관련 상태
  bool showSearchOverlay = false;
  TextEditingController searchController = TextEditingController();
  List<String> searchHistory = [];
  List<SpaceEntity> searchResults = [];
  bool isSearching = false;
  
  // Mapbox 토큰
  static const String mapboxAccessToken = 
      'pk.eyJ1IjoiaXhwbG9yZXIiLCJhIjoiY21hbmRkN24xMHJoNDJscHI2cHg0MndteiJ9.UsGyNkHONIeWgivVmAgGbw';

  PointAnnotationManager? _pointAnnotationManager; // 전역 매니저 선언
  
  // 실시간 위치 추적 관련
  StreamSubscription<geo.Position>? _positionSubscription;
  PointAnnotation? _currentLocationAnnotation; // 현재 위치 마커 참조
  bool _isTrackingLocation = false;
  DateTime? _lastLocationUpdate;
  
  // 토스트 중복 방지를 위한 플래그
  bool _isShowingZoomToast = false;
  
  // 카테고리 스크롤 컨트롤러
  ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 EVENT CATEGORY: MapScreen initState START 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
    print('🚨🚨🚨 EVENT CATEGORY: MapScreen initState called at ${DateTime.now()}');
    MapboxOptions.setAccessToken(mapboxAccessToken);
    // 토스트 플래그 초기화
    _isShowingZoomToast = false;
    // 현재 위치 가져오기 및 매장 데이터 로드
    _initializeLocation();
    // 검색 기록 로드
    _loadSearchHistory();
    // 통합 카테고리 초기화
    _initializeUnifiedCategories();
    // 이벤트 카테고리 로드
    print('🚨🚨🚨 EVENT CATEGORY: About to call _loadEventCategories()');
    _loadEventCategories();
    print('🚨🚨🚨 EVENT CATEGORY: _loadEventCategories() call completed');
    // 실시간 위치 추적은 지도 초기화 후 시작
    print('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 EVENT CATEGORY: MapScreen initState END 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
  }

  // 검색 기록 로드 (SharedPreferences에서)
  Future<void> _loadSearchHistory() async {
    try {
      // TODO: SharedPreferences에서 검색 기록 로드
      // 지금은 샘플 데이터로 대체 (최대 10개)
      searchHistory = [
        '하이드미플리즈 홍제',
        '하이드미플리즈 을지로',
      ];
      print('📱 검색 기록 로드 완료: ${searchHistory.length}개 (최대 10개)');
    } catch (e) {
      print('❌ 검색 기록 로드 실패: $e');
    }
  }

  // 통합 카테고리 초기화
  void _initializeUnifiedCategories() {
    // 매장 카테고리들을 통합 카테고리로 변환
    unifiedCategories = [
      UnifiedCategoryEntity.fromSpaceCategory(
        SpaceCategory.ENTIRE,
        LocaleKeys.entire.tr(),
        "assets/icons/icon_cate_all.png",
      ),
      UnifiedCategoryEntity.fromSpaceCategory(
        SpaceCategory.MEAL,
        LocaleKeys.meal.tr(),
        "assets/icons/icon_cate_food.png",
      ),
      UnifiedCategoryEntity.fromSpaceCategory(
        SpaceCategory.CAFE,
        LocaleKeys.cafe.tr(),
        "assets/icons/icon_cate_cafe.png",
      ),
      UnifiedCategoryEntity.fromSpaceCategory(
        SpaceCategory.PUB,
        LocaleKeys.pub.tr(),
        "assets/icons/icon_cate_beer.png",
      ),
      UnifiedCategoryEntity.fromSpaceCategory(
        SpaceCategory.MUSIC,
        LocaleKeys.music.tr(),
        "assets/icons/ic_space_category_music.svg",
      ),
      UnifiedCategoryEntity.fromSpaceCategory(
        SpaceCategory.ETC,
        "기타",
        "assets/icons/icon_cate_etc.png",
      ),
    ];
    
    // 기본값으로 전체 선택
    selectedCategory = unifiedCategories.first;
  }
  
  // 이벤트 카테고리 로드
  Future<void> _loadEventCategories() async {
    try {
      print('🚨🚨🚨 EVENT CATEGORY: Starting to load event categories...');
      print('🚨🚨🚨 EVENT CATEGORY: mounted = $mounted');
      
      // 먼저 getIt에서 가져올 수 있는지 확인
      final eventCategoryCubit = getIt<EventCategoryCubit>();
      print('🚨🚨🚨 EVENT CATEGORY: Got EventCategoryCubit from getIt: $eventCategoryCubit');
      
      // 현재 상태 확인
      final initialState = eventCategoryCubit.state;
      print('🚨🚨🚨 EVENT CATEGORY: Initial state - status: ${initialState.submitStatus}, categories: ${initialState.eventCategories.length}, isDataLoaded: ${initialState.isDataLoaded}');
      
      // 이미 데이터가 로드되어 있으면 스킵
      if (initialState.isDataLoaded && initialState.eventCategories.isNotEmpty) {
        print('🚨🚨🚨 EVENT CATEGORY: Data already loaded, skipping API call');
        _updateUnifiedCategoriesWithEvents(initialState.eventCategories);
        return;
      }
      
      // API 호출
      print('🚨🚨🚨 EVENT CATEGORY: Calling loadEventCategories...');
      await eventCategoryCubit.loadEventCategories(includeInactive: true);
      print('🚨🚨🚨 EVENT CATEGORY: Load completed');
      
      // 상태 확인
      final state = eventCategoryCubit.state;
      print('🚨🚨🚨 EVENT CATEGORY STATE AFTER LOAD: ${state.submitStatus}, categories count: ${state.eventCategories.length}');
      if (state.errorMessage != null) {
        print('🚨🚨🚨 EVENT CATEGORY ERROR MESSAGE: ${state.errorMessage}');
      }
      
      // 이벤트 카테고리를 통합 카테고리에 추가
      if (state.eventCategories.isNotEmpty) {
        _updateUnifiedCategoriesWithEvents(state.eventCategories);
      }
    } catch (e, stackTrace) {
      print('🚨🚨🚨 EVENT CATEGORY EXCEPTION: $e');
      print('🚨🚨🚨 EVENT CATEGORY EXCEPTION TYPE: ${e.runtimeType}');
      print('🚨🚨🚨 Stack trace: $stackTrace');
    }
  }

  // 이벤트 카테고리를 통합 카테고리 리스트에 추가
  void _updateUnifiedCategoriesWithEvents(List<EventCategoryEntity> eventCategories) {
    setState(() {
      // 기존 매장 카테고리만 유지 (이벤트 카테고리 제거)
      final spaceCategories = unifiedCategories.where((cat) => cat.type == CategoryType.space).toList();
      
      // 이벤트 카테고리를 통합 카테고리로 변환
      final eventUnifiedCategories = eventCategories.map((eventCat) => 
        UnifiedCategoryEntity.fromEventCategory(eventCat)
      ).toList();
      
      // 전체 버튼 + 이벤트 카테고리 + 나머지 매장 카테고리 순서로 재구성
      unifiedCategories = [
        spaceCategories.first, // 전체 버튼
        ...eventUnifiedCategories, // 이벤트 카테고리들
        ...spaceCategories.skip(1), // 나머지 매장 카테고리들
      ];
    });
  }

  // 현재 위치 초기화 (데이터 로드는 지도 준비 후)
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
        userActualLatitude = locationCubit.state.latitude;
        userActualLongitude = locationCubit.state.longitude;
        print('✅ Using location from LocationCubit');
      } else {
        print('⚠️ Using default Seoul location');
      }
      
      print('🎯 Final location for API call: $currentLatitude, $currentLongitude');
      print('📍 Location initialized - waiting for map to be ready...');
      
    } catch (e) {
      print('Error initializing location: $e');
      // 기본 위치 사용
      print('⚠️ Using default Seoul location due to error');
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
      
      // 마커 추가 플래그 리셋 (새로운 데이터 로드 시)
      markersAdded = false;
      
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
      
      // 모든 매장 데이터 저장
      allSpaces = List<SpaceEntity>.from(spaceCubit.state.spaceList);
      
      // 영업시간 데이터 확인 (디버그)
      print('🏪 영업시간 데이터 확인:');
      for (int i = 0; i < math.min(3, allSpaces.length); i++) {
        final space = allSpaces[i];
        print('  📍 ${space.name}:');
        print('     - 영업시간 수: ${space.businessHours.length}개');
        print('     - 임시 휴무: ${space.isTemporarilyClosed}');
        if (space.businessHours.isNotEmpty) {
          for (final hours in space.businessHours) {
            print('     - ${hours.dayOfWeek}: ${hours.openTime} ~ ${hours.closeTime}');
          }
        }
      }
      
      // 하이드미플리즈 홍제 찾기
      final hongjeSpace = allSpaces.firstWhere(
        (space) => space.name.contains('홍제'),
        orElse: () => SpaceEntity.empty(),
      );
      if (hongjeSpace.id.isNotEmpty) {
        print('🎯 하이드미플리즈 홍제 찾음:');
        print('   - 이름: ${hongjeSpace.name}');
        print('   - 영업시간 수: ${hongjeSpace.businessHours.length}개');
        print('   - 임시 휴무: ${hongjeSpace.isTemporarilyClosed}');
      }
      
      // 현재 선택된 카테고리에 따라 필터링
      _filterSpacesByUnifiedCategory(selectedCategory);
      
      // 데이터 로드 완료 후 바로 마커 추가 (BlocListener 대신)
      if (spaceCubit.state.submitStatus == RequestStatus.success && filteredSpaces.isNotEmpty) {
        print('🗺️ 데이터 로드 완료 - 필터된 ${filteredSpaces.length}개 매장으로 마커 추가');
        markersAdded = true;
        await _addAllMarkers(filteredSpaces);
        
        // 초기 현재 위치 마커 추가
        print('📍 초기 현재 위치 마커 추가 시도: $userActualLatitude, $userActualLongitude');
        await _updateCurrentLocationMarker(userActualLatitude, userActualLongitude);
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

  void _onMapCreated(MapboxMap mapboxMap) async {
    print('🗺️ Map created - initializing...');
    this.mapboxMap = mapboxMap;
    
    try {
      // 즉시 카메라 위치 설정하여 지도를 바로 표시
      await mapboxMap.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(currentLongitude, currentLatitude)),
          zoom: currentZoom,
        ),
      );
      print('📍 Initial camera position set immediately');
      
      // Android에서 강제 렌더링 트리거
      if (Platform.isAndroid) {
        // 약간의 지연 후 다시 카메라 설정하여 렌더링 강제
        await Future.delayed(const Duration(milliseconds: 100));
        await mapboxMap.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(currentLongitude, currentLatitude)),
            zoom: currentZoom,
          ),
        );
        print('🤖 Android: Force render triggered');
      }
      
      // 지도 초기화 완료 표시
      setState(() {
        isMapInitialized = true;
      });
      
      print('✅ Map initialized successfully');
    } catch (e) {
      print('❌ Error in map creation: $e');
      // 에러가 있어도 기본 초기화는 진행
      setState(() {
        isMapInitialized = true;
      });
    }
  }

  // 지도 초기화 완료 처리 (데이터 로드)
  void _completeMapInitialization() async {
    if (mapboxMap == null) return;
    
    print('🎯 Starting data load immediately...');
    
    try {
      if (allSpaces.isEmpty) {
        print('🚀 Loading spaces data...');
        await _loadNearbySpaces(currentLatitude, currentLongitude);
      } else {
        print('🚀 Using existing data for markers...');
        // 현재 필터 상태에 따라 적절한 필터링 수행
        print('📂 Applying unified category filter');
        _filterSpacesByUnifiedCategory(selectedCategory);
        
        if (!markersAdded) {
          markersAdded = true;
          await _addAllMarkers(filteredSpaces);
        }
      }
      print('✅ Map data loading completed');
    } catch (e) {
      print('❌ Error in map initialization: $e');
    }
  }

  // 모든 맵박스 UI 요소 비활성화
  Future<void> _disableAllMapUI() async {
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
  Future<void> _setupLocationDisplay() async {
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
    _currentLocationAnnotation = null; // 현재 위치 마커 참조 초기화
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
    // 현재 위치 마커 추가 (실시간 추적 시스템 사용)
    await _updateCurrentLocationMarker(userActualLatitude, userActualLongitude);
    print('📍 Added initial current location marker at $userActualLatitude, $userActualLongitude');
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
      //bottom: 0,
      bottom: showInfoCard && selectedSpace != null ? 110 : -200, // 인포카드 선택 시 70, 아니면 -200 (숨김)
      left: 0,
      right: 0,
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
              color: const Color(0xFF0C0C0E).withOpacity(0.5), // #0C0C0E 50% 투명도
              borderRadius: BorderRadius.circular(20), // 모든 모서리 라운드 처리
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 매장 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: const Color(0xFF3A3A3A),
                          child: space.image.isNotEmpty && !space.image.contains('undefined')
                              ? Image.network(
                                  space.image,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A3FF)),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print('❌ 이미지 로드 에러: ${space.image}');
                                    return Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[600],
                                        size: 30,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFF3A3A3A),
                                  child: Center(
                                    child: Icon(
                                      Icons.store,
                                      color: Colors.grey[600],
                                      size: 30,
                                    ),
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
                            // 카테고리 배지와 상세보기
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getCategoryDisplayName(space.category),
                                    style: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 11,
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
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Pretendard',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[500],
                                      size: 12,
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
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // 운영 상태
                            _buildBusinessHoursStatus(space),
                            // 혜택 정보가 있을 때만 구분선과 혜택 표시
                            if (space.benefitDescription.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              // 구분선
                              Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/ico_infobenefit.png',
                                    width: 12,
                                    height: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '혜택',
                                    style: const TextStyle(
                                      color: Color(0xFF00A3FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 2,
                                    height: 2,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF666666),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      space.benefitDescription,
                                      style: const TextStyle(
                                        color: Color(0xFF999999),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 영업시간 상태 위젯 생성
  Widget _buildBusinessHoursStatus(SpaceEntity space) {
    // 임시 휴무 체크
    if (space.isTemporarilyClosed) {
      return Text(
        '임시 휴무',
        style: TextStyle(
          color: Colors.red[300],
          fontSize: 14,
          fontFamily: 'Pretendard',
        ),
      );
    }

    // 영업시간 데이터가 없는 경우
    if (space.businessHours.isEmpty) {
      return Text(
        '영업시간 정보 없음',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontFamily: 'Pretendard',
        ),
      );
    }

    // 현재 영업 상태 확인
    final isOpen = space.isCurrentlyOpen;
    final now = DateTime.now();
    final currentDay = _getDayOfWeekFromDateTime(now);
    
    // 오늘의 영업시간 찾기
    final todayHours = space.businessHours.firstWhere(
      (hours) => hours.dayOfWeek == currentDay,
      orElse: () => BusinessHoursEntity(
        dayOfWeek: currentDay,
        isClosed: true,
      ),
    );

    if (isOpen) {
      // 영업 중 - 마감 시간 표시
      if (todayHours.closeTime != null) {
        // 휴게시간 체크
        if (todayHours.breakStartTime != null && todayHours.breakEndTime != null) {
          final breakStartParts = todayHours.breakStartTime!.split(':');
          final breakEndParts = todayHours.breakEndTime!.split(':');
          final currentMinutes = now.hour * 60 + now.minute;
          final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
          final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);
          
          // 휴게시간 30분 전
          if (currentMinutes >= breakStartMinutes - 30 && currentMinutes < breakStartMinutes) {
            return Row(
              children: [
                Text(
                  '영업 중',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                ),
                Text(
                  ' • ${todayHours.breakStartTime} 브레이크타임',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            );
          }
        }
        
        return Row(
          children: [
            Text(
              '영업 중',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            ),
            Text(
              ' • ${todayHours.closeTime} 마감',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        );
      } else {
        return Text(
          '영업 중',
          style: TextStyle(
            color: Colors.green[400],
            fontSize: 14,
            fontFamily: 'Pretendard',
          ),
        );
      }
    } else {
      // 영업 종료 - 다음 영업 시간 표시
      final nextOpenTime = space.nextOpeningTime;
      
      // 오늘 휴무인지 확인
      if (todayHours.isClosed) {
        if (nextOpenTime != null) {
          return Text(
            '휴무일 • 다음 영업 시작',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          );
        } else {
          return Text(
            '휴무일',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          );
        }
      }
      
      // 영업 종료
      if (nextOpenTime != null && todayHours.openTime != null) {
        // 오늘 아직 열기 전인지 확인
        final openParts = todayHours.openTime!.split(':');
        final openHour = int.parse(openParts[0]);
        final openMinute = int.parse(openParts[1]);
        final currentMinutes = now.hour * 60 + now.minute;
        final openMinutes = openHour * 60 + openMinute;
        
        if (currentMinutes < openMinutes) {
          return Row(
            children: [
              Text(
                '영업 전',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
              Text(
                ' • ${todayHours.openTime} 오픈',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          );
        }
      }
      
      // 휴게시간 중인지 확인
      if (todayHours.breakStartTime != null && todayHours.breakEndTime != null && !todayHours.isClosed) {
        final breakStartParts = todayHours.breakStartTime!.split(':');
        final breakEndParts = todayHours.breakEndTime!.split(':');
        final currentMinutes = now.hour * 60 + now.minute;
        final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);
        
        if (currentMinutes >= breakStartMinutes && currentMinutes < breakEndMinutes) {
          return Row(
            children: [
              Text(
                '브레이크타임',
                style: TextStyle(
                  color: Colors.orange[300],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
              Text(
                ' • ${todayHours.breakEndTime} 까지',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          );
        }
      }
      
      return Text(
        '영업 종료',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontFamily: 'Pretendard',
        ),
      );
    }
  }

  // 컴팩트한 영업시간 상태 위젯
  Widget _buildBusinessHoursStatusCompact(SpaceEntity space) {
    // 임시 휴무 체크
    if (space.isTemporarilyClosed) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '임시 휴무',
            style: TextStyle(
              color: Color(0xFFFF4444),
              fontSize: 12,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      );
    }

    // 영업시간 데이터가 없는 경우
    if (space.businessHours.isEmpty) {
      return const Text(
        '영업시간 정보 없음',
        style: TextStyle(
          color: Color(0xFF999999),
          fontSize: 12,
          fontFamily: 'Pretendard',
        ),
      );
    }

    // 현재 영업 상태 확인
    final isOpen = space.isCurrentlyOpen;
    final now = DateTime.now();
    final currentDay = _getDayOfWeekFromDateTime(now);
    
    // 오늘의 영업시간 찾기
    final todayHours = space.businessHours.firstWhere(
      (hours) => hours.dayOfWeek == currentDay,
      orElse: () => BusinessHoursEntity(
        dayOfWeek: currentDay,
        isClosed: true,
      ),
    );

    if (isOpen) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF00A3FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '영업 중 • ${todayHours.closeTime ?? ""}까지',
            style: const TextStyle(
              color: Color(0xFF00A3FF),
              fontSize: 12,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      );
    } else {
      // 오늘 휴무인 경우
      if (todayHours.isClosed) {
        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF999999),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '휴무일',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        );
      }
      
      // 영업 종료
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF999999),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '영업 종료',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 12,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      );
    }
  }

  // 카테고리 표시 이름 변환
  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'CAFE':
        return '카페';
      case 'MEAL':
        return '식당';
      case 'PUB':
        return '주점';
      case 'MUSIC':
        return '음악';
      case 'BAR':
        return '바';
      case 'ETC':
        return '기타';
      default:
        return category;
    }
  }

  // DateTime에서 DayOfWeek로 변환하는 헬퍼 메서드
  DayOfWeek _getDayOfWeekFromDateTime(DateTime dateTime) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
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
      case 'ETC':
      default:
        return 'marker_ETC';
    }
  }

  void _onStyleLoadedCallback(StyleLoadedEventData data) async {
    print('🗺️ Map style loaded - setting up map immediately');
    
    try {
      // 스타일 로딩 완료 후 카메라 위치 재설정 (확실한 지도 표시)
      if (mapboxMap != null) {
        await mapboxMap!.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(currentLongitude, currentLatitude)),
            zoom: currentZoom,
          ),
        );
        print('📍 Camera position reset after style loaded');
      }
      
      // 지도 스타일 로드 완료 표시
      setState(() {
        isMapStyleLoaded = true;
      });
      
      // 즉시 지도 설정 (지연 없이 바로 실행)
      await _setupMapImmediately();
    } catch (e) {
      print('❌ Error in style loaded callback: $e');
      // 에러가 있어도 기본 설정은 진행
      setState(() {
        isMapStyleLoaded = true;
      });
      await _setupMapImmediately();
    }
  }
  
  // 즉시 지도 설정 (지연 없이)
  Future<void> _setupMapImmediately() async {
    print('🔧 Setting up map immediately...');
    
    if (mapboxMap == null) return;
    
    try {
      // UI 요소 비활성화
      await _disableAllMapUI();
      
      // 현재 위치 표시 설정
      await _setupLocationDisplay();
      
      // 한국어 설정
      _setMapLanguageToKorean();
      
      // 데이터 로드 (지연 없이 즉시 시작)
      _completeMapInitialization();
      
      // 지도 설정 완료 후 위치 추적 시작 (지도 표시에 영향 없음)
      Future.delayed(const Duration(milliseconds: 500), () {
        _startLocationTracking();
      });
      
      print('✅ Map setup completed immediately');
    } catch (e) {
      print('❌ Error in immediate map setup: $e');
    }
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

  void _onMapTapListener(MapContentGestureContext gestureContext) async {
    print('🗺️ Map tapped at: ${gestureContext.point}');
    print('📄 Current info card state before tap: showInfoCard=$showInfoCard');
    print('🔧 mapboxMap is null: ${mapboxMap == null}');
    print('🔧 _isShowingZoomToast: $_isShowingZoomToast');
    
    // 현재 줌 레벨 확인
    if (mapboxMap != null) {
      try {
        final cameraState = await mapboxMap!.getCameraState();
        final currentMapZoom = cameraState.zoom;
        print('🔍 Current zoom level: $currentMapZoom');
        print('🔍 Zoom < 16: ${currentMapZoom < 16}');
        
        // 줌 레벨이 16보다 작으면 토스트 메시지 표시
        if (currentMapZoom < 13) {
          print('🎯 Showing zoom toast - mounted: $mounted, _isShowingZoomToast: $_isShowingZoomToast');
          if (mounted && !_isShowingZoomToast) {
            _isShowingZoomToast = true;
            print('🚀 Actually showing toast now!');
            try {
              // 커스텀 오버레이로 토스트 표시
              final overlay = Overlay.of(context);
              final overlayEntry = OverlayEntry(
                builder: (context) => Positioned(
                  top: MediaQuery.of(context).size.height * 0.5 - 48, // 화면 중앙
                  left: MediaQuery.of(context).size.width * 0.5 - 160, // 320/2
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 320,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Color(0xFF181819), // 컬러 배경
                        border: Border.all(
                          color: Color(0xFF23B0FF), // stroke color
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "앗! 아직 너무 멀리있어.\n좀 더 확대해서 숨을 곳을 클릭해봐!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // Pretendard Medium
                              letterSpacing: -0.14, // -1% of 14pt
                              height: 1.7, // 170% line height
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
              
              overlay.insert(overlayEntry);
              print('✨ Toast shown successfully!');
              
              // 2초 후 오버레이 제거
              Future.delayed(const Duration(seconds: 2), () {
                overlayEntry.remove();
              });
            } catch (e) {
              print('❌ Error showing toast: $e');
              _isShowingZoomToast = false;
            }
            // 2초 후 플래그 리셋
            Future.delayed(const Duration(seconds: 2), () {
              print('🔄 Resetting _isShowingZoomToast flag - mounted: $mounted');
              if (mounted) {
                setState(() {
                  _isShowingZoomToast = false;
                  print('✅ _isShowingZoomToast reset to false');
                });
              }
            });
          } else {
            print('⚠️ Toast not shown - mounted: $mounted, _isShowingZoomToast: $_isShowingZoomToast');
          }
          return; // 마커 확인을 하지 않고 종료
        }
      } catch (e) {
        print('❌ Error getting zoom level: $e');
      }
    } else {
      print('⚠️ mapboxMap is null');
    }
    
    // 먼저 인포카드를 닫는다
    if (showInfoCard) {
      print('🔄 Closing info card first...');
      setState(() {
        showInfoCard = false;
        selectedSpace = null;
      });
    }
    
    // 탭한 위치 근처에 마커가 있는지 확인 (직접 지리 좌표 사용)
    final tappedLat = gestureContext.point.coordinates.lat.toDouble();
    final tappedLng = gestureContext.point.coordinates.lng.toDouble();
    await _checkMarkerNearGeoCoordinates(tappedLat, tappedLng);
    
    // 지도 중심점 확인 및 매장 재로드는 제거 (불필요한 리로드 방지)
    // await _checkAndUpdateLocation();
  }

  // 탭한 위치 근처에 마커가 있는지 확인하고 상세화면으로 이동
  Future<void> _checkMarkerNearGeoCoordinates(double tappedLat, double tappedLng) async {
    print('🔍 Checking markers near tap: $tappedLat, $tappedLng');
    print('📍 Total markers in map: ${markerSpaceMap.length}');
    
    try {
      // 매핑된 매장 정보에서 가까운 마커 찾기
      dynamic tappedSpace;
      double minDistance = double.infinity;
      const tapThreshold = 0.001; // 약 100m 정도의 허용 거리
      
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
      
      // 마커를 찾았으면 인포카드 표시
      if (tappedSpace != null) {
        print('🎯 Marker tapped! Found space: ${tappedSpace.name}');
        
        setState(() {
          selectedSpace = tappedSpace;
          showInfoCard = true;
        });
        print('✅ Info card shown for ${tappedSpace.name}');
      } else {
        print('❌ No marker found near tap location - info card remains closed');
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
    print('🗺️ MapScreen build() called at ${DateTime.now()}');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BLUECHECK MAP',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: false,
      ),
      body: BlocListener<SpaceCubit, SpaceState>(
        bloc: getIt<SpaceCubit>(),
        listener: (context, state) {
          print('🔄 BlocListener triggered - Status: ${state.submitStatus}, Spaces: ${state.spaceList.length}');
          // BlocListener는 로그만 출력 (실제 마커 추가는 _loadNearbySpaces에서 처리)
          if (state.submitStatus == RequestStatus.success && state.spaceList.isNotEmpty) {
            print('✅ BlocListener: Data loaded successfully - ${state.spaceList.length} spaces');
            if (markersAdded) {
              print('✅ BlocListener: Markers already added, skipping');
            }
          } else if (state.submitStatus == RequestStatus.success && state.spaceList.isEmpty) {
            print('⚠️ BlocListener: Success but no spaces found');
          } else if (state.submitStatus == RequestStatus.failure) {
            print('❌ BlocListener: Failed to load spaces - ${state.errorMessage}');
          }
        },
        child: Stack(
          children: [
            // Mapbox 지도
            RepaintBoundary(
              child: MapWidget(
                key: const ValueKey("mapWidget"),
                onMapCreated: _onMapCreated,
                onStyleLoadedListener: _onStyleLoadedCallback,
                onTapListener: _onMapTapListener,
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(currentLongitude, currentLatitude)),
                  zoom: currentZoom,
                  bearing: 0.0,
                  pitch: 0.0,
                ),
                styleUri: 'mapbox://styles/ixplorer/cmbhjhxbr00b401sn9glq0y9l', // 커스텀 스타일 적용
                textureView: Platform.isAndroid, // Android만 textureView 사용
              ),
            ),



            // 상단 카테고리 필터 버튼들
            Positioned(
              top: 16,
              left: 16,
              right: 16, // 현재 위치 버튼이 하단으로 이동하여 공간 확보 불필요
              child: _buildCategoryFilterButtons(),
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
            
            // 지도 컨트롤 버튼들 (우측하단 - 탭바 위)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: showInfoCard && selectedSpace != null ? 320 : 120, // 인포카드 있을 때는 위로, 없을 때는 탭바 위
              right: 16,
              child: GestureDetector(
                onTap: _moveToCurrentLocation,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0x3319BAFF), // #19BAFF33 배경색
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF797979),
                      width: 1,
                    ),
                  ),
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
              AnimatedPositioned(
                // key: ValueKey(selectedSpace!.id), // 매장 ID를 키로 사용하여 매장 변경 시 위젯 강제 재빌드
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: showInfoCard && selectedSpace != null ? 110 : -200, // 탭바 위에 표시
                left: 20,
                right: 20,
                child: _buildInfoCard(selectedSpace!),
              ),

            // 검색 오버레이
            if (showSearchOverlay)
              Positioned.fill(
                child: _buildSearchOverlay(),
              ),

          ],
        ),
      ),
    );
  }

  // 통합 카테고리별 매장 필터링
  void _filterSpacesByUnifiedCategory(UnifiedCategoryEntity? category) {
    if (category == null) {
      // 전체 표시
      filteredSpaces = List<SpaceEntity>.from(allSpaces);
      print('📋 No category selected - showing all spaces');
      setState(() {});
      return;
    }

    print('🔍 Filtering spaces by unified category: ${category.name} (type: ${category.type})');
    print('📊 Total spaces before filtering: ${allSpaces.length}');
    
    if (category.type == CategoryType.space) {
      // 매장 카테고리 필터링
      if (category.spaceCategory == SpaceCategory.ENTIRE) {
        filteredSpaces = List<SpaceEntity>.from(allSpaces);
        print('📋 ENTIRE category selected - showing all spaces');
      } else {
        filteredSpaces = allSpaces.where((space) {
          bool matches = false;
          switch (category.spaceCategory) {
            case SpaceCategory.CAFE:
              matches = space.category?.toLowerCase() == 'cafe';
              break;
            case SpaceCategory.MEAL:
              matches = space.category?.toLowerCase() == 'meal';
              break;
            case SpaceCategory.PUB:
              matches = space.category?.toLowerCase() == 'pub';
              break;
            case SpaceCategory.MUSIC:
              matches = space.category?.toLowerCase() == 'music';
              break;
            case SpaceCategory.ETC:
              matches = space.category?.toLowerCase() == 'etc' || 
                       space.category?.toLowerCase() == 'bar';
              break;
            default:
              matches = true;
          }
          return matches;
        }).toList();
        print('🔍 Filtered to ${filteredSpaces.length} spaces by space category');
      }
    } else if (category.type == CategoryType.event && category.eventCategory != null) {
      // 이벤트 카테고리 필터링
      final eventCategory = category.eventCategory!;
      filteredSpaces = allSpaces.where((space) {
        return space.spaceEventCategories.any(
          (spaceEventCategory) => spaceEventCategory.eventCategory.id == eventCategory.id
        );
      }).toList();
      print('🎉 Filtered to ${filteredSpaces.length} spaces by event category');
    }
    
    // 필터링 결과 검증
    if (filteredSpaces.isEmpty) {
      print('⚠️ No spaces found for category: ${category.name}');
    } else {
      print('✅ Found ${filteredSpaces.length} spaces');
    }
    
    setState(() {});
  }

  // 통합 카테고리 선택 시 처리
  void _onUnifiedCategorySelected(UnifiedCategoryEntity category) async {
    print('📂 Unified category selected: ${category.name} (type: ${category.type})');
    
    // 현재 스크롤 위치 저장
    final currentScrollOffset = _categoryScrollController.hasClients 
        ? _categoryScrollController.offset 
        : 0.0;
    
    setState(() {
      selectedCategory = category;
    });
    
    _filterSpacesByUnifiedCategory(category);
    
    // 마커 업데이트
    print('🔄 카테고리 변경으로 마커 업데이트: ${filteredSpaces.length}개 매장');
    await _addAllMarkers(filteredSpaces);
    
    // 현재 위치 마커가 사라졌을 수 있으므로 다시 추가
    print('📍 카테고리 변경 후 현재 위치 마커 재추가');
    await _updateCurrentLocationMarker(userActualLatitude, userActualLongitude);
    
    // 스크롤 위치 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categoryScrollController.hasClients) {
        _categoryScrollController.jumpTo(currentScrollOffset);
      }
    });
  }

  void _moveToCurrentLocation() async {
    try {
      print('📍 Moving to current location: $userActualLatitude, $userActualLongitude');
      
      // 인포카드 닫기
      if (showInfoCard) {
        setState(() {
          showInfoCard = false;
          selectedSpace = null;
        });
      }
      
      // 실시간 추적 중인 현재 위치로 이동
      mapboxMap?.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(userActualLongitude, userActualLatitude)),
          zoom: 16.0, // 조금 더 확대
        ),
        MapAnimationOptions(duration: 1500), // 조금 더 빠르게
      );
      currentZoom = 16.0;
      
      // 위치 추적이 비활성화되어 있다면 다시 시작
      if (!_isTrackingLocation) {
        print('📍 Restarting location tracking...');
        await _startLocationTracking();
      }
      
      // 현재 위치 마커 업데이트 (혹시 사라졌을 경우를 대비)
      await _updateCurrentLocationMarker(userActualLatitude, userActualLongitude);
      
      print('✅ Moved to current location successfully');
    } catch (e) {
      print('❌ Error moving to current location: $e');
    }
  }

  // 실시간 위치 추적 시작
  Future<void> _startLocationTracking() async {
    try {
      print('📍 Starting location tracking...');
      
      // 위치 권한 확인
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          print('❌ Location permission denied');
          return;
        }
      }
      
      if (permission == geo.LocationPermission.deniedForever) {
        print('❌ Location permission denied forever');
        return;
      }
      
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location service disabled');
        return;
      }
      
      _isTrackingLocation = true;
      
      // 위치 스트림 설정 (정확도 높음, 5초마다 업데이트, 최소 이동거리 10m)
      const geo.LocationSettings locationSettings = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // 10m 이상 이동시에만 업데이트
      );
      
      _positionSubscription = geo.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onLocationUpdate,
        onError: (error) {
          print('❌ Location stream error: $error');
        },
      );
      
      print('✅ Location tracking started successfully');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
    }
  }
  
  // 위치 업데이트 처리
  void _onLocationUpdate(geo.Position position) async {
    try {
      final now = DateTime.now();
      
      // 너무 빈번한 업데이트 방지 (최소 3초 간격)
      if (_lastLocationUpdate != null && 
          now.difference(_lastLocationUpdate!).inSeconds < 3) {
        return;
      }
      
      _lastLocationUpdate = now;
      
      print('📍 Location updated: ${position.latitude}, ${position.longitude}');
      print('📏 Accuracy: ${position.accuracy}m, Speed: ${position.speed}m/s');
      
      // 사용자의 실제 위치 업데이트
      userActualLatitude = position.latitude;
      userActualLongitude = position.longitude;
      
      // 현재 위치 마커 업데이트
      await _updateCurrentLocationMarker(position.latitude, position.longitude);
      
    } catch (e) {
      print('❌ Error handling location update: $e');
    }
  }
  
  // 현재 위치 마커 실시간 업데이트
  Future<void> _updateCurrentLocationMarker(double lat, double lng) async {
    if (_pointAnnotationManager == null || mapboxMap == null) return;
    
    print('🔍 _updateCurrentLocationMarker 호출됨 - lat: $lat, lng: $lng');
    
    // 위치가 유효하지 않으면 리턴
    if (lat == 0 || lng == 0) {
      print('⚠️ 현재 위치가 유효하지 않음 (0,0) - 마커 업데이트 건너뜀');
      return;
    }
    
    try {
      // 기존 현재 위치 마커가 있으면 삭제
      if (_currentLocationAnnotation != null) {
        print('🗑️ 기존 현재 위치 마커 삭제');
        await _pointAnnotationManager!.delete(_currentLocationAnnotation!);
        _currentLocationAnnotation = null;
      }
      
      // 새로운 현재 위치 마커 생성
      final currentLocationMarker = PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        iconImage: 'current_location_marker',
        iconSize: 0.45,
      );
      
      _currentLocationAnnotation = await _pointAnnotationManager!.create(currentLocationMarker);
      
      print('📍 Current location marker updated to: $lat, $lng');
      print('✅ 현재 위치 마커 ID: ${_currentLocationAnnotation?.id}');
    } catch (e) {
      print('❌ Error updating current location marker: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }
  
  // 위치 추적 중지
  void _stopLocationTracking() {
    if (_positionSubscription != null) {
      _positionSubscription!.cancel();
      _positionSubscription = null;
      _isTrackingLocation = false;
      print('📍 Location tracking stopped');
    }
  }

  @override
  void dispose() {
    _stopLocationTracking();
    searchController.dispose();
    _categoryScrollController.dispose();
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

  // 카테고리 필터 버튼들 UI
  Widget _buildCategoryFilterButtons() {
    return Container(
          height: 38,
          child: Row(
            children: [
              // 검색 버튼
              GestureDetector(
                onTap: () {
                  print('🔍 검색 버튼 클릭');
                  
                  // 검색 화면 표시 (현재 필터 유지)
                  setState(() {
                    showSearchOverlay = true;
                  });
                },
                child: Container(
                  width: 44,
                  height: 38,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x3319BAFF), // #19BAFF33 배경색
                    borderRadius: BorderRadius.circular(19), // 카테고리 버튼과 같은 라운드 테두리
                    border: Border.all(
                      color: const Color(0xFF797979), // 카테고리 버튼과 같은 테두리 색상
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/icon_cate_search.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              
              // 카테고리 버튼들
              Expanded(
                child: ListView.builder(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: unifiedCategories.length,
                  itemBuilder: (context, index) {
                    final category = unifiedCategories[index];
                    return _buildUnifiedCategoryButton(category);
                  },
                ),
              ),
            ],
          ),
        );
  }
  
  // 색상 코드 파싱 헬퍼 메서드
  Color _parseColorCode(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
      }
      return const Color(0xFF3A3A3A);
    } catch (e) {
      return const Color(0xFF3A3A3A);
    }
  }

  // 통합 카테고리 버튼
  Widget _buildUnifiedCategoryButton(UnifiedCategoryEntity category) {
    final isSelected = selectedCategory?.id == category.id;
    
    return GestureDetector(
      onTap: () => _onUnifiedCategorySelected(category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0x3319BAFF), // #19BAFF33 배경색
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF00A3FF)
                : const Color(0xFF5A5A5A),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 처리
              if (category.iconUrl != null) ...[
                if (category.type == CategoryType.event && category.iconUrl!.startsWith('http')) 
                  // 이벤트 카테고리 - 네트워크 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.5,
                      child: ColorFiltered(
                        colorFilter: isSelected 
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                        child: Image.network(
                          category.iconUrl!,
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  )
                else if (category.iconUrl!.endsWith('.svg'))
                  // SVG 아이콘
                  SvgPicture.asset(
                    category.iconUrl!,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      isSelected 
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF9A9A9A),
                      BlendMode.srcIn,
                    ),
                  )
                else
                  // PNG 아이콘
                  Opacity(
                    opacity: isSelected ? 1.0 : 0.6,
                    child: Image.asset(
                      category.iconUrl!,
                      width: 16,
                      height: 16,
                    ),
                  ),
                const SizedBox(width: 6),
              ],
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF9A9A9A),
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색 오버레이 UI
  Widget _buildSearchOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            // 검색 바 (상단에 바로 붙음)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchTextChanged,
                  onSubmitted: _onSearchSubmitted,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: '맛집을 검색해봐',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    // 뒤로가기 버튼을 입력 필드 내부 왼쪽에 배치
                    prefixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          showSearchOverlay = false;
                          searchController.clear();
                          searchResults.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // 클리어 버튼 (검색어가 있을 때만)
                    suffixIcon: searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() {
                                searchResults.clear();
                                isSearching = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.clear,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            
            // 검색 결과 및 기록
            Expanded(
              child: searchController.text.isNotEmpty
                  ? _buildSearchResults()
                  : _buildSearchHistory(),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 기록 UI
  Widget _buildSearchHistory() {
    return Column(
      children: [
        // 헤더 (Recent & Delete All)
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    searchHistory.clear();
                  });
                },
                child: const Text(
                  'Delete All',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 검색 기록 리스트
        Expanded(
          child: ListView.builder(
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              final historyItem = searchHistory[index];
              return _buildHistoryItem(historyItem, index);
            },
          ),
        ),
      ],
    );
  }

  // 검색 기록 아이템
  Widget _buildHistoryItem(String query, int index) {
    return GestureDetector(
      onTap: () {
        // 검색 기록 클릭 시 검색 실행
        searchController.text = query;
        _addToSearchHistory(query);
        _performSearch(query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 시계 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 검색어
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (query.contains('카페') || query.contains('coffee'))
                    const Text(
                      'Cafe • 서울시 성북구 서대문',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // 삭제 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  searchHistory.removeAt(index);
                });
              },
              child: Container(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.close,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 결과 UI
  Widget _buildSearchResults() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final space = searchResults[index];
        return _buildSearchResultItem(space);
      },
    );
  }

  // 검색 결과 아이템
  Widget _buildSearchResultItem(SpaceEntity space) {
    return GestureDetector(
      onTap: () {
        // 검색 결과 클릭 시 처리
        _onSearchResultTap(space);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬로 변경
          children: [
            // 카테고리 아이콘과 거리
            Column(
              children: [
                Stack(
                  children: [
                    // 배경 이미지
                    Image.asset(
                      'assets/icons/bg_icon_cate.png',
                      width: 48,
                      height: 48,
                    ),
                    // 카테고리 아이콘
                    Positioned.fill(
                      child: Center(
                        child: _getCategoryIcon(space.category).endsWith('.svg')
                            ? SvgPicture.asset(
                                _getCategoryIcon(space.category),
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              )
                            : Image.asset(
                                _getCategoryIcon(space.category),
                                width: 20,
                                height: 20,
                                // PNG 아이콘은 원본 색상 유지
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _calculateDistance(space),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // 매장 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2, // 최대 2줄로 제한
                    overflow: TextOverflow.ellipsis, // 넘치면 ... 표시
                  ),
                  const SizedBox(height: 4),
                  _buildBusinessHoursStatus(space),
                  if (space.benefitDescription.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      space.benefitDescription,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // 화살표 아이콘
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 검색어 입력 처리
  void _onSearchTextChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults.clear();
        isSearching = false;
      } else {
        isSearching = true;
      }
    });

    if (query.isEmpty) {
      return;
    }

    // 검색 실행 (디바운싱)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchController.text == query && query.isNotEmpty) {
        _performSearch(query);
      }
    });
  }

  // 엔터키 입력 처리 (검색 기록에 추가)
  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      _addToSearchHistory(query);
      _performSearch(query);
    }
  }

  // 검색 실행
  void _performSearch(String query) {
    print('🔍 Searching for: $query');
    
    // 전체 매장에서 검색 (필터 무시)
    final results = allSpaces.where((space) {
      return space.name.toLowerCase().contains(query.toLowerCase()) ||
             space.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchResults = results;
      isSearching = false;
    });

    print('📊 Search results: ${results.length} found');
  }

  // 검색 기록에 추가하는 메서드
  void _addToSearchHistory(String query) {
    if (query.isEmpty) return;
    
    // 이미 존재하는 검색어면 맨 위로 이동
    if (searchHistory.contains(query)) {
      searchHistory.remove(query);
    }
    
    // 맨 위에 추가
    searchHistory.insert(0, query);
    
    // 최대 10개까지만 유지
    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }
    
    print('📝 Search history updated: ${searchHistory.length} items');
    print('📝 Current history: $searchHistory');
  }

  // 검색 결과 탭 처리
  void _onSearchResultTap(SpaceEntity space) {
    print('🔍 검색 결과 클릭: ${space.name}');
    print('📍 매장 위치: lat=${space.latitude}, lng=${space.longitude}');
    
    // 검색어를 기록에 추가
    _addToSearchHistory(searchController.text);

    // 검색 화면 닫기
    setState(() {
      showSearchOverlay = false;
      searchController.clear();
      searchResults.clear();
    });

    // 검색 결과를 선택했으므로 필터를 전체로 리셋
    setState(() {
      selectedCategory = unifiedCategories.first; // 전체 카테고리
    });
    _filterSpacesByUnifiedCategory(selectedCategory);

    // 해당 매장으로 지도 이동
    if (mapboxMap != null && space.latitude != 0 && space.longitude != 0) {
      print('🗺️ 지도 이동 시작: ${space.name}으로 이동');
      
      mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(space.longitude, space.latitude)),
          zoom: 17.0, // 좀 더 가깝게
        ),
        MapAnimationOptions(duration: 1500), // 조금 더 빠르게
      );
      
      currentZoom = 17.0;
      
      print('✅ 지도 이동 완료');
    } else {
      print('❌ 지도 이동 실패: 위치 정보가 없습니다');
    }

    // 인포카드 표시
    setState(() {
      selectedSpace = space;
      showInfoCard = true;
    });
    
    print('📄 인포카드 표시: ${space.name}');
  }

  // 거리 계산
  String _calculateDistance(SpaceEntity space) {
    // 간단한 거리 계산 (실제로는 더 정확한 계산 필요)
    final distance = math.sqrt(
      math.pow(space.latitude - userActualLatitude, 2) +
      math.pow(space.longitude - userActualLongitude, 2)
    ) * 111; // 대략적인 km 변환
    
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  // 카테고리별 아이콘 가져오기
  String _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'cafe':
        return 'assets/icons/icon_cate_cafe.png';
      case 'meal':
        return 'assets/icons/icon_cate_food.png';
      case 'pub':
        return 'assets/icons/icon_cate_beer.png';
      case 'music':
        return 'assets/icons/ic_space_category_music.svg';
      case 'coworking':
        return 'assets/icons/icon_cate_etc.png';
      case 'etc':
      case 'bar':
        return 'assets/icons/icon_cate_etc.png';
      default:
        return 'assets/icons/icon_cate_all.png';
    }
  }
}