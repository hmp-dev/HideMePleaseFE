// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/features/my/domain/entities/base_user_entity.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable()
class UserProfileDto extends Equatable {
  final String? id;
  final String? nickName;
  final String? introduction;
  final bool? locationPublic;
  final bool? notificationsEnabled;
  final bool? freeNftClaimed;
  final String? chatAccessToken;
  final String? pfpNftId;
  final String? pfpImageUrl;
  final String? chatAppId;
  final String? profilePartsString;
  final String? finalProfileImageUrl;

  const UserProfileDto({
    this.id,
    this.nickName,
    this.introduction,
    this.locationPublic,
    this.notificationsEnabled,
    this.chatAccessToken,
    this.pfpNftId,
    this.pfpImageUrl,
    this.freeNftClaimed,
    this.chatAppId,
    this.profilePartsString,
    this.finalProfileImageUrl,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);

  UserProfileEntity toEntity() => UserProfileEntity(
        id: id ?? "",
        nickName: nickName ?? "",
        introduction: introduction ?? "",
        locationPublic: locationPublic ?? false,
        pfpNftId: pfpNftId ?? "",
        pfpImageUrl: pfpImageUrl ?? "",
        notificationsEnabled: notificationsEnabled ?? false,
        freeNftClaimed: freeNftClaimed ?? false,
        chatAccessToken: chatAccessToken ?? "",
        chatAppId: chatAppId ?? "",
        profilePartsString: profilePartsString ?? "",
        finalProfileImageUrl: finalProfileImageUrl ?? "",
      );

//

  @override
  List<Object?> get props {
    return [
      nickName,
      introduction,
      locationPublic,
      notificationsEnabled,
      chatAccessToken,
      pfpNftId,
      pfpImageUrl,
      freeNftClaimed,
      chatAppId,
      profilePartsString,
      finalProfileImageUrl
    ];
  }
}
