import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/common/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/user_dto.dart';

abstract class ProfileRepository {
  Future<Either<HMPError, UserDto>> getProfileData();
  Future<Either<HMPError, UserDto>> updateProfileData({
    required UpdateProfileRequestDto updateProfileRequestDto,
  });
}
