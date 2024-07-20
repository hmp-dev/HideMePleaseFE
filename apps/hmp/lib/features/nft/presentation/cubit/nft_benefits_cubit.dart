import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
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
  }) async {
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      latitude = 1;
      longitude = 1;
    }

    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      selectedTokenAddress: tokenAddress,
      nftBenefitsPage: 1,
      totalBenefitCount: 0,
      errorMessage: '',
      nftBenefitList: [],
      isAllBenefitsLoaded: false,
    ));

    await Future.delayed(const Duration(milliseconds: 100));

    final response = await _nftRepository.getNftBenefits(
      tokenAddress: tokenAddress,
      latitude: latitude,
      longitude: longitude,
      pageSize: 10,
      page: 1,
    );

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        final resultList =
            data.benefits?.map((e) => e.toEntity()).toList() ?? [];

        emit(
          state.copyWith(
            totalBenefitCount: data.benefitCount,
            nftBenefitList: resultList,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  Future<void> onGetNftBenefitsLoadMore() async {
    "onGetSpacesLoadMore is called".log();
    if (state.isAllBenefitsLoaded ||
        state.loadingMoreStatus == RequestStatus.loading ||
        state.selectedTokenAddress == '') {
      return;
    }
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      latitude = 1;
      longitude = 1;
    }

    emit(state.copyWith(loadingMoreStatus: RequestStatus.loading));

    final benefitsRes = await _nftRepository.getNftBenefits(
      tokenAddress: state.selectedTokenAddress,
      latitude: latitude,
      longitude: longitude,
      pageSize: 10,
      page: state.nftBenefitList.isEmpty ? 1 : state.nftBenefitsPage + 1,
    );

    benefitsRes.fold(
      (l) => emit(state.copyWith(loadingMoreStatus: RequestStatus.failure)),
      (data) => emit(state.copyWith(
        totalBenefitCount: data.benefitCount,
        isAllBenefitsLoaded: data.benefits?.isEmpty,
        nftBenefitList: List.from(state.nftBenefitList)
          ..addAll(data.benefits?.map((e) => e.toEntity()).toList() ?? []),
        loadingMoreStatus: RequestStatus.success,
        nftBenefitsPage:
            state.nftBenefitList.isEmpty ? 1 : state.nftBenefitsPage + 1,
      )),
    );
  }
}
