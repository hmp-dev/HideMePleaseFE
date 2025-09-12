import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/space/domain/entities/check_in_status_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefit_redeem_error_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefits_group_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/new_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/recommendation_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_detail_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';
import 'package:mobile/features/space/domain/entities/check_in_users_response_entity.dart';
import 'package:mobile/features/space/domain/entities/current_group_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/top_used_nft_dto.dart';

@LazySingleton(as: SpaceRepository)
class SpaceRepositoryImpl extends SpaceRepository {
  final SpaceRemoteDataSource _spaceRemoteDataSource;

  SpaceRepositoryImpl(this._spaceRemoteDataSource);

  @override
  Future<Either<HMPError, SpacesResponseDto>> getNearBySpacesListData({
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
      "inside DioException $e".log();

      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } on BenefitRedeemErrorDto catch (e) {
      "inside Catch BenefitRedeemErrorDto $e".log();
      final error = e;
      return left(HMPError.fromNetwork(
        message: error.message,
        error: error.code,
      ));
    } catch (e, t) {
      "inside Catch $e".log();
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
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _spaceRemoteDataSource.requestGetSpaceList(
        category: category,
        page: page,
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
      final response =
          await _spaceRemoteDataSource.requestGetSpaceDetailBySpaceId(
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

  @override
  Future<Either<HMPError, CheckInResponseDto>> checkIn({
    required String spaceId,
    required double latitude,
    required double longitude,
    String? benefitId,
  }) async {
    try {
      print('🔍 Repository: Calling remote data source checkIn...');
      if (benefitId != null) {
        print('🎁 Repository: Including benefitId: $benefitId');
      }
      final response = await _spaceRemoteDataSource.checkIn(
        spaceId: spaceId,
        latitude: latitude,
        longitude: longitude,
        benefitId: benefitId,
      );
      print('✅ Repository: Check-in successful, returning right');
      return right(response);
    } on DioException catch (e, t) {
      print('❌ Repository: Caught DioException');
      print('   - Status code: ${e.response?.statusCode}');
      print('   - Response data: ${e.response?.data}');
      
      // 서버 응답에서 실제 에러 메시지 추출
      String? serverMessage;
      try {
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          serverMessage = responseData['message'] ?? e.message;
          print('   - Extracted message: $serverMessage');
        }
      } catch (_) {
        print('   - Failed to parse error message');
        // 파싱 실패 시 기본 메시지 사용
      }
      
      print('❌ Repository: Returning left with error message: ${serverMessage ?? e.message}');
      return left(HMPError.fromNetwork(
        message: serverMessage ?? e.message,
        error: e.response?.data?.toString() ?? e.toString(),
        trace: t,
      ));
    } catch (e, t) {
      print('❌ Repository: Caught unknown error: $e');
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, CheckInStatusEntity>> getCheckInStatus(
      {required String spaceId}) async {
    try {
      final response = await _spaceRemoteDataSource.getCheckInStatus(
        spaceId: spaceId,
      );
      return right(response.toEntity());
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
  Future<Either<HMPError, CheckInUsersResponseEntity>> getCheckInUsers(
      {required String spaceId}) async {
    try {
      final response = await _spaceRemoteDataSource.getCheckInUsers(
        spaceId: spaceId,
      );
      return right(response.toEntity());
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
  Future<Either<HMPError, CurrentGroupEntity>> getCurrentGroup(
      {required String spaceId}) async {
    try {
      final response = await _spaceRemoteDataSource.getCurrentGroup(
        spaceId: spaceId,
      );
      return right(response.toEntity());
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
  Future<Either<HMPError, bool>> checkOut({required String spaceId}) async {
    try {
      final response = await _spaceRemoteDataSource.checkOut(spaceId: spaceId);
      return right(response.success);
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
