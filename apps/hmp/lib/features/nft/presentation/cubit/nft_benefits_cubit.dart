import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'nft_benefits_state.dart';

@lazySingleton
class NftBenefitsCubit extends BaseCubit<NftBenefitsState> {
  final NftRepository _nftRepository;

  /// Initializes an instance of [NftBenefitsCubit]
  NftBenefitsCubit(
    this._nftRepository,
  ) : super(NftBenefitsState.initial());

  /// Calls [NftRepository.getNftBenefits] to get NFT benefits and updates the state accordingly.
  Future<void> onGetNftBenefits({
    required String tokenAddress,
  }) async {
    // Get current geolocation
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      // If geolocation fails, use default coordinates
      latitude = 1;
      longitude = 1;
    }

    // Update state with loading status
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

    // Call NftRepository to get NFT benefits
    final response = await _nftRepository.getNftBenefits(
      tokenAddress: tokenAddress,
      latitude: latitude,
      longitude: longitude,
      pageSize: 10,
      page: 1,
    );

    response.fold(
      // If NftRepository call fails, update state with error message
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If NftRepository call succeeds, update state with fetched benefits
      (data) {
        final resultList =
            data.benefits?.map((e) => e.toEntity()).toList() ?? [];

        // Remove duplicates based on `id`
        final uniqueResultList = removeDuplicates(resultList);

        emit(
          state.copyWith(
            totalBenefitCount: data.benefitCount,
            nftBenefitList: uniqueResultList,
            submitStatus: RequestStatus.success,
            errorMessage: '',
            isAllBenefitsLoaded: resultList.length == data.benefitCount,
          ),
        );
      },
    );
  }

  /// Calls [NftRepository.getNftBenefits] to get NFT benefits for load more case and updates the state accordingly.
  Future<void> onGetNftBenefitsLoadMore() async {
    // If all benefits are loaded, or loading more status is loading, or selected token address is empty, return
    if (state.isAllBenefitsLoaded ||
        state.loadingMoreStatus == RequestStatus.loading ||
        state.selectedTokenAddress == '') {
      return;
    }
    // Get current geolocation
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      // If geolocation fails, use default coordinates
      latitude = 1;
      longitude = 1;
    }

    // Update state with loading more status
    emit(state.copyWith(loadingMoreStatus: RequestStatus.loading));

    // Call NftRepository to get NFT benefits for load more case
    final benefitsRes = await _nftRepository.getNftBenefits(
      tokenAddress: state.selectedTokenAddress,
      latitude: latitude,
      longitude: longitude,
      pageSize: 10,
      page: state.nftBenefitList.isEmpty ? 1 : state.nftBenefitsPage + 1,
    );

    benefitsRes.fold(
        // If NftRepository call fails for load more case, update state with error message
        (l) => emit(state.copyWith(loadingMoreStatus: RequestStatus.failure)),
        // If NftRepository call succeeds for load more case, update state with fetched benefits
        (data) {
      final List<BenefitEntity> allList = List.from(state.nftBenefitList)
        ..addAll(data.benefits?.map((e) => e.toEntity()).toList() ?? []);

      // Remove duplicates based on `id`
      final uniqueResultList = removeDuplicates(allList);

      emit(state.copyWith(
        totalBenefitCount: data.benefitCount,
        isAllBenefitsLoaded: data.benefits?.isEmpty,
        nftBenefitList: uniqueResultList,
        loadingMoreStatus: RequestStatus.success,
        nftBenefitsPage:
            state.nftBenefitList.isEmpty ? 1 : state.nftBenefitsPage + 1,
      ));
    });
  }
}
