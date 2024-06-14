import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefit_redeem_error_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefits_group_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/new_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/recommendation_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_detail_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/top_used_nft_dto.dart';

@lazySingleton
class SpaceRemoteDataSource {
  final Network _network;

  SpaceRemoteDataSource(this._network);

  Future<SpacesResponseDto> getNearBySpacesList({
    required String tokenAddress,
    required double latitude,
    required double longitude,
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      'latitude': '$latitude',
      'longitude': '$longitude',
    };

    final response =
        await _network.get("nft/collection/$tokenAddress/spaces", queryParams);

    return SpacesResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> getBackdoorToken({required String spaceId}) async {
    final response =
        await _network.get("space/benefits/token-backdoor/$spaceId", {});

    return response.data;
  }

  // Future<bool> postRedeemBenefit({
  //   required String benefitId,
  //   required String tokenAddress,
  //   required String spaceId,
  //   required double latitude,
  //   required double longitude,
  // }) async {
  //   // Construct the query parameters
  //   final Map<String, dynamic> queryParams = {
  //     "latitude": latitude,
  //     "longitude": longitude,
  //     'spaceId': spaceId,
  //     'tokenAddress': tokenAddress,
  //   };

  //   final response =
  //       await _network.post("space/benefits/redeem/$benefitId", queryParams);

  //   if (response.statusCode == 204) {
  //     return true;
  //   }

  //   if (response.statusCode == 400) {
  //     "inside Status Code is 400  **********************************************"
  //         .log();
  //     // Parse the response body
  //     final Map<String, dynamic> responseBody = json.decode(response.data);
  //     final errorCode = responseBody['error']['code'];
  //     final errorMessage = responseBody['error']['message'];

  //     throw BenefitRedeemErrorDto(
  //       message: errorMessage,
  //       error: errorCode,
  //       trace: StackTrace.current.toString(),
  //     );
  //   }

  //   return false;
  // }

  Future<bool> postRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String spaceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Construct the query parameters
      final Map<String, dynamic> queryParams = {
        "latitude": latitude,
        "longitude": longitude,
        'spaceId': spaceId,
        'tokenAddress': tokenAddress,
      };

      final response =
          await _network.post("space/benefits/redeem/$benefitId", queryParams);

      if (response.statusCode == 204) {
        return true;
      }

      return false;
    } on DioException catch (e, t) {
      if (e.response != null && e.response?.statusCode == 400) {
        final Map<String, dynamic> responseBody = e.response?.data;
        final errorCode = responseBody['error']['code'];
        final errorMessage = responseBody['error']['message'];

        throw BenefitRedeemErrorDto(
          message: errorMessage,
          error: errorCode,
          trace: t.toString(),
        );
      }

      throw BenefitRedeemErrorDto(
        message: e.message ?? "",
        error: e.toString(),
        trace: t.toString(),
      );
    } catch (e, t) {
      throw BenefitRedeemErrorDto(
        message: e.toString(),
        error: e.toString(),
        trace: t.toString(),
      );
    }
  }

  Future<List<TopUsedNftDto>> requestGetTopUsedNfts() async {
    final response = await _network.get("nft/collections", {});
    return response.data
        .map<TopUsedNftDto>(
            (e) => TopUsedNftDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  //

  Future<List<NewSpaceDto>> requestGetNewSpaceList() async {
    final response = await _network.get("space/new-spaces", {});
    return response.data
        .map<NewSpaceDto>(
            (e) => NewSpaceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SpaceDto>> requestGetSpaceList({
    String? category,
    int? page,
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      if (category != null) 'category': category,
      if (page != null) 'page': page.toString(),
    };

    final response = await _network.get("space", queryParams);
    return response.data
        .map<SpaceDto>((e) => SpaceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecommendationSpaceDto>> requestGetRecommendedSpaces() async {
    final response = await _network.get("space/recommendations", {});
    return response.data
        .map<RecommendationSpaceDto>(
            (e) => RecommendationSpaceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SpaceDetailDto> requestGetSpaceDetailBySpaceId(
      {required String spaceId}) async {
    final response = await _network.get("space/space/$spaceId", {});
    return SpaceDetailDto.fromJson(response.data as Map<String, dynamic>);
  }

  //

  Future<BenefitsGroupDto> requestGetSpaceBenefits(
      {required String spaceId}) async {
    final response = await _network.get("space/space/$spaceId/benefits", {});
    return BenefitsGroupDto.fromJson(response.data as Map<String, dynamic>);
  }
}
