import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_benefit_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_network_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_points_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_usage_history_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/welcome_nft_dto.dart';

@lazySingleton
class NftRemoteDataSource {
  final Network _network;

  NftRemoteDataSource(this._network);

  Future<NftCollectionsGroupDto> requestGetNftCollections({
    String? chain,
    String? nextCursor,
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      if (chain != null) 'chain': chain,
      if (nextCursor != null) 'next': nextCursor,
    };

    final response = await _network.get("nft/collections", queryParams);
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

  Future<List<SelectedNFTDto>> requestGetSelectTokens() async {
    final response = await _network.get("nft/nfts/selected", {});
    return response.data
        .map<SelectedNFTDto>(
            (e) => SelectedNFTDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> saveCollectionsSelectedOrder(
      SaveSelectedTokensReorderRequestDto saveOrderDto) async {
    final response = await _network.post(
        "nft/collections/selected/order", saveOrderDto.toJson());
    return response.statusCode == 201;
  }

  Future<WelcomeNftDto> requestGetWelcomeNFT() async {
    final response = await _network.get("nft/welcome", {});
    return WelcomeNftDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> requestGetConsumeWelcomeNft(int welcomeNftId) async {
    final response = await _network.get("nft/welcome/$welcomeNftId", {});
    return response.data;
  }

  Future<List<NftBenefitDto>> requestGetNftBenefits(
      {required String tokenAddress}) async {
    final response =
        await _network.get("nft/collection/{$tokenAddress}/benefits", {});
    return response.data
        .map<NftBenefitDto>(
            (e) => NftBenefitDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NftPointsDto>> requestGetNftPoints() async {
    final response = await _network.get("nft/nfts/selected/points", {});
    return response.data
        .map<NftPointsDto>(
            (e) => NftPointsDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NftNetworkDto> requestGetNftNetworkInfo(
      {required String tokenAddress}) async {
    final response =
        await _network.get("nft/collection/$tokenAddress/network-info", {});
    return NftNetworkDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NftUsageHistoryDto> requestGetNftUsageHistory({
    required String tokenAddress,
    String? order,
    String? page,
    String? type,
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      if (order != null) 'order': order,
      if (page != null) 'page': page,
      if (type != null) 'type': type,
    };

    final response = await _network.get(
        "nft/collection/$tokenAddress/usage-history", queryParams);
    return NftUsageHistoryDto.fromJson(response.data as Map<String, dynamic>);
  }
}
