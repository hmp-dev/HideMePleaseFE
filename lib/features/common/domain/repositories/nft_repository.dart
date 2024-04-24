import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';

abstract class NftRepository {
  Future<Either<HMPError, NftCollectionsGroupDto>> getNftCollections();
}
