part of 'points_cubit.dart';

class PointsState extends BaseState {
  final List<NftPointsEntity> nftPointsList;
  @override
  final RequestStatus status;

  const PointsState({
    required this.nftPointsList,
    required this.status,
  });

  factory PointsState.initial() => const PointsState(
        nftPointsList: [],
        status: RequestStatus.initial,
      );

  @override
  List<Object?> get props => [
        nftPointsList,
        status,
      ];

  @override
  PointsState copyWith({
    List<NftPointsEntity>? nftPointsList,
    RequestStatus? status,
  }) {
    return PointsState(
      nftPointsList: nftPointsList ?? this.nftPointsList,
      status: status ?? this.status,
    );
  }
}
