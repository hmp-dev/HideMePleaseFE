import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';

part 'nft_community_member_dto.g.dart';

@JsonSerializable()
class NftCommunityMemberResponseDto extends Equatable {
  final List<NftCommunityMemberDto>? members;
  final int nftMemberCount;

  const NftCommunityMemberResponseDto({
    this.members,
    required this.nftMemberCount,
  });

  factory NftCommunityMemberResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NftCommunityMemberResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCommunityMemberResponseDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      members,
      nftMemberCount,
    ];
  }
}

@JsonSerializable()
class NftCommunityMemberDto extends Equatable {
  final int? totalPoints;
  final int? pointFluctuation;
  final int? memberRank;
  final String? name;
  final String? userId;
  final String? introduction;
  final String? pfpImage;

  const NftCommunityMemberDto({
    this.totalPoints,
    this.pointFluctuation,
    this.memberRank,
    this.name,
    this.userId,
    this.introduction,
    this.pfpImage,
  });

  factory NftCommunityMemberDto.fromJson(Map<String, dynamic> json) =>
      _$NftCommunityMemberDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCommunityMemberDtoToJson(this);

  CommunityMemberEntity toEntity() => CommunityMemberEntity(
        totalPoints: totalPoints!,
        pointFluctuation: pointFluctuation!,
        memberRank: memberRank!,
        name: name!,
        userId: userId!,
        introduction: introduction ?? '',
        pfpImage: pfpImage ?? '',
      );

  @override
  List<Object?> get props {
    return [
      totalPoints,
      pointFluctuation,
      memberRank,
      name,
      userId,
      introduction,
      pfpImage,
    ];
  }
}
