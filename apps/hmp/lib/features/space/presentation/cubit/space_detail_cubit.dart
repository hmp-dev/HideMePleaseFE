import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'space_detail_state.dart';

@lazySingleton
class SpaceDetailCubit extends BaseCubit<SpaceDetailState> {
  final SpaceRepository _spaceRepository;

  SpaceDetailCubit(
    this._spaceRepository,
  ) : super(SpaceDetailState.initial());

  onGetSpaceDetail({required BenefitEntity selectedBenefitEntity}) async {
    EasyLoading.show(dismissOnTap: true);

    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      selectedBenefitEntity: selectedBenefitEntity,
    ));

    final response = await _spaceRepository.getSpaceDetail(
      spaceId: selectedBenefitEntity.spaceId,
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
}
