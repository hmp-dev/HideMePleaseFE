import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/entities/spaces_response_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'nearby_spaces_state.dart';

@lazySingleton
class NearBySpacesCubit extends BaseCubit<NearBySpacesState> {
  final SpaceRepository _spaceRepository;

  NearBySpacesCubit(
    this._spaceRepository,
  ) : super(NearBySpacesState.initial());

  // write a method to get list of spaces
  // and send it to state

  onResetSubmitStatus() {
    emit(state.copyWith(submitStatus: RequestStatus.initial));
  }

  // write a method to pass selected Benefit Entity adn send it to state

  onSetSelectedBenefitEntity(BenefitEntity selectedBenefitEntity) {
    emit(state.copyWith(selectedBenefitEntity: selectedBenefitEntity));
  }

  onResetSelectedBenefitEntity() {
    emit(state.copyWith(selectedBenefitEntity: const BenefitEntity.empty()));
  }

  // write a method to pass selected SpaceId adn send it to state

  onSetSelectedSpace(SpaceDetailEntity spaceDetailEntity) {
    emit(state.copyWith(selectedSpaceDetailEntity: spaceDetailEntity));
  }

  onReSetSelectedSpace() {
    emit(state.copyWith(
        selectedSpaceDetailEntity: const SpaceDetailEntity.empty()));
  }

  Future<void> onGetNearBySpacesListData({
    required String tokenAddress,
    BenefitEntity? selectedBenefitEntity,
  }) async {
    final position = await Geolocator.getCurrentPosition();

    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      selectedBenefitEntity: selectedBenefitEntity,
      errorMessage: '',
      spacesResponseEntity: SpacesResponseEntity.empty(),
    ));

    EasyLoading.show(dismissOnTap: true);
    final response = await _spaceRepository.getNearBySpacesListData(
      tokenAddress: tokenAddress,
      latitude: position.latitude,
      longitude: position.longitude,
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
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            spacesResponseEntity: spacesData.toEntity(),
          ),
        );
      },
    );
  }
}
