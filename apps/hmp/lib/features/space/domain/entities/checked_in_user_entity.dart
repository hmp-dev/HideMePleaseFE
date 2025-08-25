import 'package:equatable/equatable.dart';

class CheckedInUserEntity extends Equatable {
  final String userId;
  final String nickName;
  final DateTime checkedInAt;

  const CheckedInUserEntity({
    required this.userId,
    required this.nickName,
    required this.checkedInAt,
  });

  @override
  List<Object?> get props => [userId, nickName, checkedInAt];
}
