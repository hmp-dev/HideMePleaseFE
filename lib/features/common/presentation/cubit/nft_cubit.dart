import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/common/domain/entities/nft_benefit_entity.dart';
import 'package:mobile/features/common/domain/entities/nft_collections_group_entity.dart';
import 'package:mobile/features/common/domain/entities/nft_network_entity.dart';
import 'package:mobile/features/common/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/common/domain/entities/nft_usage_history_entity.dart';
import 'package:mobile/features/common/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/common/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/common/domain/repositories/nft_repository.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';

part 'nft_state.dart';

@lazySingleton
class NftCubit extends BaseCubit<NftState> {
  final NftRepository _nftRepository;

  NftCubit(
    this._nftRepository,
  ) : super(NftState.initial());

  final SnackbarService snackbarService = getIt<SnackbarService>();

  Future<void> onGetNftCollections({
    String? chain,
    String? nextCursor,
    bool? isLoadMoreFetch,
  }) async {
    EasyLoading.show();

    final response = await _nftRepository.getNftCollections(
      chain: chain,
      nextCursor: nextCursor,
    );

    EasyLoading.dismiss();
    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftCollectionsGroup) {
        if (isLoadMoreFetch == true) {
          NftCollectionsGroupEntity result = nftCollectionsGroup.toEntity();
          // Create a new instance of NftCollectionsGroupEntity with updated 'next' value
          NftCollectionsGroupEntity updatedGroupEntity =
              state.nftCollectionsGroupEntity.copyWith(next: result.next);

          // Add collections to the current list
          updatedGroupEntity.collections.addAll(result.collections);

          emit(
            state.copyWith(
              submitStatus: RequestStatus.success,
              errorMessage: '',
              nftCollectionsGroupEntity: updatedGroupEntity,
              collectionFetchTime: DateTime.now(),
              selectedChain: chain ?? ChainType.ALL.name,
            ),
          );
        } else {
          // Reset the nftCollectionsGroupEntity
          emit(
            state.copyWith(
              submitStatus: RequestStatus.success,
              errorMessage: '',
              nftCollectionsGroupEntity: nftCollectionsGroup.toEntity(),
              collectionFetchTime: DateTime.now(),
              selectedChain: chain ?? ChainType.ALL.name,
            ),
          );
        }
      },
    );
  }

  Future<void> onSelectDeselectNftToken({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  }) async {
    EasyLoading.show();

    final response = await _nftRepository.postNftSelectDeselectToken(
        selectTokenToggleRequestDto: selectTokenToggleRequestDto);

    EasyLoading.dismiss();

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftCollectionsGroup) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );

        // call the NFT Collections Again
        onGetNftCollections();
        onGetSelectedNftTokens();
      },
    );
  }

  Future<void> onGetSelectedNftTokens() async {
    EasyLoading.show();

    final response = await _nftRepository.getSelectNftCollections();

    EasyLoading.dismiss();

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (selectedNftTokensList) {
        final resultList =
            selectedNftTokensList.map((e) => e.toEntity()).toList();

        emit(
          state.copyWith(
            selectedNftTokensList: resultList,
            nftsListHome: getNftListForHomeWithEmptyAt1stAndLast(resultList),
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  getNftListForHomeWithEmptyAt1stAndLast(List<SelectedNFTEntity> resultList) {
    List<SelectedNFTEntity> result = List.from(resultList);
    //
    result.insert(0, const SelectedNFTEntity.emptyForHome1st());
    result.add(const SelectedNFTEntity.empty());

    return result;
  }

  Future<void> onPostCollectionOrderSave({
    required SaveSelectedTokensReorderRequestDto
        saveSelectedTokensReorderRequestDto,
  }) async {
    EasyLoading.show();

    final response = await _nftRepository.postCollectionOrderSave(
        saveSelectedTokensReorderRequestDto:
            saveSelectedTokensReorderRequestDto);

    EasyLoading.dismiss();

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftCollectionsGroup) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  Future<void> onGetWelcomeNft() async {
    EasyLoading.show();

    final response = await _nftRepository.getWelcomeNft();

    EasyLoading.dismiss();

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (welcomeNft) {
        emit(
          state.copyWith(
            welcomeNftEntity: welcomeNft.toEntity(),
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  Future<void> onGetConsumeWelcomeNft({
    required int welcomeNftId,
  }) async {
    EasyLoading.show();

    final response = await _nftRepository.getConsumeUserWelcomeNft(
        welcomeNftId: welcomeNftId);

    EasyLoading.dismiss();

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));

        snackbarService.showSnackbar(
          title: "Error",
          message: err.message,
        );
      },
      (url) {
        emit(
          state.copyWith(
            consumeWelcomeNftUrl: url,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  Future<void> onGetNftBenefits({required String tokenAddress}) async {
    final response =
        await _nftRepository.getNftBenefits(tokenAddress: tokenAddress);

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftBenefitsList) {
        final resultList = nftBenefitsList.map((e) => e.toEntity()).toList();

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

  Future<void> onGetNftPoints() async {
    final response = await _nftRepository.getNftPoints();

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftPointsList) {
        final resultList = nftPointsList.map((e) => e.toEntity()).toList();

        emit(
          state.copyWith(
            nftPointsList: resultList,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  Future<void> onGetNftNetworkInfo({required String tokenAddress}) async {
    final response =
        await _nftRepository.getNftNetworkInfo(tokenAddress: tokenAddress);

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (networkInfo) {
        emit(
          state.copyWith(
            nftNetworkEntity: networkInfo.toEntity(),
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  Future<void> onGetNftUsageHistory({
    required String tokenAddress,
    String? order,
    String? page,
    String? type,
  }) async {
    final response = await _nftRepository.getNftUsageHistory(
      tokenAddress: tokenAddress,
      order: order,
      page: page,
      type: type,
    );

    response.fold(
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (usageHistory) {
        emit(
          state.copyWith(
            nftUsageHistoryEntity: usageHistory.toEntity(),
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }
}
