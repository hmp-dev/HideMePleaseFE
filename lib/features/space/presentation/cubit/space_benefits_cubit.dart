import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/space/domain/entities/benefits_group_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'space_benefits_state.dart';

@lazySingleton
class SpaceBenefitsCubit extends BaseCubit<SpaceBenefitsState> {
  final SpaceRepository _spaceRepository;

  SpaceBenefitsCubit(
    this._spaceRepository,
  ) : super(SpaceBenefitsState.initial());

  Future<void> onGetSpaceBenefits({
    required String spaceId,
  }) async {
    emit(state.copyWith(
      selectedSpaceId: spaceId,
      errorMessage: '',
    ));

    final response = await _spaceRepository.getSpaceBenefits(spaceId: spaceId);

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (result) {
        emit(
          state.copyWith(
            benefitGroupEntity: result.toEntity(),
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }
}
