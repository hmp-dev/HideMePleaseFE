// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/features/my/domain/entities/base_user_entity.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable()
class UserProfileDto extends Equatable {
  @JsonKey(name: "nickName")
  final String? nickName;
  @JsonKey(name: "introduction")
  final String? introduction;
  @JsonKey(name: "locationPublic")
  final bool? locationPublic;
  @JsonKey(name: "notificationsEnabled")
  final bool? notificationsEnabled;
  @JsonKey(name: "pfpNftId")
  final String? pfpNftId;
  @JsonKey(name: "pfpImageUrl")
  final String? pfpImageUrl;
  final bool? freeNftClaimed;

  const UserProfileDto({
    this.nickName,
    this.introduction,
    this.locationPublic,
    this.notificationsEnabled,
    this.pfpNftId,
    this.pfpImageUrl,
    this.freeNftClaimed,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);

  UserProfileEntity toEntity() => UserProfileEntity(
        nickName: nickName ?? "",
        introduction: introduction ?? "",
        locationPublic: locationPublic ?? false,
        pfpNftId: pfpNftId ?? "",
        pfpImageUrl: pfpImageUrl ?? "",
        notificationsEnabled: notificationsEnabled ?? false,
        freeNftClaimed: freeNftClaimed ?? false,
      );

//

  @override
  List<Object?> get props {
    return [
      nickName,
      introduction,
      locationPublic,
      notificationsEnabled,
      pfpNftId,
      pfpImageUrl,
      freeNftClaimed,
    ];
  }
}
