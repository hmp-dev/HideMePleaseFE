import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;

class NftCommunityEntity extends Equatable {
  final int communityRank;
  final int totalMembers;
  final String tokenAddress;
  final String name;
  final String collectionLogo;
  final String chain;
  final String lastConversation;
  final int eventCount;

  const NftCommunityEntity({
    required this.communityRank,
    required this.totalMembers,
    required this.tokenAddress,
    required this.name,
    required this.collectionLogo,
    required this.chain,
    required this.lastConversation,
    required this.eventCount,
  });

  const NftCommunityEntity.empty()
      : communityRank = 0,
        totalMembers = 0,
        tokenAddress = '',
        name = '',
        collectionLogo = '',
        chain = '',
        lastConversation = '',
        eventCount = 0;

  String get timeAgo => DateTime.tryParse(lastConversation) == null
      ? ''
      : timeago.format(DateTime.parse(lastConversation).toLocal(),
          locale: 'ko');

  String get people => '$totalMembers명';

  String get rank => '$communityRank위';

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
      eventCount,
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
    int? eventCount,
  }) {
    return NftCommunityEntity(
      communityRank: communityRank ?? this.communityRank,
      totalMembers: totalMembers ?? this.totalMembers,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      name: name ?? this.name,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      chain: chain ?? this.chain,
      lastConversation: lastConversation ?? this.lastConversation,
      eventCount: eventCount ?? this.eventCount,
    );
  }
}
