import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/infrastructure/dtos/new_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/top_used_nft_dto.dart';

abstract class SpaceRepository {
  Future<Either<HMPError, SpacesResponseDto>> getSpacesData({
    required String tokenAddress,
    required double latitude,
    required double longitude,
  });

  Future<Either<HMPError, String>> getBackdoorToken({
    required String spaceId,
  });

  Future<Either<HMPError, bool>> postRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String nfcToken,
  });

  Future<Either<HMPError, List<TopUsedNftDto>>> getTopUsedNfts();
  //

  Future<Either<HMPError, List<NewSpaceDto>>> getNewsSpaceList();

  Future<Either<HMPError, List<SpaceDto>>> getSpaceList({
    String? category,
    int? page,
  });
}
