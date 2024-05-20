import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';

abstract class SpaceRepository {
  Future<Either<HMPError, SpacesResponseDto>> getSpacesData({
    required String tokenAddress,
    required String latitude,
    required String longitude,
  });
}
