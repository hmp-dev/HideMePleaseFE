import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';

@lazySingleton
class NftRemoteDataSource {
  final Network _network;

  NftRemoteDataSource(this._network);

  Future<NftCollectionsGroupDto> getAllConnectedWallets() async {
    final response = await _network.get("nft/collections", {});
    return NftCollectionsGroupDto.fromJson(
        response.data as Map<String, dynamic>);
  }
}
