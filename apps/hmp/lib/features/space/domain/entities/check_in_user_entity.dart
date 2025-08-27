import 'package:equatable/equatable.dart';

class CheckInUserEntity extends Equatable {
  final String userId;
  final String nickName;
  final String? profileImageUrl;
  final DateTime checkedInAt;

  const CheckInUserEntity({
    required this.userId,
    required this.nickName,
    this.profileImageUrl,
    required this.checkedInAt,
  });

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl, checkedInAt];
}
