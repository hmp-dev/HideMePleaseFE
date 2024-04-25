import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';

@lazySingleton
class NftRemoteDataSource {
  final Network _network;

  NftRemoteDataSource(this._network);

  Future<NftCollectionsGroupDto> getAllConnectedWallets() async {
    final response = await _network.get("nft/collections", {});
    return NftCollectionsGroupDto.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<bool> postTokenSelectDeselect({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  }) async {
    final response = await _network.post(
      "nft/token/select",
      selectTokenToggleRequestDto.toJson(),
    );
    return response.statusCode == 201;
  }

  Future<List<SelectedNFTDto>> getSelectTokens() async {
    final response = await _network.get("nft/collections/selected", {});
    return response.data
        .map<SelectedNFTDto>(
            (e) => SelectedNFTDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  
}
