import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/friends/domain/repositories/friends_repository.dart';
import 'package:mobile/features/friends/infrastructure/data_sources/friends_remote_data_source.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_list_response_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_request_response_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_stats_dto.dart';

@LazySingleton(as: FriendsRepository)
class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource _remoteDataSource;

  const FriendsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<HMPError, Map<String, dynamic>>> sendFriendRequest({
    required String addresseeId,
  }) async {
    try {
      final response = await _remoteDataSource.sendFriendRequest(
        addresseeId: addresseeId,
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
  Future<Either<HMPError, Map<String, dynamic>>> acceptFriendRequest({
    required String friendshipId,
  }) async {
    try {
      final response = await _remoteDataSource.acceptFriendRequest(
        friendshipId: friendshipId,
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
  Future<Either<HMPError, Map<String, dynamic>>> rejectFriendRequest({
    required String friendshipId,
  }) async {
    try {
      final response = await _remoteDataSource.rejectFriendRequest(
        friendshipId: friendshipId,
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
  Future<Either<HMPError, FriendListResponseDto>> getFriendsList({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getFriendsList(
        page: page,
        limit: limit,
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
  Future<Either<HMPError, FriendRequestResponseDto>> getReceivedFriendRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getReceivedFriendRequests(
        page: page,
        limit: limit,
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
  Future<Either<HMPError, FriendRequestResponseDto>> getSentFriendRequests({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getSentFriendRequests(
        status: status,
        page: page,
        limit: limit,
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
  Future<Either<HMPError, bool>> deleteFriend({
    required String friendshipId,
  }) async {
    try {
      final response = await _remoteDataSource.deleteFriend(
        friendshipId: friendshipId,
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
  Future<Either<HMPError, Map<String, dynamic>>> blockUser({
    required String userId,
  }) async {
    try {
      final response = await _remoteDataSource.blockUser(userId: userId);
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
  Future<Either<HMPError, Map<String, dynamic>>> unblockUser({
    required String userId,
  }) async {
    try {
      final response = await _remoteDataSource.unblockUser(userId: userId);
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
  Future<Either<HMPError, FriendListResponseDto>> searchFriends({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.searchFriends(
        query: query,
        page: page,
        limit: limit,
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
  Future<Either<HMPError, FriendStatsDto>> getFriendStats() async {
    try {
      final response = await _remoteDataSource.getFriendStats();
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
  Future<Either<HMPError, Map<String, dynamic>?>> getFriendshipStatus({
    required String userId,
  }) async {
    try {
      final response = await _remoteDataSource.getFriendshipStatus(
        userId: userId,
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
}
