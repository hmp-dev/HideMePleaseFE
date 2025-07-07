import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/space/domain/entities/benefits_group_entity.dart';
import 'package:mobile/features/space/domain/entities/new_space_entity.dart';
import 'package:mobile/features/space/domain/entities/recommendation_space_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/entities/spaces_response_entity.dart';
import 'package:mobile/features/space/domain/entities/top_used_nft_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'dart:math' as math;

part 'space_state.dart';

@lazySingleton
class SpaceCubit extends BaseCubit<SpaceState> {
  final SpaceRepository _spaceRepository;

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
    final response = await _spaceRepository.getNewsSpaceList();
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
            newSpaceList: result.map((e) => e.toEntity()).toList(),
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
  }) async {
    final response = await _spaceRepository.getSpaceList(
      latitude: latitude,
      longitude: longitude,
    );
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
            spaceList: result.map((e) => e.toEntity()).toList(),
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
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      latitude = 1;
      longitude = 1;
    }

    await Future.wait([
      onGetTopUsedNfts(),
      onGetNewSpaceList(),
      onGetRecommendSpaceList(),
      onGetSpaceList(
        latitude: latitude,
        longitude: longitude,
      ),
    ]);

    // Assuming success if no errors were emitted
    emit(state.copyWith(
      submitStatus: RequestStatus.success,
      errorMessage: '',
    ));
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
      (result) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            spaceDetailEntity: result.toEntity(),
          ),
        );
        onGetSpaceBenefitsOnSpaceDetailView(spaceId: spaceId);
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
          print('🎉 Raw API 응답 개수: ${spaces.length}개');
          
          final allSpaces = spaces.map((e) => e.toEntity()).toList();
          
          // 위치 정보가 있는 매장과 없는 매장 개수 확인
          int validLocationCount = 0;
          int invalidLocationCount = 0;
          
          for (final space in allSpaces) {
            if (space.latitude != 0 && space.longitude != 0) {
              validLocationCount++;
            } else {
              invalidLocationCount++;
            }
          }
          
          print('📊 매장 위치 정보 분석:');
          print('   ✅ 위치 정보 있음: ${validLocationCount}개');
          print('   ❌ 위치 정보 없음: ${invalidLocationCount}개');
          print('   📍 총 매장 수: ${allSpaces.length}개');
          
          emit(state.copyWith(
            submitStatus: RequestStatus.success,
            spaceList: allSpaces,
            allSpacesLoaded: true,
            errorMessage: '',
          ));
          
          // 처음 5개 매장의 상세 정보 확인
          for (int i = 0; i < math.min(5, allSpaces.length); i++) {
            final space = allSpaces[i];
            print('🏪 매장 ${i + 1}: ${space.name}');
            print('   📍 위치: lat=${space.latitude}, lng=${space.longitude}');
            print('   🏷️ 카테고리: ${space.category}');
            print('   🔥 핫: ${space.hot}');
          }
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
}
