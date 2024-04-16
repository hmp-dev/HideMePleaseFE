part of 'app_cubit.dart';

class AppState extends BaseState {
  final bool isLoggedIn;

  @override
  final RequestStatus submitStatus;

  const AppState({
    required this.isLoggedIn,
    this.submitStatus = RequestStatus.initial,
  });

  factory AppState.initial() => const AppState(
        isLoggedIn: false,
        submitStatus: RequestStatus.initial,
      );

  @override
  List<Object?> get props => [isLoggedIn, submitStatus];

  @override
  AppState copyWith({
    bool? isLoggedIn,
    RequestStatus? status,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      submitStatus: status ?? submitStatus,
    );
  }
}
