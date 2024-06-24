import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String nickName;
  final String introduction;
  final bool locationPublic;
  final bool notificationsEnabled;
  final String pfpNftId;
  final String pfpImageUrl;
  final bool freeNftClaimed;

  const UserProfileEntity({
    required this.nickName,
    required this.introduction,
    required this.locationPublic,
    required this.notificationsEnabled,
    required this.pfpNftId,
    required this.pfpImageUrl,
    required this.freeNftClaimed,
  });

  const UserProfileEntity.empty()
      : nickName = '',
        introduction = '',
        locationPublic = false,
        notificationsEnabled = false,
        pfpNftId = '',
        pfpImageUrl = '',
        this.freeNftClaimed = false;

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

  UserProfileEntity copyWith({
    String? nickName,
    String? introduction,
    bool? locationPublic,
    bool? notificationsEnabled,
    String? pfpNftId,
    String? pfpImageUrl,
    bool? freeNftClaimed,
  }) {
    return UserProfileEntity(
      nickName: nickName ?? this.nickName,
      introduction: introduction ?? this.introduction,
      locationPublic: locationPublic ?? this.locationPublic,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pfpNftId: pfpNftId ?? this.pfpNftId,
      pfpImageUrl: pfpImageUrl ?? this.pfpImageUrl,
      freeNftClaimed: freeNftClaimed ?? this.freeNftClaimed,
    );
  }
}
