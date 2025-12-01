import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/services/live_activity_service.dart';
import 'package:mobile/features/space/domain/entities/benefits_group_entity.dart';
import 'package:mobile/features/space/domain/entities/new_space_entity.dart';
import 'package:mobile/features/space/domain/entities/recommendation_space_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/entities/spaces_response_entity.dart';
import 'package:mobile/features/space/domain/entities/top_used_nft_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'dart:math' as math;

part 'space_state.dart';

@lazySingleton
class SpaceCubit extends BaseCubit<SpaceState> {
  final SpaceRepository _spaceRepository;
  bool _isCheckingIn = false;

  SpaceCubit(
      this._spaceRepository,
      ) : super(SpaceState.initial());

  Future<void> onGetBackdoorToken({
    required String spaceId,
  }) async {
    final response = await _spaceRepository.getBackdoorToken(
      spaceId: spaceId,
    );
    response.fold(
          (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (token) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            nfcToken: token,
          ),
        );
      },
    );
  }

  onResetSubmitStatus() {
    emit(state.copyWith(submitStatus: RequestStatus.initial));
  }

  Future<void> onGetTopUsedNfts() async {
    final response = await _spaceRepository.getTopUsedNfts();
    response.fold(
          (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (result) {
        emit(
          state.copyWith(
            topUsedNfts: result.map((e) => e.toEntity()).toList(),
          ),
        );
      },
    );
  }

  Future<void> onGetNewSpaceList() async {
    print('🔄 [SpaceCubit] onGetNewSpaceList 시작');
    print('📍 [SpaceCubit] 현재 newSpaceList 상태: ${state.newSpaceList.length}개');
    print('📍 [SpaceCubit] 호출 위치: ${StackTrace.current.toString().split('\n').take(5).join('\n')}');
    final response = await _spaceRepository.getNewsSpaceList();
    response.fold(
          (err) {
        print('❌ [SpaceCubit] onGetNewSpaceList 실패: $err');
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (result) {
        print('✅ [SpaceCubit] onGetNewSpaceList 성공: ${result.length}개');
        final entities = result.map((e) => e.toEntity()).toList();
        if (entities.isNotEmpty) {
          print('   첫 번째 매장: ${entities.first.name} (${entities.first.id})');
        }
        emit(
          state.copyWith(
            newSpaceList: entities,
          ),
        );
      },
    );
  }

  Future<void> onGetRecommendSpaceList() async {
    final response = await _spaceRepository.getRecommendedSpaces();
    response.fold(
          (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (result) {
        emit(
          state.copyWith(
            recommendationSpaceList: result.map((e) => e.toEntity()).toList(),
          ),
        );
      },
    );
  }

  Future<void> onGetSpaceList({
    required double latitude,
    required double longitude,
    int? page,
  }) async {
    print('🔄 [SpaceCubit] onGetSpaceList 시작 (lat: $latitude, lng: $longitude, page: $page)');
    final response = await _spaceRepository.getSpaceList(
      latitude: latitude,
      longitude: longitude,
      page: page,
    );
    response.fold(
          (err) {
        print('❌ [SpaceCubit] onGetSpaceList 실패: $err');
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (result) {
        print('✅ [SpaceCubit] onGetSpaceList 성공: ${result.length}개');
        final entities = result.map((e) => e.toEntity()).toList();
        if (entities.isNotEmpty) {
          print('   첫 번째 매장: ${entities.first.name} (${entities.first.id})');
        }
        emit(
          state.copyWith(
            spaceList: entities,
            allSpacesLoaded:
            result.isEmpty || result.length < 10 ? true : false,
            spacesPage: 1,
          ),
        );
      },
    );
  }

  Future<void> onGetSpaceListByCategory({
    SpaceCategory? category,
    int? page,
    required double latitude,
    required double longitude,
  }) async {
    EasyLoading.show(dismissOnTap: true);

    final response = await _spaceRepository.getSpaceList(
      category: category == SpaceCategory.ENTIRE ? null : category?.name,
      page: page ?? 1,
      latitude: latitude,
      longitude: longitude,
    );

    EasyLoading.dismiss();

    response.fold(
          (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (result) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            spaceCategory: category,
            spaceList: result.map((e) => e.toEntity()).toList(),
            allSpacesLoaded: result.isEmpty || result.length < 10 ? true : false,
            spacesPage: 1,
          ),
        );
      },
    );
  }

  Future<void> onGetSpacesLoadMore({
    required double latitude,
    required double longitude,
  }) async {
    "onGetSpacesLoadMore is called".log();
    if (state.allSpacesLoaded ||
        state.loadingMoreStatus == RequestStatus.loading) {
      return;
    }

    "onGetSpacesLoadMore is called".log();

    emit(state.copyWith(loadingMoreStatus: RequestStatus.loading));

    final spacesRes = await _spaceRepository.getSpaceList(
      category: state.spaceCategory == SpaceCategory.ENTIRE
          ? null
          : state.spaceCategory.name,
      page: state.spacesPage + 1,
      latitude: latitude,
      longitude: longitude,
    );

    spacesRes.fold(
          (l) => emit(state.copyWith(loadingMoreStatus: RequestStatus.failure)),
          (data) => emit(state.copyWith(
        allSpacesLoaded: data.isEmpty,
        spaceList: List.from(state.spaceList)
          ..addAll(data.map((e) => e.toEntity()).toList()),
        loadingMoreStatus: RequestStatus.success,
        spacesPage: state.spacesPage + 1,
      )),
    );
  }

  onFetchAllSpaceViewData() async {
    print('🔄 [SpaceCubit] onFetchAllSpaceViewData 시작');
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
      print('✅ [SpaceCubit] 위치 획득: $latitude, $longitude');
    } catch (e) {
      print('⚠️ [SpaceCubit] 위치 획득 실패, 기본값 사용: $e');
      latitude = 1;
      longitude = 1;
    }

    print('🔄 [SpaceCubit] Future.wait 시작...');

    // newSpaceList 캐싱: 이미 로드되어 있으면 다시 로드하지 않음
    if (state.newSpaceList.isEmpty) {
      print('📥 [SpaceCubit] newSpaceList 비어있음 - 새로 로드');
    } else {
      print('💾 [SpaceCubit] newSpaceList 캐시 사용 (${state.newSpaceList.length}개)');
    }

    await Future.wait([
      onGetTopUsedNfts(),
      if (state.newSpaceList.isEmpty) onGetNewSpaceList(),  // 캐싱: 비어있을 때만 로드
      onGetRecommendSpaceList(),
      onGetSpaceList(
        latitude: latitude,
        longitude: longitude,
        page: 999,  // 전체 매장 로드 (newSpaceList ID 매칭을 위해)
      ),
    ]);
    print('✅ [SpaceCubit] Future.wait 완료');

    // Assuming success if no errors were emitted
    emit(state.copyWith(
      submitStatus: RequestStatus.success,
      errorMessage: '',
    ));
    print('✅ [SpaceCubit] onFetchAllSpaceViewData 완료');
  }

  onGetSpaceDetailBySpaceId({required String spaceId}) async {
    EasyLoading.show(dismissOnTap: true);

    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      currentSpaceId: spaceId,
    ));

    final response = await _spaceRepository.getSpaceDetail(
      spaceId: spaceId,
    );

    EasyLoading.dismiss();

    response.fold(
          (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
          (result) async {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            spaceDetailEntity: result.toEntity(),
          ),
        );
        await onGetSpaceBenefitsOnSpaceDetailView(spaceId: spaceId);
      },
    );
  }

  Future<void> onGetSpaceBenefitsOnSpaceDetailView({
    required String spaceId,
    String? nextCursor,
    bool? isLoadingMore,
  }) async {
    if (isLoadingMore == true) {
      emit(state.copyWith(isLoadingMoreFetch: isLoadingMore));
      EasyLoading.show(dismissOnTap: true);

      final response = await _spaceRepository.getSpaceBenefits(
        spaceId: spaceId,
      );

      EasyLoading.dismiss();

      response.fold(
            (err) {
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        },
            (result) {
          emit(
            state.copyWith(
              submitStatus: RequestStatus.success,
              errorMessage: '',
              benefitsGroupEntity: result.toEntity(),
            ),
          );
        },
      );
    } else {
      EasyLoading.show(dismissOnTap: true);

      final response = await _spaceRepository.getSpaceBenefits(
        spaceId: spaceId,
      );

      EasyLoading.dismiss();

      response.fold(
            (err) {
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        },
            (result) {
          emit(
            state.copyWith(
              submitStatus: RequestStatus.success,
              errorMessage: '',
              benefitsGroupEntity: result.toEntity(),
            ),
          );
        },
      );
    }
  }

  Future<void> onCheckInWithNfc({
    required String spaceId,
    required double latitude,
    required double longitude,
    dynamic benefit, // Can be BenefitEntity or any benefit object
  }) async {
    // 이미 체크인 중이면 중복 체크인 방지
    if (_isCheckingIn) {
      print('⚠️ Check-in already in progress, preventing duplicate request');
      print('🔍 Current _isCheckingIn flag: $_isCheckingIn');
      return;
    }
    
    _isCheckingIn = true;
    print('🔄 Set _isCheckingIn = true for space: $spaceId');
    
    // 상태 초기화 - 이전 에러 메시지 제거
    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      errorMessage: '',
    ));
    print('🔄 Reset state - submitStatus: loading, errorMessage: cleared');
    
    ('🏁 Starting check-in for space: $spaceId').log();
    print('🔍 Calling repository checkIn...');
    
    // Extract benefitId if benefit is provided
    String? benefitId;
    String? benefitDescription;
    if (benefit != null) {
      // Handle different benefit object types
      if (benefit is Map<String, dynamic>) {
        benefitId = benefit['id']?.toString();
        benefitDescription = benefit['description']?.toString();
      } else {
        // Assuming it has id and description properties
        try {
          benefitId = benefit.id?.toString();
          benefitDescription = benefit.description?.toString();
        } catch (e) {
          print('⚠️ Could not extract benefit info: $e');
        }
      }
      print('🎁 Check-in with benefit: $benefitId - $benefitDescription');
    }

    final response = await _spaceRepository.checkIn(
      spaceId: spaceId,
      latitude: latitude,
      longitude: longitude,
      benefitId: benefitId,
    );

    return response.fold(
          (err) {
        _isCheckingIn = false; // 체크인 플래그 해제
        print('🔄 Set _isCheckingIn = false (check-in failed)');
        print('❌ Check-in failed in cubit with HMPError:');
        print('   - Message: ${err.message}');
        print('   - Error: ${err.error}');
        print('   - Type: ${err.type}');
        print('🚨 About to throw error from cubit');
        ('❌ Check-in failed: $err').log();
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
        throw err;  // This should propagate to the view
      },
          (result) async {
        print('✅ Check-in successful in cubit!');
        ('✅ Check-in successful!').log();
        
        // Save check-in info to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageValues.activeCheckInSpaceId, spaceId);
        await prefs.setInt(StorageValues.checkInTimestamp, DateTime.now().millisecondsSinceEpoch);
        await prefs.setDouble(StorageValues.checkInLatitude, latitude);
        await prefs.setDouble(StorageValues.checkInLongitude, longitude);
        // Save space name if available
        if (state.spaceDetailEntity != null) {
          await prefs.setString(StorageValues.checkInSpaceName, state.spaceDetailEntity!.name);
        }
        // Save benefit info if available
        if (benefitId != null) {
          await prefs.setString(StorageValues.checkInBenefitId, benefitId);
          if (benefitDescription != null) {
            await prefs.setString(StorageValues.checkInBenefitDescription, benefitDescription);
          }
        }
        print('💾 Check-in info saved to local storage (including benefit)');
        
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          currentCheckedInSpaceId: spaceId,
          checkInLatitude: latitude,
          checkInLongitude: longitude,
          checkInTime: DateTime.now(),
        ));
        
        _isCheckingIn = false; // 체크인 성공 후 플래그 해제
        print('🔄 Set _isCheckingIn = false (check-in successful)');
      },
    );
  }
  
  Future<void> onCheckOut({required String spaceId}) async {
    print('🔍 Starting check-out for space: $spaceId');
    
    final response = await _spaceRepository.checkOut(spaceId: spaceId);
    
    response.fold(
      (err) {
        print('❌ Check-out failed: ${err.message}');
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (success) async {
        print('✅ Check-out successful!');
        
        // Clear check-in info from local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(StorageValues.activeCheckInSpaceId);
        await prefs.remove(StorageValues.checkInTimestamp);
        await prefs.remove(StorageValues.checkInLatitude);
        await prefs.remove(StorageValues.checkInLongitude);
        await prefs.remove(StorageValues.checkInSpaceName);
        await prefs.remove(StorageValues.checkInBenefitId);
        await prefs.remove(StorageValues.checkInBenefitDescription);
        print('🗑️ Check-in info cleared from local storage');
        
        // End Live Activity when check-out is successful
        try {
          final liveActivityService = getIt<LiveActivityService>();
          await liveActivityService.endCheckInActivity();
          print('✅ Live Activity ended after check-out');
        } catch (e) {
          print('❌ Failed to end Live Activity after check-out: $e');
        }
        
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          clearCheckInData: true,
        ));
      },
    );
  }

  Future<void> onGetAllSpacesForMap({
    required double latitude,
    required double longitude,
  }) async {
    print('🎯 onGetAllSpacesForMap 함수 진입!');
    print('🎯 파라미터: lat=$latitude, lng=$longitude');

    try {
      print('🌍 지도용 전체 매장 로드 시작...');
      print('📍 요청 위치: lat=$latitude, lng=$longitude');

      // page=999로 전체 매장 데이터 요청 (백엔드에서 page=999일 때 전체 데이터 반환)
      final response = await _spaceRepository.getSpaceList(
        category: null, // 전체 카테고리 조회
        page: 999, // page=999로 전체 데이터 요청
        latitude: latitude,
        longitude: longitude,
      );

      await response.fold(
            (err) async {
          print('❌ 지도용 매장 로드 실패: $err');
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        },
            (spaces) async {
          final allSpaces = spaces.map((e) => e.toEntity()).toList();

          emit(state.copyWith(
            submitStatus: RequestStatus.success,
            spaceList: allSpaces,
            allSpacesLoaded: true,
            errorMessage: '',
          ));
        },
      );

    } catch (e) {
      print('❌ Error in onGetAllSpacesForMap: $e');
      emit(state.copyWith(
        submitStatus: RequestStatus.failure,
        errorMessage: LocaleKeys.somethingError.tr(),
      ));
    }
  }

  /// Sets or clears the currently selected space.
  void selectSpace(SpaceEntity? space) {
    emit(state.copyWith(selectedSpace: space, clearSelectedSpace: space == null));
  }
  
  /// Restores check-in state from local storage
  Future<void> restoreCheckInState() async {
    try {
      print('🔄 Restoring check-in state from local storage');
      final prefs = await SharedPreferences.getInstance();

      // Check for pending auto check-out from background task
      final shouldAutoCheckOut = prefs.getBool('shouldAutoCheckOut') ?? false;
      final pendingCheckOutSpaceId = prefs.getString('pendingCheckOutSpaceId');

      if (shouldAutoCheckOut && pendingCheckOutSpaceId != null) {
        print('🚨 Pending auto check-out detected for space: $pendingCheckOutSpaceId');
        // Clear the flags
        await prefs.remove('shouldAutoCheckOut');
        await prefs.remove('pendingCheckOutSpaceId');
        // Perform the check-out
        await onCheckOut(spaceId: pendingCheckOutSpaceId);
        print('✅ Completed pending auto check-out');
        return;
      }

      final spaceId = prefs.getString(StorageValues.activeCheckInSpaceId);
      final timestamp = prefs.getInt(StorageValues.checkInTimestamp);
      final latitude = prefs.getDouble(StorageValues.checkInLatitude);
      final longitude = prefs.getDouble(StorageValues.checkInLongitude);
      final spaceName = prefs.getString(StorageValues.checkInSpaceName);

      // Also check workmanager stored check-in data
      final workmanagerSpaceId = prefs.getString('currentCheckedInSpaceId');
      final workmanagerLat = prefs.getDouble('checkInLatitude');
      final workmanagerLng = prefs.getDouble('checkInLongitude');

      // Use workmanager data if available and main storage is empty
      final activeSpaceId = spaceId ?? workmanagerSpaceId;
      final activeLat = latitude ?? workmanagerLat;
      final activeLng = longitude ?? workmanagerLng;

      if (activeSpaceId != null && timestamp != null) {
        final checkInTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final timeDifference = DateTime.now().difference(checkInTime);

        // If more than 10 minutes have passed, auto check-out
        if (timeDifference.inMinutes > 10) {
          print('⏰ Check-in expired (${timeDifference.inMinutes} minutes old), auto checking out');
          await onCheckOut(spaceId: activeSpaceId);
        } else {
          print('✅ Valid check-in found for space: $activeSpaceId ($spaceName)');
          print('📍 Location: $activeLat, $activeLng');
          print('⏱️ Check-in time: ${timeDifference.inMinutes} minutes ago');

          emit(state.copyWith(
            currentCheckedInSpaceId: activeSpaceId,
            checkInLatitude: activeLat,
            checkInLongitude: activeLng,
            checkInTime: checkInTime,
          ));
        }
      } else {
        print('📭 No active check-in found in local storage');
      }
    } catch (e) {
      print('❌ Error restoring check-in state: $e');
    }
  }
}