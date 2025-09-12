import 'package:equatable/equatable.dart';

class CheckInStats extends Equatable {
  final int totalCheckIns;
  final int todayCheckIns;
  final int weekCheckIns;
  final int monthCheckIns;
  final dynamic activeCheckIn;

  const CheckInStats({
    required this.totalCheckIns,
    required this.todayCheckIns,
    required this.weekCheckIns,
    required this.monthCheckIns,
    this.activeCheckIn,
  });

  const CheckInStats.empty()
      : totalCheckIns = 0,
        todayCheckIns = 0,
        weekCheckIns = 0,
        monthCheckIns = 0,
        activeCheckIn = null;

  @override
  List<Object?> get props => [
        totalCheckIns,
        todayCheckIns,
        weekCheckIns,
        monthCheckIns,
        activeCheckIn,
      ];
}

class UserProfileEntity extends Equatable {
  final String id;
  final String nickName;
  final String introduction;
  final bool locationPublic;
  final bool notificationsEnabled;
  final bool freeNftClaimed;
  final String chatAccessToken;
  final String pfpNftId;
  final String pfpImageUrl;
  final String chatAppId;
  final String profilePartsString;
  final String finalProfileImageUrl;
  final int availableBalance;
  final CheckInStats checkInStats;

  const UserProfileEntity({
    required this.id,
    required this.nickName,
    required this.introduction,
    required this.locationPublic,
    required this.notificationsEnabled,
    required this.freeNftClaimed,
    required this.chatAccessToken,
    required this.pfpNftId,
    required this.pfpImageUrl,
    required this.chatAppId,
    required this.profilePartsString,
    required this.finalProfileImageUrl,
    required this.availableBalance,
    required this.checkInStats,
  });

  const UserProfileEntity.empty()
      : id = '',
        nickName = '',
        introduction = '',
        locationPublic = false,
        notificationsEnabled = false,
        freeNftClaimed = false,
        chatAccessToken = '',
        pfpNftId = '',
        pfpImageUrl = '',
        chatAppId = '',
        profilePartsString = '',
        finalProfileImageUrl = '',
        availableBalance = 0,
        checkInStats = const CheckInStats.empty();

  @override
  List<Object?> get props {
    return [
      nickName,
      introduction,
      locationPublic,
      notificationsEnabled,
      freeNftClaimed,
      chatAccessToken,
      pfpNftId,
      pfpImageUrl,
      chatAppId,
      profilePartsString,
      finalProfileImageUrl,
      availableBalance,
      checkInStats
    ];
  }

  UserProfileEntity copyWith({
    String? nickName,
    String? introduction,
    bool? locationPublic,
    bool? notificationsEnabled,
    bool? freeNftClaimed,
    String? chatAccessToken,
    String? pfpNftId,
    String? pfpImageUrl,
    String? chatAppId,
    String? profilePartsString,
    String? finalProfileImageUrl,
    int? availableBalance,
    CheckInStats? checkInStats,
  }) {
    return UserProfileEntity(
      id: id,
      nickName: nickName ?? this.nickName,
      introduction: introduction ?? this.introduction,
      locationPublic: locationPublic ?? this.locationPublic,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      freeNftClaimed: freeNftClaimed ?? this.freeNftClaimed,
      chatAccessToken: chatAccessToken ?? this.chatAccessToken,
      pfpNftId: pfpNftId ?? this.pfpNftId,
      pfpImageUrl: pfpImageUrl ?? this.pfpImageUrl,
      chatAppId: chatAppId ?? this.chatAppId,
      profilePartsString: profilePartsString ?? this.profilePartsString,
      finalProfileImageUrl: finalProfileImageUrl ?? this.finalProfileImageUrl,
      availableBalance: availableBalance ?? this.availableBalance,
      checkInStats: checkInStats ?? this.checkInStats,
    );
  }
}
