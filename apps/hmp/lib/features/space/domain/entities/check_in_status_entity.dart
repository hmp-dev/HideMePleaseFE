import 'package:equatable/equatable.dart';

class CheckInStatusEntity extends Equatable {
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final String groupProgress;
  final int earnedPoints;
  final String groupId;

  const CheckInStatusEntity({
    required this.isCheckedIn,
    this.checkedInAt,
    required this.groupProgress,
    required this.earnedPoints,
    required this.groupId,
  });

  @override
  List<Object?> get props => [
        isCheckedIn,
        checkedInAt,
        groupProgress,
        earnedPoints,
        groupId,
      ];
}
