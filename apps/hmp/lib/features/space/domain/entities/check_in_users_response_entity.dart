import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/check_in_user_entity.dart';
import 'package:mobile/features/space/domain/entities/current_group_entity.dart';

class CheckInUsersResponseEntity extends Equatable {
  final int totalCount;
  final List<CheckInUserEntity> users;
  final CurrentGroupEntity? currentGroup;

  const CheckInUsersResponseEntity({
    required this.totalCount,
    required this.users,
    this.currentGroup,
  });

  @override
  List<Object?> get props => [totalCount, users, currentGroup];
}
