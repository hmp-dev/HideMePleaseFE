import 'package:easy_localization/easy_localization.dart';
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
    required String latitude,
    required String longitude,
  }) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));
    final response = await _spaceRepository.getSpacesData(
      tokenAddress: tokenAddress,
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
      (spacesData) {
        // if users
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
