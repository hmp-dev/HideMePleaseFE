import 'package:equatable/equatable.dart';

class CheckInResponseEntity extends Equatable {
  final bool success;
  final String checkInId;
  final String groupProgress;
  final int earnedPoints;

  const CheckInResponseEntity({
    required this.success,
    required this.checkInId,
    required this.groupProgress,
    required this.earnedPoints,
  });

  @override
  List<Object?> get props => [
        success,
        checkInId,
        groupProgress,
        earnedPoints,
      ];
}
