import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';

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
}
