import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;

class NftCommunityEntity extends Equatable {
  final int communityRank;
  final int totalMembers;
  final String tokenAddress;
  final String name;
  final String collectionLogo;
  final String chain;
  final String lastConversation;
  final List<BaseMessage> recentMessages;
  final int unreadCount;

  const NftCommunityEntity({
    required this.communityRank,
    required this.totalMembers,
    required this.tokenAddress,
    required this.name,
    required this.collectionLogo,
    required this.chain,
    required this.lastConversation,
    required this.recentMessages,
    required this.unreadCount,
  });

  const NftCommunityEntity.empty()
      : communityRank = 0,
        totalMembers = 0,
        tokenAddress = '',
        name = '',
        collectionLogo = '',
        chain = '',
        lastConversation = '',
        recentMessages = const [],
        unreadCount = 0;

  String get timeAgo => DateTime.tryParse(lastConversation) == null
      ? ''
      : timeago.format(DateTime.parse(lastConversation).toLocal(),
          locale: 'ko');

  String get people => '$totalMembers명';

  String get rank => '$communityRank위';

  String get chainLogo => ChainType.fromString(chain).chainLogo;

  @override
  List<Object?> get props {
    return [
      communityRank,
      totalMembers,
      tokenAddress,
      name,
      collectionLogo,
      chain,
      lastConversation,
      recentMessages,
      unreadCount,
    ];
  }

  NftCommunityEntity copyWith({
    int? communityRank,
    int? totalMembers,
    String? tokenAddress,
    String? name,
    String? collectionLogo,
    String? chain,
    String? lastConversation,
    List<BaseMessage>? recentMessages,
    int? unreadCount,
  }) {
    return NftCommunityEntity(
      communityRank: communityRank ?? this.communityRank,
      totalMembers: totalMembers ?? this.totalMembers,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      name: name ?? this.name,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      chain: chain ?? this.chain,
      lastConversation: lastConversation ?? this.lastConversation,
      recentMessages: recentMessages ?? this.recentMessages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
