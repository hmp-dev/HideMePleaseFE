import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';

@lazySingleton
class SpaceRemoteDataSource {
  final Network _network;

  SpaceRemoteDataSource(this._network);

  Future<SpacesResponseDto> getNearBySpacesList({
    required String tokenAddress,
    required String latitude,
    required String longitude,
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      'latitude': latitude,
      'longitude': longitude,
    };

    final response =
        await _network.get("nft/collection/$tokenAddress/spaces", queryParams);

    return SpacesResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
