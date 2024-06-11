import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_dto.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_member_dto.dart';
import 'package:mobile/features/community/infrastructure/dtos/top_collection_nft_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/benefit_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_network_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_points_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_usage_history_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/selected_nft_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/welcome_nft_dto.dart';

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

    final response =
        await _network.get("user/collections/populated", queryParams);
    return NftCollectionsGroupDto.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<bool> postTokenSelectDeselect({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  }) async {
    final response = await _network.post(
      "user/nft/select",
      selectTokenToggleRequestDto.toJson(),
    );
    return response.statusCode == 201;
  }

  Future<List<SelectedNFTDto>> requestGetSelectTokens() async {
    final response = await _network.get("user/collections/selected", {});
    return response.data
        .map<SelectedNFTDto>(
            (e) => SelectedNFTDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> saveCollectionsSelectedOrder(
      SaveSelectedTokensReorderRequestDto saveOrderDto) async {
    final response =
        await _network.post("user/nft/selected/order", saveOrderDto.toJson());
    return response.statusCode == 201;
  }

  Future<WelcomeNftDto> requestGetWelcomeNFT() async {
    final response = await _network.get("nft/welcome", {});
    return WelcomeNftDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> requestGetConsumeWelcomeNft(int welcomeNftId) async {
    final response = await _network.post("nft/welcome/$welcomeNftId", {});
    return response.data;
  }

  Future<NftBenefitsResponseDto> requestGetNftBenefits({
    required String tokenAddress,
    String? spaceId,
    int? pageSize,
    int? page,
  }) async {
    // Construct the query parameters
    final Map<String, String> queryParams = {
      if (spaceId != null) 'spaceId': spaceId,
      if (pageSize != null) 'pageSize': '$pageSize',
      if (page != null) 'page': '$page',
    };

    final response = await _network.get(
        "nft/collection/{$tokenAddress}/benefits", queryParams);
    return NftBenefitsResponseDto.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<List<NftPointsDto>> requestGetNftPoints() async {
    final response = await _network.get("user/collections/selected/points", {});
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
        "user/collection/$tokenAddress/usage-history", queryParams);
    return NftUsageHistoryDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NftCommunityResponseDto> getNftCommunities(
      {required GetNftCommunityOrderBy order, int? page}) async {
    final response = await _network.get(
      '/nft/collections/communities',
      {
        'orderBy': order.toString().split('.').last,
        if (page != null) 'page': page.toString(),
      },
    );
    return NftCommunityResponseDto.fromJson(response.data);
  }

  Future<List<NftCommunitytDto>> getHotNftCommunities() async {
    final response = await _network.get(
      '/nft/collections/communities/hot',
      {},
    );
    return (response.data as List)
        .map((e) => NftCommunitytDto.fromJson(e))
        .toList();
  }

  Future<List<NftCommunitytDto>> getUserNftCommunities() async {
    final response = await _network.get(
      'user/collections/communities',
      {},
    );
    return (response.data as List)
        .map((e) => NftCommunitytDto.fromJson(e))
        .toList();
  }

  Future<NftCommunityMemberResponseDto> getNftMembers(
      {required String tokenAddress, int? page}) async {
    final response = await _network.get(
      '/nft/collections/$tokenAddress/members',
      {
        if (page != null) 'page': page.toString(),
      },
    );
    return NftCommunityMemberResponseDto.fromJson(response.data);
  }

  Future<TopCollectionNftDto> getNftCollectionInfo(
      {required String tokenAddress}) async {
    final response =
        await _network.get('/nft/collections/$tokenAddress/info', {});
    return TopCollectionNftDto.fromJson(response.data);
  }

  Future<List<TopCollectionNftDto>> getTopNftCollections(
      {int? pageSize, int? page}) async {
    final response = await _network.get(
      'nft/collections',
      {
        if (pageSize != null) 'pageSize': pageSize.toString(),
        if (page != null) 'page': page.toString(),
      },
    );
    return (response.data as List)
        .map((e) => TopCollectionNftDto.fromJson(e))
        .toList();
  }
}
