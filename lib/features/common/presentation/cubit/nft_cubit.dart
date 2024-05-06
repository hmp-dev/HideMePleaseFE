import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/common/domain/entities/nft_collections_group_entity.dart';
import 'package:mobile/features/common/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/common/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/common/domain/repositories/nft_repository.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'nft_state.dart';

@lazySingleton
class NftCubit extends BaseCubit<NftState> {
  final NftRepository _nftRepository;

  NftCubit(
    this._nftRepository,
  ) : super(NftState.initial());

  Future<void> onGetNftCollections(
      {String? chain, String? nextCursor, bool? isLoadMoreFetch}) async {
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
          // reset the nftCollectionsGroupEntity
          emit(
            state.copyWith(
              nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
            ),
          );
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
        resultList.add(const SelectedNFTEntity.empty());
        resultList.insert(
            0,
            const SelectedNFTEntity(
              id: '',
              order: 0,
              name: 'Ready to Hide',
              symbol: '',
              chain: 'ETHEREUM',
              imageUrl: '',
            ));
        emit(
          state.copyWith(
            selectedNftTokensList: resultList,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
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
}
