import 'package:flutter_easyloading/flutter_easyloading.dart';
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
    required double latitude,
    required double longitude,
  }) async {
    
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    EasyLoading.show(dismissOnTap: true);

    final response = await _spaceRepository.postRedeemBenefit(
      benefitId: benefitId,
      tokenAddress: tokenAddress,
      spaceId: spaceId,
      latitude: latitude,
      longitude: longitude,
    );

    EasyLoading.dismiss();

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
