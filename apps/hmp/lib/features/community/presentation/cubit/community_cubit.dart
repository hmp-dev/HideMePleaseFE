import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_dto.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

part 'community_state.dart';

@lazySingleton
class CommunityCubit extends BaseCubit<CommunityState> {
  final NftRepository _nftRepository;
  final ChatRepository _chatRepository;
  CommunityCubit(this._nftRepository, this._chatRepository)
      : super(CommunityState.initial());

  Future<void> onStart() {
    return Future.wait([
      onGetAllNftCommunities(),
      onGetHotNftCommunities(),
      onGetUserNftCommunities(),
    ]);
  }

  Future<void> onGetAllNftCommunities() async {
    final allNftCommsRes = await _nftRepository.getNftCommunities(
      order: state.allNftCommOrderBy,
      page: 1,
    );
    allNftCommsRes.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failure)),
      (data) => emit(state.copyWith(
        allNftCommunities:
            data.allCommunities?.map((e) => e.toEntity()).toList() ?? [],
        communityCount: data.communityCount ?? 0,
        itemCount: data.itemCount ?? 0,
        status: RequestStatus.success,
      )),
    );
  }

  Future<void> onGetAllNftCommunitiesLoadMore() async {
    if (state.allNftLoaded ||
        state.loadingMoreStatus == RequestStatus.loading) {
      return;
    }

    emit(state.copyWith(loadingMoreStatus: RequestStatus.loading));

    final allNftCommsRes = await _nftRepository.getNftCommunities(
      order: state.allNftCommOrderBy,
      page: state.allCommunitiesPage + 1,
    );
    allNftCommsRes.fold(
      (l) => emit(state.copyWith(loadingMoreStatus: RequestStatus.failure)),
      (data) => emit(state.copyWith(
        allNftLoaded: data.allCommunities?.isEmpty ?? true,
        allNftCommunities: List.from(state.allNftCommunities)
          ..addAll(
              data.allCommunities?.map((e) => e.toEntity()).toList() ?? []),
        loadingMoreStatus: RequestStatus.success,
        allCommunitiesPage: state.allCommunitiesPage + 1,
      )),
    );
  }

  void onOrderByChanged(GetNftCommunityOrderBy? orderBy) {
    if (orderBy == null) return;

    emit(state.copyWith(
      allNftCommOrderBy: orderBy,
      allNftLoaded: false,
      loadingMoreStatus: RequestStatus.initial,
      allCommunitiesPage: 1,
    ));
    onGetAllNftCommunities();
  }

  Future<void> onGetHotNftCommunities() async {
    final hotNftCommsRes = await _nftRepository.getHotNftCommunities();
    hotNftCommsRes.fold(
      (_) {},
      (data) => emit(state.copyWith(
        hotNftCommunities: data.map((e) => e.toEntity()).toList(),
      )),
    );
  }

  Future<void> onGetUserNftCommunities() async {
    final userNftCommsRes = await _nftRepository.getUserNftCommunities();
    userNftCommsRes.fold(
      (_) {},
      (data) {
        emit(state.copyWith(
            userNftCommunities: data.map((e) => e.toEntity()).toList()));

        onGetUserCommunitiesUnread(
            state.userNftCommunities.map((e) => e.tokenAddress).toList());
        for (var e in state.userNftCommunities) {
          onGetUserCommunitiesRecentMsgs(e.tokenAddress);
        }
      },
    );
  }

  Future<void> onGetUserCommunitiesUnread(List<String> channelUrls) async {
    final channelsRes = await _chatRepository.getChannelList(
      channelUrls: channelUrls,
    );
    channelsRes.fold(
      (err) => null,
      (channels) => emit(state.copyWith(
        userNftCommunities: state.userNftCommunities.map((e) {
          final channel = channels
              .where((element) => element.channelUrl == e.tokenAddress)
              .firstOrNull;
          return e.copyWith(
            unreadCount: channel?.unreadMessageCount ?? 0,
            totalMembers: channel?.memberCount ?? 0,
          );
        }).toList(),
      )),
    );
  }

  Future<void> onGetUserCommunitiesRecentMsgs(String channelUrl) async {
    final messagesRes = await _chatRepository.getMessages(
      channelType: ChannelType.group,
      channelUrl: channelUrl,
    );

    messagesRes.fold(
      (err) => null,
      (messages) {
        final idx = state.userNftCommunities
            .indexWhere((element) => element.tokenAddress == channelUrl);
        final userNftCommunities =
            List<NftCommunityEntity>.from(state.userNftCommunities);
        userNftCommunities[idx] =
            userNftCommunities[idx].copyWith(recentMessages: messages);
        emit(state.copyWith(userNftCommunities: userNftCommunities));
      },
    );
  }
}
