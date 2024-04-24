import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';

abstract class NftRepository {
  Future<Either<HMPError, NftCollectionsGroupDto>> getNftCollections();

  Future<Either<HMPError, bool>> postNftSelectDeselectToken({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  });

  //

  Future<Either<HMPError, List<SelectedNFTDto>>> getSelectNftTokensList();
}
