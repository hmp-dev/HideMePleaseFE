import 'package:equatable/equatable.dart';

class SirenAuthorEntity extends Equatable {
  final String userId;
  final String nickName;
  final String profileImageUrl;

  const SirenAuthorEntity({
    required this.userId,
    required this.nickName,
    required this.profileImageUrl,
  });

  const SirenAuthorEntity.empty()
      : userId = '',
        nickName = '',
        profileImageUrl = '';

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl];
}
