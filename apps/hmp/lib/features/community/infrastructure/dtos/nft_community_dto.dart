import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';

part 'nft_community_dto.g.dart';

@JsonSerializable()
class NftCommunityResponseDto extends Equatable {
  final int? communityCount;
  final int? itemCount;
  final List<NftCommunityDto>? allCommunities;

  const NftCommunityResponseDto({
    this.communityCount,
    this.itemCount,
    this.allCommunities,
  });

  factory NftCommunityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NftCommunityResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCommunityResponseDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      communityCount,
      itemCount,
      allCommunities,
    ];
  }
}

@JsonSerializable()
class NftCommunityDto extends Equatable {
  final int? communityRank;
  final int? totalMembers;
  final String? tokenAddress;
  final String? name;
  final String? collectionLogo;
  final String? chain;
  final String? lastConversation;
  final int? eventCount;

  const NftCommunityDto({
    this.communityRank,
    this.totalMembers,
    this.tokenAddress,
    this.name,
    this.collectionLogo,
    this.chain,
    this.lastConversation,
    this.eventCount,
  });

  factory NftCommunityDto.fromJson(Map<String, dynamic> json) =>
      _$NftCommunityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCommunityDtoToJson(this);

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

  NftCommunityEntity toEntity() => NftCommunityEntity(
        communityRank: communityRank ?? 0,
        totalMembers: totalMembers ?? 0,
        tokenAddress: tokenAddress ?? '',
        name: name ?? '',
        collectionLogo: collectionLogo ?? '',
        chain: chain ?? '',
        lastConversation: lastConversation ?? '',
        eventCount: eventCount ?? 0,
      );
}

enum GetNftCommunityOrderBy { points, members }
