import 'package:equatable/equatable.dart';

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
        chatAppId = '';

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
      chatAppId
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
    );
  }
}
