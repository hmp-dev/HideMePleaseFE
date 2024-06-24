import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/core/enum/usage_type_enum.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_collection_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_collections_group_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_network_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_token_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_usage_history_entity.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/select_token_toggle_request_dto.dart';
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
  List<SelectedNFTEntity> _selectedNftTokensListCached = [];

  Future<void> onGetNftCollections({
    String? chain,
    String? nextCursor,
    bool isLoadMoreFetch = false,
    bool? isChainTypeFetchTapped,
    bool? isLoadingMore,
  }) async {
    if(isLoadMoreFetch && state.nextCursor.isEmpty) {
      return;
    }
    
    emit(state.copyWith(selectedChain: chain));
    // if isChainTypeFetchTapped is true, then reset the nftCollectionsGroupEntity
    if (isChainTypeFetchTapped == true) {
      emit(
        state.copyWith(
          nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        ),
      );
    }

    // set isLoadingMore to true
    emit(state.copyWith(isLoadingMore: true));

    final response = await _nftRepository.getNftCollections(
      chain: state.selectedChain != ChainType.ALL.name
          ? state.selectedChain
          : null,
      nextCursor: isLoadMoreFetch && state.nextCursor.isNotEmpty
          ? state.nextCursor
          : null,
    );

    response.fold(
      (err) {
        Log.error(err); // Log the error
        emit(state.copyWith(
          isLoadingMore: false,
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftCollectionsGroup) {
        final updatedGroupEntity = isLoadMoreFetch == true
            ? _updateGroupWithNewCollections(nftCollectionsGroup)
            : nftCollectionsGroup.toEntity();

        emit(state.copyWith(
          isLoadingMore: false,
          submitStatus: RequestStatus.success,
          errorMessage: '',
          nftCollectionsGroupEntity: updatedGroupEntity,
          collectionFetchTime: DateTime.now(),
          nextCursor: nftCollectionsGroup.next ?? '',
        ));
      },
    );
  }

// Helper function to update group entity with new collections
  NftCollectionsGroupEntity _updateGroupWithNewCollections(
      NftCollectionsGroupDto nftCollectionsGroup) {
    final result = nftCollectionsGroup.toEntity();

    if (result.collections.isEmpty) {
      // If collections list is empty, return the current state without any modifications
      return state.nftCollectionsGroupEntity;
    }

    // Add collections to the current list

    List<NftCollectionEntity> collections =
        List.from(state.nftCollectionsGroupEntity.collections);
    collections.addAll(result.collections);

    // Create a new instance of NftCollectionsGroupEntity with updated 'next' value
    final updatedGroupEntity = state.nftCollectionsGroupEntity.copyWith(
      next: result.next,
      selectedNftCount: result.selectedNftCount,
      collections: collections,
    );

    return updatedGroupEntity;
  }

  Future<void> onSelectDeselectNftToken({
    required SelectTokenToggleRequestDto requestDto,
    required NftTokenEntity selectedNft,
  }) async {
    //  emit(
    //       state.copyWith(
    //         selectedNftTokensList: state.selectedNftTokensList..add(value),));
    final response = await _nftRepository.postNftSelectDeselectToken(
        selectTokenToggleRequestDto: requestDto);

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

  Future<void> onGetSelectedNftTokens({
    bool isShowLoader = true,
  }) async {
    final response = await _nftRepository.getSelectNftCollections();

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

        _selectedNftTokensListCached = List.from(resultList);

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

  List<SelectedNFTEntity> getNftListForHomeWithEmptyAt1stAndLast(
      List<SelectedNFTEntity> resultList) {
    List<SelectedNFTEntity> result = List.from(resultList);
    //

    result.add(const SelectedNFTEntity.empty());

    result.insert(0, const SelectedNFTEntity.emptyForHome1st());

    Log.info("result.length: ${result.length}");
    Log.info("result[0].imageUrl: ${result[0].imageUrl}");

    return result;
  }

  Future<void> onCollectionOrderChanged() async {
    if (state.selectedNftTokensList.isNotEmpty &&
        state.selectedNftTokensList != _selectedNftTokensListCached) {
      final request = SaveSelectedTokensReorderRequestDto(
          order: state.selectedNftTokensList.map((e) => e.id).toList());
      final response = await _nftRepository.postCollectionOrderSave(
          saveSelectedTokensReorderRequestDto: request);

      response.fold(
        (err) {
          Log.error(err);
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        },
        (nftCollectionsGroup) {
          onGetSelectedNftTokens();

          emit(
            state.copyWith(
              submitStatus: RequestStatus.success,
              errorMessage: '',
            ),
          );
        },
      );
    }
  }

  Future<void> onGetWelcomeNft({bool isShowLoader = true}) async {
    if (isShowLoader) {
      EasyLoading.show();
    }

    final response = await _nftRepository.getWelcomeNft();

    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

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

  // Future<void> onGetNftBenefits({
  //   required String tokenAddress,
  //   String? spaceId,
  //   int? pageSize,
  //   int? page,
  //   bool isShowLoading = false,
  // }) async {
  //   if (isShowLoading) EasyLoading.show();

  //   final response = await _nftRepository.getNftBenefits(
  //     tokenAddress: tokenAddress,
  //     spaceId: spaceId,
  //     pageSize: pageSize,
  //     page: page,
  //   );
  //   if (isShowLoading) EasyLoading.dismiss();

  //   response.fold(
  //     (err) {
  //       Log.error(err);
  //       emit(state.copyWith(
  //         submitStatus: RequestStatus.failure,
  //         errorMessage: LocaleKeys.somethingError.tr(),
  //       ));
  //     },
  //     (nftBenefitsList) {
  //       final resultList =
  //           nftBenefitsList.benefits?.map((e) => e.toEntity()).toList() ?? [];

  //       emit(
  //         state.copyWith(
  //           nftBenefitList: resultList,
  //           submitStatus: RequestStatus.success,
  //           errorMessage: '',
  //         ),
  //       );
  //     },
  //   );
  // }

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
    BenefitUsageType? type,
  }) async {
    EasyLoading.show();

    emit(state.copyWith(
      submitStatus: RequestStatus.failure,
      errorMessage: LocaleKeys.somethingError.tr(),
      benefitUsageType: type ?? BenefitUsageType.ENTIRE,
    ));

    final response = await _nftRepository.getNftUsageHistory(
      tokenAddress: tokenAddress,
      order: order,
      page: page,
      type: type?.name,
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
