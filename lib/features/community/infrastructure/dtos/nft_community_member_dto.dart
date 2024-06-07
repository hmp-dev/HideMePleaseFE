import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/core/cubit/cubit.dart';

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
  final int totalPoints;
  final int pointFluctuation;
  final int memberRank;
  final String name;

  const NftCommunityMemberDto({
    required this.totalPoints,
    required this.pointFluctuation,
    required this.memberRank,
    required this.name,
  });

  factory NftCommunityMemberDto.fromJson(Map<String, dynamic> json) =>
      _$NftCommunityMemberDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCommunityMemberDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      totalPoints,
      pointFluctuation,
      memberRank,
      name,
    ];
  }
}
