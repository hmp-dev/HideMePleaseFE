// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_community_member_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftCommunityMemberResponseDto _$NftCommunityMemberResponseDtoFromJson(
        Map<String, dynamic> json) =>
    NftCommunityMemberResponseDto(
      members: (json['members'] as List<dynamic>?)
          ?.map(
              (e) => NftCommunityMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nftMemberCount: json['nftMemberCount'] as int,
    );

Map<String, dynamic> _$NftCommunityMemberResponseDtoToJson(
        NftCommunityMemberResponseDto instance) =>
    <String, dynamic>{
      'members': instance.members,
      'nftMemberCount': instance.nftMemberCount,
    };

NftCommunityMemberDto _$NftCommunityMemberDtoFromJson(
        Map<String, dynamic> json) =>
    NftCommunityMemberDto(
      totalPoints: json['totalPoints'] as int,
      pointFluctuation: json['pointFluctuation'] as int,
      memberRank: json['memberRank'] as int,
      name: json['name'] as String,
      userId: json['userId'] as String,
      introduction: json['introduction'] as String,
      pfpImage: json['pfpImage'] as String,
    );

Map<String, dynamic> _$NftCommunityMemberDtoToJson(
        NftCommunityMemberDto instance) =>
    <String, dynamic>{
      'totalPoints': instance.totalPoints,
      'pointFluctuation': instance.pointFluctuation,
      'memberRank': instance.memberRank,
      'name': instance.name,
      'userId': instance.userId,
      'introduction': instance.introduction,
      'pfpImage': instance.pfpImage,
    };
