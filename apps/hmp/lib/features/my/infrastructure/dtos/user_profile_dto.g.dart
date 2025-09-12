// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInStatsDto _$CheckInStatsDtoFromJson(Map<String, dynamic> json) =>
    CheckInStatsDto(
      totalCheckIns: (json['totalCheckIns'] as num?)?.toInt(),
      todayCheckIns: (json['todayCheckIns'] as num?)?.toInt(),
      weekCheckIns: (json['weekCheckIns'] as num?)?.toInt(),
      monthCheckIns: (json['monthCheckIns'] as num?)?.toInt(),
      activeCheckIn: json['activeCheckIn'],
    );

Map<String, dynamic> _$CheckInStatsDtoToJson(CheckInStatsDto instance) =>
    <String, dynamic>{
      'totalCheckIns': instance.totalCheckIns,
      'todayCheckIns': instance.todayCheckIns,
      'weekCheckIns': instance.weekCheckIns,
      'monthCheckIns': instance.monthCheckIns,
      'activeCheckIn': instance.activeCheckIn,
    };

PointBalanceDto _$PointBalanceDtoFromJson(Map<String, dynamic> json) =>
    PointBalanceDto(
      totalBalance: (json['totalBalance'] as num?)?.toInt(),
      availableBalance: (json['availableBalance'] as num?)?.toInt(),
      lockedBalance: (json['lockedBalance'] as num?)?.toInt(),
      lifetimeEarned: (json['lifetimeEarned'] as num?)?.toInt(),
      lifetimeSpent: (json['lifetimeSpent'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PointBalanceDtoToJson(PointBalanceDto instance) =>
    <String, dynamic>{
      'totalBalance': instance.totalBalance,
      'availableBalance': instance.availableBalance,
      'lockedBalance': instance.lockedBalance,
      'lifetimeEarned': instance.lifetimeEarned,
      'lifetimeSpent': instance.lifetimeSpent,
    };

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      id: json['id'] as String?,
      nickName: json['nickName'] as String?,
      introduction: json['introduction'] as String?,
      locationPublic: json['locationPublic'] as bool?,
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      chatAccessToken: json['chatAccessToken'] as String?,
      pfpNftId: json['pfpNftId'] as String?,
      pfpImageUrl: json['pfpImageUrl'] as String?,
      freeNftClaimed: json['freeNftClaimed'] as bool?,
      chatAppId: json['chatAppId'] as String?,
      profilePartsString: json['profilePartsString'] as String?,
      finalProfileImageUrl: json['finalProfileImageUrl'] as String?,
      pointBalance: json['pointBalance'] == null
          ? null
          : PointBalanceDto.fromJson(
              json['pointBalance'] as Map<String, dynamic>),
      checkInStats: json['checkInStats'] == null
          ? null
          : CheckInStatsDto.fromJson(
              json['checkInStats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickName': instance.nickName,
      'introduction': instance.introduction,
      'locationPublic': instance.locationPublic,
      'notificationsEnabled': instance.notificationsEnabled,
      'freeNftClaimed': instance.freeNftClaimed,
      'chatAccessToken': instance.chatAccessToken,
      'pfpNftId': instance.pfpNftId,
      'pfpImageUrl': instance.pfpImageUrl,
      'chatAppId': instance.chatAppId,
      'profilePartsString': instance.profilePartsString,
      'finalProfileImageUrl': instance.finalProfileImageUrl,
      'pointBalance': instance.pointBalance,
      'checkInStats': instance.checkInStats,
    };
