import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/space_category.dart';
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

  Future<void> onGetSpacesData({
    required String tokenAddress,
    required double latitude,
    required double longitude,
  }) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));
    EasyLoading.show(dismissOnTap: true);
    final response = await _spaceRepository.getSpacesData(
      tokenAddress: tokenAddress,
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
      (spacesData) {
        // if users
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            spacesResponseEntity: spacesData.toEntity(),
            selectedNftTokenAddress: tokenAddress,
          ),
        );
      },
    );
  }

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

  Future<void> onPostRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String nfcToken,
    required double latitude,
    required double longitude,
  }) async {
    EasyLoading.show(dismissOnTap: true);

    final response = await _spaceRepository.postRedeemBenefit(
      benefitId: benefitId,
      tokenAddress: tokenAddress,
      nfcToken: nfcToken,
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
      (isSuccess) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            benefitRedeemStatus: true,
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

  Future<void> onGetSpaceList() async {
    final response = await _spaceRepository.getSpaceList();
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
          ),
        );
      },
    );
  }

  Future<void> onGetSpaceListByCategory({
    SpaceCategory? category,
    int? page,
  }) async {
    EasyLoading.show(dismissOnTap: true);
    final response = await _spaceRepository.getSpaceList(
      category: category == SpaceCategory.ENTIRE ? null : category?.name,
      page: page,
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
          ),
        );
      },
    );
  }

  onFetchAllSpaceViewData() async {
    EasyLoading.show(dismissOnTap: true);
    await Future.wait([
      onGetTopUsedNfts(),
      onGetNewSpaceList(),
      onGetRecommendSpaceList(),
      onGetSpaceList(),
    ]);

    EasyLoading.dismiss();

    // Assuming success if no errors were emitted
    emit(state.copyWith(
      submitStatus: RequestStatus.success,
      errorMessage: '',
    ));
  }

  onGetSpaceDetail({required String spaceId}) async {
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
      },
    );
  }

  Future<void> onGetSpaceBenefits({
    required String spaceId,
    String? nextCursor,
    bool? isLoadingMore,
  }) async {
    //TODO implement Load more functionality
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
