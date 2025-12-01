import 'package:equatable/equatable.dart';

class ActiveCheckInEntity extends Equatable {
  final String spaceId;
  final String spaceName;
  final DateTime checkedInAt;

  const ActiveCheckInEntity({
    required this.spaceId,
    required this.spaceName,
    required this.checkedInAt,
  });

  @override
  List<Object?> get props => [spaceId, spaceName, checkedInAt];
}
