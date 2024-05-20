import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';

@LazySingleton(as: SpaceRepository)
class SpaceRepositoryImpl extends SpaceRepository {
  final SpaceRemoteDataSource _spaceRemoteDataSource;

  SpaceRepositoryImpl(this._spaceRemoteDataSource);

  @override
  Future<Either<HMPError, SpacesResponseDto>> getSpacesData({
    required String tokenAddress,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _spaceRemoteDataSource.getNearBySpacesList(
        tokenAddress: tokenAddress,
        latitude: latitude,
        longitude: longitude,
      );
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
  Future<Either<HMPError, String>> getBackdoorToken({
    required String spaceId,
  }) async {
    try {
      final response =
          await _spaceRemoteDataSource.getBackdoorToken(spaceId: spaceId);
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
  Future<Either<HMPError, bool>> postRedeemBenefit(
      {required String benefitId,
      required String tokenAddress,
      required String nfcToken}) async {
    try {
      final response = await _spaceRemoteDataSource.postRedeemBenefit(
        benefitId: benefitId,
        tokenAddress: tokenAddress,
        nfcToken: nfcToken,
      );
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
}
