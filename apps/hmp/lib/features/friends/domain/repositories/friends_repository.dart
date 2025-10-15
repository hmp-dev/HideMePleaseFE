import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_list_response_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_request_response_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_stats_dto.dart';

abstract class FriendsRepository {
  Future<Either<HMPError, Map<String, dynamic>>> sendFriendRequest({
    required String addresseeId,
  });

  Future<Either<HMPError, Map<String, dynamic>>> acceptFriendRequest({
    required String friendshipId,
  });

  Future<Either<HMPError, Map<String, dynamic>>> rejectFriendRequest({
    required String friendshipId,
  });

  Future<Either<HMPError, FriendListResponseDto>> getFriendsList({
    int page = 1,
    int limit = 20,
  });

  Future<Either<HMPError, FriendRequestResponseDto>> getReceivedFriendRequests({
    int page = 1,
    int limit = 20,
  });

  Future<Either<HMPError, FriendRequestResponseDto>> getSentFriendRequests({
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<Either<HMPError, bool>> deleteFriend({
    required String friendshipId,
  });

  Future<Either<HMPError, Map<String, dynamic>>> blockUser({
    required String userId,
  });

  Future<Either<HMPError, Map<String, dynamic>>> unblockUser({
    required String userId,
  });

  Future<Either<HMPError, FriendListResponseDto>> searchFriends({
    required String query,
    int page = 1,
    int limit = 20,
  });

  Future<Either<HMPError, FriendStatsDto>> getFriendStats();

  Future<Either<HMPError, Map<String, dynamic>?>> getFriendshipStatus({
    required String userId,
  });
}
