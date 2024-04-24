import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/common/domain/entities/nft_collections_group_entity.dart';
import 'package:mobile/features/common/domain/repositories/nft_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'nft_state.dart';

@lazySingleton
class NftCubit extends BaseCubit<NftState> {
  final NftRepository _nftRepository;

  NftCubit(
    this._nftRepository,
  ) : super(NftState.initial());

  Future<void> onGetNftCollections() async {
    EasyLoading.show();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

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
}
