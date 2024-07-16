part of 'app_cubit.dart';

class AppState extends BaseState {
  final bool isLoggedIn;
  final bool initialized;

  @override
  final RequestStatus submitStatus;

  const AppState({
    required this.isLoggedIn,
    this.initialized = false,
    this.submitStatus = RequestStatus.initial,
  });

  factory AppState.initial() => const AppState(
        isLoggedIn: false,
        initialized: false,
        submitStatus: RequestStatus.initial,
      );

  @override
  List<Object?> get props => [isLoggedIn, submitStatus, initialized];

  @override
  AppState copyWith({
    bool? isLoggedIn,
    RequestStatus? status,
    bool? initialized,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      submitStatus: status ?? submitStatus,
      initialized: initialized ?? this.initialized,
    );
  }
}
