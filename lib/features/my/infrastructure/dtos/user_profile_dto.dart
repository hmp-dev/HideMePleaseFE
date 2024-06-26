// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/features/my/domain/entities/base_user_entity.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable()
class UserProfileDto extends Equatable {
  final String? id;
  @JsonKey(name: "nickName")
  final String? nickName;
  @JsonKey(name: "introduction")
  final String? introduction;
  @JsonKey(name: "locationPublic")
  final bool? locationPublic;
  @JsonKey(name: "notificationsEnabled")
  final bool? notificationsEnabled;
  final bool? freeNftClaimed;
  final String? chatAccessToken;
  @JsonKey(name: "pfpNftId")
  final String? pfpNftId;
  @JsonKey(name: "pfpImageUrl")
  final String? pfpImageUrl;
  final String? chatAppId;

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
      chatAppId
    ];
  }
}
