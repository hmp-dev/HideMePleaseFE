import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart';
import 'package:mobile/features/my/infrastructure/dtos/base_user_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/user_profile_dto.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<HMPError, BaseUserDto>> getBaseUserData() async {
    try {
      final response = await _remoteDataSource.getBaseUserData();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, UserProfileDto>> updateProfileData({
    required UpdateProfileRequestDto updateProfileRequestDto,
  }) async {
    try {
      final response = await _remoteDataSource.putProfileData(
          updateProfileRequestDto: updateProfileRequestDto);
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, UserProfileDto>> getUserProfileData() async {
    try {
      final response = await _remoteDataSource.getProfileData();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, bool>> getRequestCheckNickNameExists(
      String nickName) async {
    try {
      final response = await _remoteDataSource.checkNickNameExist(nickName);
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, Unit>> updateUserLocation(
      {required double latitude, required double longitude}) async {
    try {
      await _remoteDataSource.updateUserLocation(
          latitude: latitude, longitude: longitude);
      return right(unit);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }
}
