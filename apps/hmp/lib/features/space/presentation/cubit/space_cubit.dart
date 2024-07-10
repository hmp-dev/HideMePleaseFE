import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
      page: page,
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
            spaceCategory: category,
            spaceList: result.map((e) => e.toEntity()).toList(),
            allSpacesLoaded:
                result.isEmpty || result.length < 10 ? true : false,
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
        allSpacesLoaded: data.isEmpty || data.length < 10,
        spaceList: List.from(state.spaceList)
          ..addAll(data.map((e) => e.toEntity()).toList()),
        loadingMoreStatus: RequestStatus.success,
        spacesPage: state.spacesPage + 1,
      )),
    );
  }

  onFetchAllSpaceViewData({
    required double latitude,
    required double longitude,
  }) async {
    EasyLoading.show(dismissOnTap: true);
    await Future.wait([
      onGetTopUsedNfts(),
      onGetNewSpaceList(),
      onGetRecommendSpaceList(),
      onGetSpaceList(
        latitude: latitude,
        longitude: longitude,
      ),
    ]);

    EasyLoading.dismiss();

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
}
