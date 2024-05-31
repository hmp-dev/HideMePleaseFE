part of 'app_cubit.dart';

class AppState extends BaseState {
  final bool isLoggedIn;

  @override
  final RequestStatus status;

  const AppState({
    required this.isLoggedIn,
    this.status = RequestStatus.initial,
  });

  factory AppState.initial() => const AppState(
        isLoggedIn: false,
        status: RequestStatus.initial,
      );

  @override
  List<Object?> get props => [isLoggedIn, status];

  @override
  AppState copyWith(
      {bool? isLoggedIn,
      RequestStatus? status,
      bool? isLoggedOutFromDeleteAccount}) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      status: status ?? this.status,
    );
  }
}
