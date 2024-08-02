part of 'home_cubit.dart';

/// Represents the state of the home screen.
///
/// It contains the status of the submission,
/// and the current view type of the home screen.
class HomeState extends BaseState {
  // The current view type of the home screen.
  final HomeViewType homeViewType;

  /// Initializes an instance of [HomeState] with the given values.
  ///
  /// If [submitStatus] is not provided, it defaults to [RequestStatus.initial].
  /// If [homeViewType] is not provided, it defaults to [HomeViewType.beforeWalletConnected].
  const HomeState({
    this.submitStatus = RequestStatus.initial,
    this.homeViewType = HomeViewType.beforeWalletConnected,
  });

  /// The status of the submission.
  @override
  final RequestStatus submitStatus;

  /// Returns an instance of [HomeState] with the initial values.
  factory HomeState.initial() => const HomeState();

  /// Returns a list of objects that determine the equality of this object.
  @override
  List<Object?> get props => [submitStatus, homeViewType];

  /// Returns a string representation of this object.
  @override
  String toString() =>
      'HomeState(status: $submitStatus, homeViewType: $homeViewType)';

  /// Returns a copy of this object with the given values updated.
  ///
  /// If [status] is not provided, the value of [submitStatus] is used.
  /// If [homeViewType] is not provided, the value of [this.homeViewType] is used.
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
