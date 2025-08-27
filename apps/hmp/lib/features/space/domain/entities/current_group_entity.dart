import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/check_in_user_entity.dart';

class CurrentGroupEntity extends Equatable {
  final String groupId;
  final String progress;
  final bool isCompleted;
  final List<CheckInUserEntity> members;
  final int bonusPoints;

  const CurrentGroupEntity({
    required this.groupId,
    required this.progress,
    required this.isCompleted,
    required this.members,
    required this.bonusPoints,
  });

  @override
  List<Object?> get props => [groupId, progress, isCompleted, members, bonusPoints];
}
