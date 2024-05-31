import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';
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

  Future<bool> postRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String nfcToken,
    required double latitude,
    required double longitude,
  }) async {
    // Construct the query parameters
    final Map<String, dynamic> queryParams = {
      "latitude": latitude,
      "longitude": longitude,
      'token': nfcToken,
      'tokenAddress': tokenAddress,
    };

    final response =
        await _network.post("space/benefits/redeem/$benefitId", queryParams);

    "response is: ${response.statusCode}".log();
    "response is: ${response.data}".log();

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<TopUsedNftDto>> requestGetTopUsedNfts() async {
    final response = await _network.get("nft/collections/top", {});
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

  Future<SpaceDetailDto> requestGetSpaceDetail(
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
