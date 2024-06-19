import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'nft_benefits_state.dart';

@lazySingleton
class NftBenefitsCubit extends BaseCubit<NftBenefitsState> {
  final NftRepository _nftRepository;

  NftBenefitsCubit(
    this._nftRepository,
  ) : super(NftBenefitsState.initial());

  Future<void> onGetNftBenefits({
    required String tokenAddress,
    String? spaceId,
    int? pageSize,
    int? page,
  }) async {
    "Current Token Address passed is $tokenAddress".log();
    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      selectedTokenAddress: tokenAddress,
      errorMessage: '',
      nftBenefitList: [],
    ));

    final response = await _nftRepository.getNftBenefits(
      tokenAddress: tokenAddress,
      spaceId: spaceId,
      pageSize: pageSize,
      page: page,
    );

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftBenefitsList) {
        final resultList =
            nftBenefitsList.benefits?.map((e) => e.toEntity()).toList() ?? [];

        emit(
          state.copyWith(
            nftBenefitList: resultList,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }
}
