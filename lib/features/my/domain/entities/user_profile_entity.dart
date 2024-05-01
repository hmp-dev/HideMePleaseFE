import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String nickName;
  final String introduction;
  final bool locationPublic;
  final String pfpNftId;
  final String pfpImageUrl;

  const UserProfileEntity({
    required this.nickName,
    required this.introduction,
    required this.locationPublic,
    required this.pfpNftId,
    required this.pfpImageUrl,
  });

  const UserProfileEntity.empty()
      : nickName = '',
        introduction = '',
        locationPublic = false,
        pfpNftId = '',
        pfpImageUrl = '';

  @override
  List<Object?> get props {
    return [
      nickName,
      introduction,
      locationPublic,
      pfpNftId,
      pfpImageUrl,
    ];
  }

  UserProfileEntity copyWith({
    String? nickName,
    String? introduction,
    bool? locationPublic,
    String? pfpNftId,
    String? pfpImageUrl,
  }) {
    return UserProfileEntity(
      nickName: nickName ?? this.nickName,
      introduction: introduction ?? this.introduction,
      locationPublic: locationPublic ?? this.locationPublic,
      pfpNftId: pfpNftId ?? this.pfpNftId,
      pfpImageUrl: pfpImageUrl ?? this.pfpImageUrl,
    );
  }
}
