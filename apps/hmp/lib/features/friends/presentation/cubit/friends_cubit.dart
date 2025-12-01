import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/friends/domain/entities/friend_request_entity.dart';
import 'package:mobile/features/friends/domain/entities/friend_stats_entity.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/features/friends/domain/entities/pagination_entity.dart';
import 'package:mobile/features/friends/domain/repositories/friends_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'friends_state.dart';

@lazySingleton
class FriendsCubit extends BaseCubit<FriendsState> {
  final FriendsRepository _friendsRepository;

  FriendsCubit(this._friendsRepository) : super(FriendsState.initial());

  /// 특정 사용자와의 친구 관계 상태 확인
  Future<void> checkFriendshipStatus(String userId) async {
    print('🔍 Checking friendship status for userId: $userId');
    emit(state.copyWith(queryStatus: RequestStatus.loading));

    final response = await _friendsRepository.getFriendshipStatus(userId: userId);

    response.fold(
      (err) {
        print('❌ Error checking friendship status: ${err.message}');
        emit(state.copyWith(
          queryStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
          clearFriendshipStatus: true,
          clearFriendshipId: true,
        ));
      },
      (data) {
        print('📦 API Response: $data');
        if (data == null) {
          // 친구 관계 없음
          print('✅ No friendship found - clearing state');
          emit(state.copyWith(
            queryStatus: RequestStatus.success,
            errorMessage: '',
            clearFriendshipStatus: true,
            clearFriendshipId: true,
          ));
        } else {
          // 친구 관계 있음
          final status = data['status'] as String?;
          final id = data['friendshipId'] as String?;
          final direction = data['direction'] as String?;

          print('📊 Friendship data - status: $status, friendshipId: $id, direction: $direction');

          FriendshipStatus? friendshipStatus;
          switch (status?.toUpperCase()) {
            case 'PENDING':
              // ✅ FIX: Use direction field from backend API
              // direction: "sent" → 내가 보낸 신청 (PENDING_SENT)
              // direction: "received" → 내가 받은 신청 (PENDING_RECEIVED)
              if (direction == 'received') {
                friendshipStatus = FriendshipStatus.PENDING_RECEIVED;
                print('→ 받은 친구 신청 (수락 가능)');
              } else if (direction == 'sent') {
                friendshipStatus = FriendshipStatus.PENDING_SENT;
                print('→ 내가 보낸 친구 신청 (대기 중)');
              } else {
                friendshipStatus = FriendshipStatus.PENDING;
                print('→ 방향을 알 수 없는 PENDING 상태');
              }
              break;
            case 'ACCEPTED':
              friendshipStatus = FriendshipStatus.ACCEPTED;
              break;
            case 'REJECTED':
              friendshipStatus = FriendshipStatus.REJECTED;
              break;
            case 'BLOCKED':
              friendshipStatus = FriendshipStatus.BLOCKED;
              break;
          }

          print('✅ Setting friendshipStatus to: $friendshipStatus');
          emit(state.copyWith(
            queryStatus: RequestStatus.success,
            errorMessage: '',
            friendshipStatus: friendshipStatus,
            friendshipId: id,
          ));
          print('✅ State updated: friendshipStatus=${state.friendshipStatus}, friendshipId=${state.friendshipId}');
        }
      },
    );
  }

  /// 친구 신청 보내기
  Future<void> sendFriendRequest(String addresseeId) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.sendFriendRequest(
      addresseeId: addresseeId,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        final friendshipId = data['friendshipId'] as String?;
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          friendshipStatus: FriendshipStatus.PENDING_SENT, // 내가 보낸 신청
          friendshipId: friendshipId,
        ));
      },
    );
  }

  /// 친구 신청 수락
  Future<void> acceptFriendRequest(String friendshipId) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.acceptFriendRequest(
      friendshipId: friendshipId,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          friendshipStatus: FriendshipStatus.ACCEPTED,
        ));
      },
    );
  }

  /// 친구 신청 거절
  Future<void> rejectFriendRequest(String friendshipId) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.rejectFriendRequest(
      friendshipId: friendshipId,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          friendshipStatus: FriendshipStatus.REJECTED,
        ));
      },
    );
  }

  /// 친구 목록 조회
  Future<void> getFriendsList({int page = 1, int limit = 20}) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.getFriendsList(
      page: page,
      limit: limit,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        final entity = data.toEntity();
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          friendsList: entity.friends,
          friendsPagination: entity.pagination,
        ));
      },
    );
  }

  /// 받은 친구 신청 목록 조회
  Future<void> getReceivedFriendRequests({int page = 1, int limit = 20}) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.getReceivedFriendRequests(
      page: page,
      limit: limit,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        final entity = data.toEntity();
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          receivedRequests: entity.requests,
          receivedPagination: entity.pagination,
        ));
      },
    );
  }

  /// 보낸 친구 신청 목록 조회
  Future<void> getSentFriendRequests({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.getSentFriendRequests(
      status: status,
      page: page,
      limit: limit,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        final entity = data.toEntity();
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          sentRequests: entity.requests,
          sentPagination: entity.pagination,
        ));
      },
    );
  }

  /// 친구 삭제
  Future<void> deleteFriend(String friendshipId) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.deleteFriend(
      friendshipId: friendshipId,
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (success) {
        if (success) {
          emit(state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            clearFriendshipStatus: true,
            clearFriendshipId: true,
          ));
        } else {
          emit(state.copyWith(
            submitStatus: RequestStatus.failure,
            errorMessage: LocaleKeys.somethingError.tr(),
          ));
        }
      },
    );
  }

  /// 친구 통계 조회
  Future<void> getFriendStats() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _friendsRepository.getFriendStats();

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: err.message ?? LocaleKeys.somethingError.tr(),
        ));
      },
      (data) {
        emit(state.copyWith(
          submitStatus: RequestStatus.success,
          errorMessage: '',
          friendStats: data.toEntity(),
        ));
      },
    );
  }

  /// 친구 관계 상태 초기화 (다른 사용자 프로필로 이동할 때 사용)
  void resetFriendshipStatus() {
    print('🔄 Reset friendship status');
    emit(state.copyWith(
      clearFriendshipStatus: true,
      clearFriendshipId: true,
      errorMessage: '',
      submitStatus: RequestStatus.initial,
      queryStatus: RequestStatus.initial,
    ));
    print('✅ State after reset: friendshipStatus=${state.friendshipStatus}, friendshipId=${state.friendshipId}');
  }
}
