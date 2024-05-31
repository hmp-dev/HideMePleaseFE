part of 'home_cubit.dart';

class HomeState extends BaseState {
  final HomeViewType homeViewType;

  const HomeState({
    this.status = RequestStatus.initial,
    this.homeViewType = HomeViewType.BeforeLogin,
  });

  @override
  final RequestStatus status;

  factory HomeState.initial() => const HomeState();

  @override
  List<Object?> get props => [status, homeViewType];

  @override
  String toString() =>
      'HomeState(status: $status, homeViewType: $homeViewType)';

  @override
  HomeState copyWith({
    RequestStatus? status,
    HomeViewType? homeViewType,
  }) {
    return HomeState(
      status: status ?? this.status,
      homeViewType: homeViewType ?? this.homeViewType,
    );
  }
}
