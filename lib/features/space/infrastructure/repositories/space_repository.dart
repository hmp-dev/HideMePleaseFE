import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefits_group_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/new_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/recommendation_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_detail_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/top_used_nft_dto.dart';

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
  Future<Either<HMPError, bool>> postRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String spaceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _spaceRemoteDataSource.postRedeemBenefit(
        benefitId: benefitId,
        tokenAddress: tokenAddress,
        spaceId: spaceId,
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
  Future<Either<HMPError, List<TopUsedNftDto>>> getTopUsedNfts() async {
    try {
      final response = await _spaceRemoteDataSource.requestGetTopUsedNfts();
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
  Future<Either<HMPError, List<NewSpaceDto>>> getNewsSpaceList() async {
    try {
      final response = await _spaceRemoteDataSource.requestGetNewSpaceList();
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
  Future<Either<HMPError, List<SpaceDto>>> getSpaceList({
    String? category,
    int? page,
  }) async {
    try {
      final response = await _spaceRemoteDataSource.requestGetSpaceList(
        category: category,
        page: page,
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
  Future<Either<HMPError, List<RecommendationSpaceDto>>>
      getRecommendedSpaces() async {
    try {
      final response =
          await _spaceRemoteDataSource.requestGetRecommendedSpaces();
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
  Future<Either<HMPError, SpaceDetailDto>> getSpaceDetail(
      {required String spaceId}) async {
    try {
      final response = await _spaceRemoteDataSource.requestGetSpaceDetail(
        spaceId: spaceId,
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
  Future<Either<HMPError, BenefitsGroupDto>> getSpaceBenefits({
    required String spaceId,
  }) async {
    try {
      final response = await _spaceRemoteDataSource.requestGetSpaceBenefits(
        spaceId: spaceId,
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
