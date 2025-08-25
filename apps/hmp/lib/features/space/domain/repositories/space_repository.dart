import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefits_group_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_response_dto.dart';
import 'package:mobile/features/space/domain/entities/check_in_status_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/new_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/recommendation_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_detail_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/top_used_nft_dto.dart';

abstract class SpaceRepository {
  Future<Either<HMPError, SpacesResponseDto>> getNearBySpacesListData({
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
    required String spaceId,
    required double latitude,
    required double longitude,
  });

  Future<Either<HMPError, List<TopUsedNftDto>>> getTopUsedNfts();
  //

  Future<Either<HMPError, List<NewSpaceDto>>> getNewsSpaceList();

  Future<Either<HMPError, List<SpaceDto>>> getSpaceList({
    String? category,
    int? page,
    required double latitude,
    required double longitude,
  });

  Future<Either<HMPError, List<RecommendationSpaceDto>>> getRecommendedSpaces();

  Future<Either<HMPError, SpaceDetailDto>> getSpaceDetail(
      {required String spaceId});

  Future<Either<HMPError, BenefitsGroupDto>> getSpaceBenefits({
    required String spaceId,
  });

  Future<Either<HMPError, CheckInResponseDto>> checkIn({
    required String spaceId,
    required double latitude,
    required double longitude,
  });

  Future<Either<HMPError, CheckInStatusEntity>> getCheckInStatus({
    required String spaceId,
  });
}
