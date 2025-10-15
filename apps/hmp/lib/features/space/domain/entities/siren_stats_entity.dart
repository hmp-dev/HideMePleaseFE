import 'package:equatable/equatable.dart';

class SirenStatsEntity extends Equatable {
  final int activeSirensCount;
  final int totalSirensCount;

  const SirenStatsEntity({
    required this.activeSirensCount,
    required this.totalSirensCount,
  });

  const SirenStatsEntity.empty()
      : activeSirensCount = 0,
        totalSirensCount = 0;

  @override
  List<Object?> get props => [activeSirensCount, totalSirensCount];
}
