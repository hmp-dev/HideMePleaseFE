import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';

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
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      'token': nfcToken,
      'tokenAddress': tokenAddress,
    };

    final response =
        await _network.post("space/benefits/redeem/$benefitId", queryParams);

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }
}
