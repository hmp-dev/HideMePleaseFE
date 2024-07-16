import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/my/infrastructure/dtos/base_user_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/user_profile_dto.dart';

abstract class ProfileRepository {
  Future<Either<HMPError, BaseUserDto>> getBaseUserData();

  Future<Either<HMPError, UserProfileDto>> getUserProfileData();

  Future<Either<HMPError, UserProfileDto>> getUserProfile(
      {required String userId});

  Future<Either<HMPError, UserProfileDto>> updateProfileData({
    required UpdateProfileRequestDto updateProfileRequestDto,
  });

  Future<Either<HMPError, bool>> getRequestCheckNickNameExists(String nickName);

  Future<Either<HMPError, Unit>> updateUserLocation({
    required double latitude,
    required double longitude,
  });
}
