import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_benefit_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/welcome_nft_dto.dart';

abstract class NftRepository {
  Future<Either<HMPError, NftCollectionsGroupDto>> getNftCollections({
    String? chain,
    String? nextCursor,
  });

  Future<Either<HMPError, bool>> postNftSelectDeselectToken({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  });

  Future<Either<HMPError, bool>> postCollectionOrderSave({
    required SaveSelectedTokensReorderRequestDto
        saveSelectedTokensReorderRequestDto,
  });

  Future<Either<HMPError, List<SelectedNFTDto>>> getSelectNftCollections();

  Future<Either<HMPError, WelcomeNftDto>> getWelcomeNft();

  Future<Either<HMPError, String>> getConsumeUserWelcomeNft({
    required int welcomeNftId,
  });

  Future<Either<HMPError, List<NftBenefitDto>>> getNftBenefits(
      {required String tokenAddress});
}
