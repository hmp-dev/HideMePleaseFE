import 'package:equatable/equatable.dart';

class SirenCreateResponseEntity extends Equatable {
  final bool success;
  final String sirenId;
  final int pointsSpent;
  final int remainingBalance;

  const SirenCreateResponseEntity({
    required this.success,
    required this.sirenId,
    required this.pointsSpent,
    required this.remainingBalance,
  });

  const SirenCreateResponseEntity.empty()
      : success = false,
        sirenId = '',
        pointsSpent = 0,
        remainingBalance = 0;

  @override
  List<Object?> get props => [success, sirenId, pointsSpent, remainingBalance];
}
