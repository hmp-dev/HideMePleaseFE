part of 'home_cubit.dart';

class HomeState extends BaseState {
  final HomeViewType homeViewType;

  const HomeState({
    this.submitStatus = RequestStatus.initial,
    this.homeViewType = HomeViewType.beforeWalletConnected,
  });

  @override
  final RequestStatus submitStatus;

  factory HomeState.initial() => const HomeState();

  @override
  List<Object?> get props => [submitStatus, homeViewType];

  @override
  String toString() =>
      'HomeState(status: $submitStatus, homeViewType: $homeViewType)';

  @override
  HomeState copyWith({
    RequestStatus? status,
    HomeViewType? homeViewType,
  }) {
    return HomeState(
      submitStatus: status ?? submitStatus,
      homeViewType: homeViewType ?? this.homeViewType,
    );
  }
}
