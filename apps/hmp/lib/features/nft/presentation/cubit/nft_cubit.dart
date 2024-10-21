// ignore_for_file: unused_field

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/core/enum/usage_type_enum.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/community/presentation/cubit/community_cubit.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
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
  final ProfileRepository _profileRepository;

  NftCubit(
    this._nftRepository,
    this._profileRepository,
  ) : super(NftState.initial());

  final SnackbarService snackbarService = getIt<SnackbarService>();
  List<SelectedNFTEntity> _selectedNftTokensListCached = [];

  /// Fetches NFT collections from the repository based on the provided parameters.
  ///
  /// Parameters:
  /// - [chain]: The chain type to filter the collections by.
  /// - [nextCursor]: The cursor to fetch the next page of collections.
  /// - [isLoadMoreFetch]: Whether the fetch is for loading more collections.
  /// - [isChainTypeFetchTapped]: Whether the chain type fetch button was tapped.
  /// - [isLoadingMore]: Whether the UI is in the loading more state.
  ///
  /// Emits the updated state with the fetched collections and other relevant information.
  Future<void> onGetNftCollections({
    String? chain,
    String? nextCursor,
    bool isLoadMoreFetch = false,
    bool? isChainTypeFetchTapped,
    bool? isLoadingMore,
  }) async {
    // If it's a load more fetch and there's no next cursor, return early
    if (isLoadMoreFetch && state.nextCursor.isEmpty) {
      return;
    }

    // Update the selected chain in the state
    emit(state.copyWith(selectedChain: chain));

    // If the chain type fetch button was tapped, reset the nftCollectionsGroupEntity in the state
    if (isChainTypeFetchTapped == true) {
      emit(
        state.copyWith(
          nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        ),
      );
    }

    // Set the isLoadingMore flag in the state to true
    emit(state.copyWith(isLoadingMore: true));

    // Fetch the NFT collections from the repository
    final response = await _nftRepository.getNftCollections(
      chain: state.selectedChain != ChainType.ALL.name
          ? state.selectedChain
          : null,
      nextCursor: isLoadMoreFetch && state.nextCursor.isNotEmpty
          ? state.nextCursor
          : null,
    );

    // Handle the response
    response.fold(
      // If the response is an error, emit the updated state with the error message
      (err) {
        Log.error(err);
        emit(state.copyWith(
          isLoadingMore: false,
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If the response is successful, update the state with the fetched collections and other information
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
  /// Updates the group entity with new collections.
  ///
  /// Takes a [nftCollectionsGroup] of type [NftCollectionsGroupDto] as input.
  /// Converts the [nftCollectionsGroup] to an entity using the [toEntity] method
  /// of the [NftCollectionsGroupDto] class. If the resulting collections list is empty,
  /// returns the current state without any modifications. Otherwise, adds the new collections
  /// to the current list of collections and creates a new instance of [NftCollectionsGroupEntity]
  /// with the updated 'next' value and the new collections list.
  ///
  /// Returns the updated [NftCollectionsGroupEntity].
  NftCollectionsGroupEntity _updateGroupWithNewCollections(
      NftCollectionsGroupDto nftCollectionsGroup) {
    // Convert the input to an entity
    final result = nftCollectionsGroup.toEntity();

    if (result.collections.isEmpty) {
      // If collections list is empty, return the current state without any modifications
      return state.nftCollectionsGroupEntity;
    }

    // Add collections to the current list

    // Create a copy of the current collections list
    List<NftCollectionEntity> collections =
        List.from(state.nftCollectionsGroupEntity.collections);
    // Add the new collections to the current list
    collections.addAll(result.collections);

    // Create a new instance of NftCollectionsGroupEntity with updated 'next' value
    // and the new collections list
    final updatedGroupEntity = state.nftCollectionsGroupEntity.copyWith(
      next: result.next,
      selectedNftCount: result.selectedNftCount,
      collections: collections,
    );

    // Return the updated group entity
    return updatedGroupEntity;
  }

  /// Handles the selection or deselection of an NFT token.
  ///
  /// Updates the selected status of the token and emits the updated state.
  /// If the user tries to select more tokens than the maximum allowed,
  /// the function returns early.
  ///
  /// If the token is already selected and the user tries to select more tokens
  /// from the same collection, the function returns early.
  ///
  /// The function also updates the selected nft collection count.
  ///
  /// Parameters:
  /// - [collectionIndex]: The index of the collection in the state.
  /// - [requestDto]: The request data for posting the token selection/deselection.
  /// - [selectedNft]: The selected NFT token.
  /// - [selected]: The selected status of the token.
  Future<void> onSelectDeselectNftToken({
    required int collectionIndex,
    required SelectTokenToggleRequestDto requestDto,
    required NftTokenEntity selectedNft,
    required bool selected,
  }) async {
    // If the user tries to select more tokens than the maximum allowed,
    // or if the token is already selected and the user tries to select
    // more tokens from the same collection, return early.
    if (state.selectedCollectionCount >= state.maxSelectableCount &&
        selected &&
        !state.nftCollectionsGroupEntity.collections[collectionIndex].tokens
            .any((element) => element.selected)) {
      return;
    }

    // Update the selected status of the token.
    final collections = List<NftCollectionEntity>.from(
        state.nftCollectionsGroupEntity.collections);
    final tokenIdx = collections[collectionIndex]
        .tokens
        .indexWhere((element) => element.id == selectedNft.id);
    if (tokenIdx >= 0) {
      final tokens = List<NftTokenEntity>.from(collections[collectionIndex]
          .tokens
          .map((e) => e.copyWith(selected: false))
          .toList());
      tokens[tokenIdx] = collections[collectionIndex]
          .tokens[tokenIdx]
          .copyWith(selected: selected);
      collections[collectionIndex] =
          collections[collectionIndex].copyWith(tokens: tokens);
    }

    // Update the selected nft collection count.
    final nftCollectionsGroupEntity =
        state.nftCollectionsGroupEntity.copyWith(collections: collections);
    final selectedCollectionCount = nftCollectionsGroupEntity.collections.fold(
        state.selectedNftTokensList
            .where((element) => !nftCollectionsGroupEntity.collections.any(
                (nftCollectionElement) =>
                    nftCollectionElement.tokenAddress == element.tokenAddress))
            .length,
        (value, element) =>
            element.tokens.where((element) => element.selected).length + value);

    // Emit the updated state.
    emit(state.copyWith(
      nftCollectionsGroupEntity: nftCollectionsGroupEntity,
      selectedCollectionCount: selectedCollectionCount,
    ));

    // Post the token selection/deselection request.
    final response = await _nftRepository.postNftSelectDeselectToken(
        selectTokenToggleRequestDto: requestDto);

    response.fold(
      (err) {
        // Handle error response.
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (nftCollectionsGroup) {
        // Handle successful response.
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }

  /// Retrieves the selected NFT tokens via the after welcome NFT fetch.
  ///
  /// This function first emits a new state with an empty list for
  /// `selectedNftTokensList` and a loading status for `submitStatus`.
  ///
  /// Then, it calls the `_nftRepository.getSelectNftCollections` method to
  /// retrieve the selected NFT tokens.
  ///
  /// If the retrieval is successful, it maps the response to a list of
  /// `SelectedNFTDto` entities and converts them to a list of `SelectedNFTEntity`
  /// entities. It assigns this list to `_selectedNftTokensListCached` and
  /// emits a new state with the converted list for `selectedNftTokensList`, a
  /// transformed list for `nftsListHome`, a success status for `submitStatus`,
  /// an empty string for `errorMessage`, and the length of the converted list
  /// for `selectedCollectionCount`.
  ///
  /// If the retrieval fails, it emits a new state with a failure status for
  /// `submitStatus` and an error message obtained from the `LocaleKeys.somethingError.tr()`
  /// function.
  Future<void> onGetSelectedNftTokensViaAfterWelcomeNftFetch({
    required bool isFreeNftAvailable,
  }) async {
    // Emit a new state with an empty list for selectedNftTokensList and a loading status for submitStatus
    emit(state.copyWith(
      selectedNftTokensList: [],
      submitStatus: RequestStatus.loading,
    ));

    // Call the _nftRepository.getSelectNftCollections method to retrieve the selected NFT tokens
    final response = await _nftRepository.getSelectNftCollections();

    // Handle the response
    response.fold(
      // If the retrieval fails, log the error and emit a new state with a failure status for submitStatus and an error message obtained from the LocaleKeys.somethingError.tr() function
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If the retrieval is successful, map the response to a list of SelectedNFTDto entities and convert them to a list of SelectedNFTEntity entities. Assign this list to _selectedNftTokensListCached and emit a new state with the converted list for selectedNftTokensList, a transformed list for nftsListHome, a success status for submitStatus, an empty string for errorMessage, and the length of the converted list for selectedCollectionCount.
      (selectedNftTokensList) {
        final resultList =
            selectedNftTokensList.map((e) => e.toEntity()).toList();

        _selectedNftTokensListCached = List.from(resultList);

        emit(
          state.copyWith(
            selectedNftTokensList: resultList,
            nftsListHome: getNftListForHomeWithEmptyAt1stAndLast(
                resultList, isFreeNftAvailable),
            submitStatus: RequestStatus.success,
            errorMessage: '',
            selectedCollectionCount: resultList.length,
          ),
        );
      },
    );
  }

  /// Retrieves the selected NFT tokens and updates the state accordingly.
  ///
  /// This function first retrieves the current position using the Geolocator
  /// package. If the retrieval is successful, it assigns the latitude and
  /// longitude values to the `latitude` and `longitude` variables respectively.
  /// If the retrieval fails, it assigns default values of 1 to both variables.
  ///
  /// Then, it calls the `_nftRepository.getWelcomeNft` method with the latitude
  /// and longitude values to retrieve the welcome NFT data. The response is
  /// handled using the `fold` method. If the response is successful (`fold`
  /// first parameter is null), it emits the `state` with the welcome NFT entity
  /// updated. It also checks if the free NFT is available and assigns the value
  /// to the `isFreeNftAvailable` variable.
  ///
  /// After that, it calls the `_nftRepository.getSelectNftCollections` method
  /// to retrieve the selected NFT tokens. The response is handled using the `fold`
  /// method. If the response is successful (`fold` first parameter is null), it
  /// maps the `selectedNftTokensList` to a list of entities and assigns it to
  /// the `resultList` variable. It emits the `state` with the selected NFT tokens
  /// list, the NFTs list for the home screen, the submit status, error message,
  /// selected collection count, and the welcome NFT entity updated.
  ///
  /// If the response is unsuccessful (`fold` first parameter is not null), it
  /// logs the error and emits the `state` with the submit status and error message
  /// updated.
  Future<void> onGetSelectedNftTokens() async {
    // Retrieve the current position
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

    // Retrieve the welcome NFT data
    final welcomeNFtResponse = await _nftRepository.getWelcomeNft(
      latitude: latitude,
      longitude: longitude,
    );

    welcomeNFtResponse.fold(
      // Handle the welcome NFT data response
      (err) {},
      (welcomeNftData) async {
        // Update the state with the welcome NFT entity
        emit(state.copyWith(
          welcomeNftEntity: welcomeNftData.toEntity(),
        ));

        // Check if the free NFT is available
        final isFreeNftAvailable = welcomeNftData.freeNftAvailable ?? false;

        // Retrieve the selected NFT tokens
        final response = await _nftRepository.getSelectNftCollections();

        response.fold(
          // Handle the selected NFT tokens response
          (err) {
            Log.error(err);
            // Update the state with failure status and error message
            emit(state.copyWith(
              submitStatus: RequestStatus.failure,
              errorMessage: LocaleKeys.somethingError.tr(),
            ));
          },
          (selectedNftTokensList) {
            final resultList =
                selectedNftTokensList.map((e) => e.toEntity()).toList();

            // Update the state with the selected NFT tokens list,
            // the NFTs list for the home screen, the submit status,
            // error message, selected collection count, and the
            // welcome NFT entity updated.
            emit(
              state.copyWith(
                selectedNftTokensList: resultList,
                nftsListHome: getNftListForHomeWithEmptyAt1stAndLast(
                    resultList, isFreeNftAvailable),
                submitStatus: RequestStatus.success,
                errorMessage: '',
                selectedCollectionCount: resultList.length,
                welcomeNftEntity: welcomeNftData.toEntity(),
              ),
            );
          },
        );
      },
    );
  }

  /// Returns a list of selected NFT entities with an empty entity at the end
  /// and an optional entity at the beginning if the free NFT is available.
  ///
  /// The [resultList] parameter is the list of selected NFT entities.
  /// The [isFreeNftAvailable] parameter is a boolean indicating whether the free NFT is available.
  ///
  /// Returns a list of selected NFT entities with an empty entity at the end
  /// and an optional entity at the beginning if the free NFT is available.
  List<SelectedNFTEntity> getNftListForHomeWithEmptyAt1stAndLast(
    List<SelectedNFTEntity> resultList,
    bool isFreeNftAvailable,
  ) {
    // Create a mutable copy of the result list
    List<SelectedNFTEntity> result = List.from(resultList);

    // Add an empty entity at the end of the result list
    result.add(const SelectedNFTEntity.empty());

    // If the free NFT is available, add an empty entity at the beginning of the result list
    if (isFreeNftAvailable) {
      result.insert(0, const SelectedNFTEntity.emptyForHome1st());
    }

    // Return the result list
    return result;
  }

  /// Updates the order of selected NFT collections and saves the changes.
  ///
  /// This method checks if there are any selected NFT collections and if their
  /// order has changed since the last save. If the order has changed, it creates
  /// a request object with the new order and calls the [NftRepository.postCollectionOrderSave]
  /// method to save the changes. If the save is successful, it calls the
  /// [onGetSelectedNftTokens] method to refresh the selected NFT collections.
  /// Finally, it updates the state with the success status.
  Future<void> onCollectionOrderChanged() async {
    // Check if there are selected NFT collections and if their order has changed.
    if (state.selectedNftTokensList.isNotEmpty &&
        state.selectedNftTokensList != _selectedNftTokensListCached) {
      // Create a request object with the new order.
      final request = SaveSelectedTokensReorderRequestDto(
          order: state.selectedNftTokensList.map((e) => e.id).toList());
      // Call the repository method to save the changes.
      final response = await _nftRepository.postCollectionOrderSave(
          saveSelectedTokensReorderRequestDto: request);

      // Handle the response from the repository call.
      response.fold(
        // If there was an error, update the state with the failure status and error message.
        (err) {
          Log.error(err);
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        },
        // If the save was successful, refresh the selected NFT collections and update the state with the success status.
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

  /// Calls the [NftRepository.getWelcomeNft] method to get the welcome NFT.
  ///
  /// This method performs the following actions:
  /// 1. Retrieves the user's current location.
  /// 2. Calls the [NftRepository.getWelcomeNft] method to get the welcome NFT.
  /// 3. Emits the updated state.
  /// 4. Emits the welcome NFT state.
  /// 5. Calls the [onGetSelectedNftTokensViaAfterWelcomeNftFetch] method to get the selected NFTs.
  /// 6. Handles the response from the repository call.
  ///
  /// This method does not return anything.
  Future<void> onGetWelcomeNft() async {
    // Retrieve the user's current location
    double latitude = 1;
    double longitude = 1;
    try {
      final position = await Geolocator.getCurrentPosition();

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      // If the location cannot be retrieved, use default values
      latitude = 1;
      longitude = 1;
    }

    // Call the repository method to get the welcome NFT
    final response = await _nftRepository.getWelcomeNft(
      latitude: latitude,
      longitude: longitude,
    );

    response.fold(
      // Handle error response
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // Handle success response
      (welcomeNft) {
        // Fetch selected NFTs
        final isFreeNftAvailable = welcomeNft.freeNftAvailable ?? false;

        // Fetch Selected NFTs
        onGetSelectedNftTokensViaAfterWelcomeNftFetch(
          isFreeNftAvailable: isFreeNftAvailable,
        );

        // Emit welcome NFT state
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

  /// Calls the [NftRepository.getConsumeUserWelcomeNft] method to consume the user's welcome NFT.
  ///
  /// This method performs the following actions:
  /// 1. Shows a loading indicator.
  /// 2. Calls the [NftRepository.getConsumeUserWelcomeNft] method to consume the user's welcome NFT.
  /// 3. Dismisses the loading indicator.
  /// 4. Handles the response from the repository call.
  /// 5. Emits the updated state.
  /// 6. Shows a success or error message based on the response.
  ///
  /// Returns a [Future] that completes when the method is done executing.
  Future<void> onGetConsumeWelcomeNft() async {
    // Show loading indicator
    EasyLoading.show();

    // Call NftRepository to consume the user's welcome NFT
    final response = await _nftRepository.getConsumeUserWelcomeNft(
        tokenAddress: state.welcomeNftEntity.tokenAddress);

    // Dismiss loading indicator
    EasyLoading.dismiss();

    // Handle response from the repository call
    response.fold(
      // If the repository call fails, update state with error message
      (err) {
        // Dismiss loading indicator
        EasyLoading.dismiss();
        Log.error(err);

        // Update state with failure status and error message
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));

        // Show error snackbar
        snackbarService.showSnackbar(
          title: "Error",
          message: err.message,
          duration: const Duration(seconds: 5),
        );
      },
      // If the repository call succeeds, update state and show success message
      (_) async {
        // Call onGetWelcomeNft to fetch welcome NFT data
        await onGetWelcomeNft();

        // Refresh user NFT communities
        getIt<CommunityCubit>().onGetUserNftCommunities();

        // Update state with success status and empty error message
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
        ));

        // Show success snackbar
        snackbarService.showSnackbar(
          message: 'Free NFT가 발급중에 있습니다. 잠시만 기다려주세요',
          duration: const Duration(seconds: 5),
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

  /// Retrieves the points of the NFTs.
  ///
  /// This function calls the `_nftRepository.getNftPoints()` method to get the
  /// NFT points. It then handles the response and updates the state accordingly.
  /// If the response is successful, it converts the response list of `NftPointsDto`
  /// to a list of `NftPointsEntity` and updates the state with the new list.
  /// If the response is unsuccessful, it logs the error and updates the state
  /// with the failure status and an error message.
  Future<void> onGetNftPoints() async {
    // Call the repository to get the NFT points
    final response = await _nftRepository.getNftPoints();

    // Handle the response
    response.fold(
      // If the response is unsuccessful
      (err) {
        // Log the error
        Log.error(err);
        // Update the state with the failure status and an error message
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If the response is successful
      (nftPointsList) {
        // Convert the response list of NftPointsDto to a list of NftPointsEntity
        final resultList = nftPointsList.map((e) => e.toEntity()).toList();

        // Update the state with the new list and success status
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

  /// Retrieves the network information of an NFT based on the provided token address.
  ///
  /// Parameters:
  /// - [tokenAddress]: The address of the NFT.
  Future<void> onGetNftNetworkInfo({required String tokenAddress}) async {
    // Call the repository to get the network information of the NFT
    final response =
        await _nftRepository.getNftNetworkInfo(tokenAddress: tokenAddress);

    // Handle the response based on its outcome
    response.fold(
      // If there is an error, log it and update the state with the failure status and error message
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // If the response is successful, update the state with the network information and success status
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

  /// Retrieves the usage history of an NFT based on the provided parameters.
  ///
  /// Parameters:
  /// - [tokenAddress]: The address of the NFT.
  /// - [order]: The order in which the history should be sorted.
  /// - [page]: The page number of the history.
  /// - [type]: The type of usage to retrieve.
  Future<void> onGetNftUsageHistory({
    required String tokenAddress,
    String? order,
    String? page,
    BenefitUsageType? type,
  }) async {
    // Show loading indicator
    EasyLoading.show();

    // Set initial state with submission status and usage type
    emit(state.copyWith(
      submitStatus: RequestStatus.failure,
      errorMessage: LocaleKeys.somethingError.tr(),
      benefitUsageType: type ?? BenefitUsageType.ENTIRE,
    ));

    // Retrieve the NFT usage history from the repository
    final response = await _nftRepository.getNftUsageHistory(
      tokenAddress: tokenAddress,
      order: order,
      page: page,
      type: type?.name,
    );

    // Dismiss the loading indicator
    EasyLoading.dismiss();

    // Handle the response
    response.fold(
      // Handle error
      (err) {
        Log.error(err);
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // Handle success
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
