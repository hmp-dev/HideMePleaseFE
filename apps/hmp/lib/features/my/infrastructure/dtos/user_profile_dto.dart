// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/features/my/domain/entities/base_user_entity.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/friends/infrastructure/dtos/active_check_in_dto.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable()
class CheckInStatsDto extends Equatable {
  final int? totalCheckIns;
  final int? todayCheckIns;
  final int? weekCheckIns;
  final int? monthCheckIns;
  final ActiveCheckInDto? activeCheckIn;

  const CheckInStatsDto({
    this.totalCheckIns,
    this.todayCheckIns,
    this.weekCheckIns,
    this.monthCheckIns,
    this.activeCheckIn,
  });

  factory CheckInStatsDto.fromJson(Map<String, dynamic> json) =>
      _$CheckInStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInStatsDtoToJson(this);

  @override
  List<Object?> get props => [
        totalCheckIns,
        todayCheckIns,
        weekCheckIns,
        monthCheckIns,
        activeCheckIn,
      ];
}

@JsonSerializable()
class PointBalanceDto extends Equatable {
  final int? totalBalance;
  final int? availableBalance;
  final int? lockedBalance;
  final int? lifetimeEarned;
  final int? lifetimeSpent;

  const PointBalanceDto({
    this.totalBalance,
    this.availableBalance,
    this.lockedBalance,
    this.lifetimeEarned,
    this.lifetimeSpent,
  });

  factory PointBalanceDto.fromJson(Map<String, dynamic> json) =>
      _$PointBalanceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PointBalanceDtoToJson(this);

  @override
  List<Object?> get props => [
        totalBalance,
        availableBalance,
        lockedBalance,
        lifetimeEarned,
        lifetimeSpent,
      ];
}

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
  final PointBalanceDto? pointBalance;
  final CheckInStatsDto? checkInStats;
  final int? friendsCount;
  final bool? onboardingCompleted;
  final String? appOS;
  final String? appVersion;

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
    this.pointBalance,
    this.checkInStats,
    this.friendsCount,
    this.onboardingCompleted,
    this.appOS,
    this.appVersion,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);

  UserProfileEntity toEntity() {
    final userId = id ?? "";
    // API URL 생성 - HTTPS 사용
    final apiImageUrl = userId.isNotEmpty
        ? 'https://dev-api.hidemeplease.xyz/v1/public/nft/user/$userId/image'
        : "";

    return UserProfileEntity(
        id: userId,
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
        finalProfileImageUrl: apiImageUrl, // API URL 사용
        availableBalance: pointBalance?.availableBalance ?? 0,
        checkInStats: checkInStats != null
            ? CheckInStats(
                totalCheckIns: checkInStats!.totalCheckIns ?? 0,
                todayCheckIns: checkInStats!.todayCheckIns ?? 0,
                weekCheckIns: checkInStats!.weekCheckIns ?? 0,
                monthCheckIns: checkInStats!.monthCheckIns ?? 0,
                activeCheckIn: checkInStats!.activeCheckIn?.toEntity(),
              )
            : const CheckInStats.empty(),
        friendsCount: friendsCount ?? 0,
        onboardingCompleted: onboardingCompleted ?? false,
        appOS: appOS ?? "",
        appVersion: appVersion ?? "",
      );
  }

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
      finalProfileImageUrl,
      friendsCount,
      onboardingCompleted,
      appOS,
      appVersion,
    ];
  }
}
