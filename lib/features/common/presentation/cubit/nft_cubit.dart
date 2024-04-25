import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/common/domain/entities/nft_collections_group_entity.dart';
import 'package:mobile/features/common/domain/repositories/nft_repository.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';

part 'nft_state.dart';

@lazySingleton
class NftCubit extends BaseCubit<NftState> {
  final NftRepository _nftRepository;

  NftCubit(
    this._nftRepository,
  ) : super(NftState.initial());

  Future<void> onGetNftCollections() async {
    EasyLoading.show();

    final response = await _nftRepository.getNftCollections();

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
            nftCollectionsGroupEntity: nftCollectionsGroup.toEntity(),
          ),
        );
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

    final response = await _nftRepository.getSelectNftTokensList();

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
        emit(
          state.copyWith(
            selectedNftTokensList: selectedNftTokensList,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }
}
