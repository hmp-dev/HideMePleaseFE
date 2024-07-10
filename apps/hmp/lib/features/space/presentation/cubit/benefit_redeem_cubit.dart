import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';

part 'benefit_redeem_state.dart';

@lazySingleton
class BenefitRedeemCubit extends BaseCubit<BenefitRedeemState> {
  final SpaceRepository _spaceRepository;

  BenefitRedeemCubit(
    this._spaceRepository,
  ) : super(BenefitRedeemState.initial());

  Future<void> onPostRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String spaceId,
  }) async {
    final position = await Geolocator.getCurrentPosition();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _spaceRepository.postRedeemBenefit(
      benefitId: benefitId,
      tokenAddress: tokenAddress,
      spaceId: spaceId,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message,
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
}
