import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_dto.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_member_dto.dart';
import 'package:mobile/features/community/infrastructure/dtos/top_collection_nft_dto.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';
import 'package:mobile/features/nft/infrastructure/datasources/nft_remote_data_source.dart';
import 'package:mobile/features/nft/infrastructure/dtos/benefit_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_network_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_points_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/nft_usage_history_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/selected_nft_dto.dart';
import 'package:mobile/features/nft/infrastructure/dtos/welcome_nft_dto.dart';

@LazySingleton(as: NftRepository)
class NftRepositoryImpl extends NftRepository {
  final NftRemoteDataSource _nftRemoteDataSource;

  NftRepositoryImpl(this._nftRemoteDataSource);

  @override
  Future<Either<HMPError, NftCollectionsGroupDto>> getNftCollections({
    String? chain,
    String? nextCursor,
  }) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftCollections(
        chain: chain,
        nextCursor: nextCursor,
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
  Future<Either<HMPError, bool>> postNftSelectDeselectToken({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  }) async {
    try {
      final response = await _nftRemoteDataSource.postTokenSelectDeselect(
          selectTokenToggleRequestDto: selectTokenToggleRequestDto);
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
  Future<Either<HMPError, List<SelectedNFTDto>>> getSelectNftCollections(
      {String? userId}) async {
    try {
      final response = userId != null
          ? await _nftRemoteDataSource.requestGetSelectTokensByUser(
              userId: userId)
          : await _nftRemoteDataSource.requestGetSelectTokens();
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
  Future<Either<HMPError, bool>> postCollectionOrderSave({
    required SaveSelectedTokensReorderRequestDto
        saveSelectedTokensReorderRequestDto,
  }) async {
    try {
      final response = await _nftRemoteDataSource
          .saveCollectionsSelectedOrder(saveSelectedTokensReorderRequestDto);

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
  Future<Either<HMPError, WelcomeNftDto>> getWelcomeNft(
      {required double latitude, required double longitude}) async {
    try {
      final response = await _nftRemoteDataSource.requestGetWelcomeNFT(
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
  Future<Either<HMPError, Unit>> getConsumeUserWelcomeNft(
      {required String tokenAddress}) async {
    try {
      await _nftRemoteDataSource.requestGetConsumeWelcomeNft(tokenAddress);
      return right(unit);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.response?.data['error']?['message'] ?? e.message,
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
  Future<Either<HMPError, NftBenefitsResponseDto>> getNftBenefits({
    required String tokenAddress,
    required double latitude,
    required double longitude,
    String? spaceId,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftBenefits(
        tokenAddress: tokenAddress,
        latitude: latitude,
        longitude: longitude,
        spaceId: spaceId,
        pageSize: pageSize,
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
  Future<Either<HMPError, List<NftPointsDto>>> getNftPoints({
    String? userId,
  }) async {
    try {
      final response = userId != null
          ? await _nftRemoteDataSource.requestGetNftPointsByUser(userId: userId)
          : await _nftRemoteDataSource.requestGetNftPoints();
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
  Future<Either<HMPError, NftNetworkDto>> getNftNetworkInfo(
      {required String tokenAddress}) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftNetworkInfo(
        tokenAddress: tokenAddress,
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
  Future<Either<HMPError, NftUsageHistoryDto>> getNftUsageHistory({
    required String tokenAddress,
    String? order,
    String? page,
    String? type,
  }) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftUsageHistory(
        tokenAddress: tokenAddress,
        order: order,
        page: page,
        type: type,
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
  Future<Either<HMPError, NftCommunityResponseDto>> getNftCommunities(
      {required GetNftCommunityOrderBy order, int? page}) async {
    try {
      final response = await _nftRemoteDataSource.getNftCommunities(
        order: order,
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
  Future<Either<HMPError, List<NftCommunityDto>>> getHotNftCommunities() async {
    try {
      final response = await _nftRemoteDataSource.getHotNftCommunities();
      return right(response);
    } on DioException catch (e, t) {
      return left(
        HMPError.fromNetwork(message: e.message, error: e, trace: t),
      );
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, List<NftCommunityDto>>>
      getUserNftCommunities() async {
    try {
      final response = await _nftRemoteDataSource.getUserNftCommunities();
      return right(response);
    } on DioException catch (e, t) {
      return left(
        HMPError.fromNetwork(message: e.message, error: e, trace: t),
      );
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, NftCommunityMemberResponseDto>> getNftMembers(
      {required String tokenAddress, int? page}) async {
    try {
      final response = await _nftRemoteDataSource.getNftMembers(
        tokenAddress: tokenAddress,
        page: page,
      );
      return right(response);
    } on DioException catch (e, t) {
      return left(
        HMPError.fromNetwork(message: e.message, error: e, trace: t),
      );
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, TopCollectionNftDto>> getNftCollectionInfo(
      {required String tokenAddress}) async {
    try {
      final response = await _nftRemoteDataSource.getNftCollectionInfo(
        tokenAddress: tokenAddress,
      );
      return right(response);
    } on DioException catch (e, t) {
      return left(
        HMPError.fromNetwork(message: e.message, error: e, trace: t),
      );
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, List<TopCollectionNftDto>>> getTopNftColletions(
      {int? pageSize, int? page}) async {
    try {
      final response = await _nftRemoteDataSource.getTopNftCollections(
        pageSize: pageSize,
        page: page,
      );
      return right(response);
    } on DioException catch (e, t) {
      return left(
        HMPError.fromNetwork(message: e.message, error: e, trace: t),
      );
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }
}
