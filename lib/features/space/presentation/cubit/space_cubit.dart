import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/space/domain/entities/spaces_response_entity.dart';
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
  }) async {
    EasyLoading.show(dismissOnTap: true);

    final response = await _spaceRepository.postRedeemBenefit(
      benefitId: benefitId,
      tokenAddress: tokenAddress,
      nfcToken: nfcToken,
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
}
