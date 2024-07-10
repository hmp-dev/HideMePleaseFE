part of 'auth_cubit.dart';

class AuthState extends BaseState {
  final bool isLogInSuccessful;
  final String message;

  @override
  final RequestStatus submitStatus;

  const AuthState({
    required this.isLogInSuccessful,
    this.submitStatus = RequestStatus.initial,
    this.message = "",
  });

  factory AuthState.initial() => const AuthState(
        isLogInSuccessful: false,
        submitStatus: RequestStatus.initial,
        message: "",
      );

  @override
  List<Object?> get props => [
        isLogInSuccessful,
        submitStatus,
        message,
      ];

  @override
  AuthState copyWith({
    bool? isLogInSuccessful,
    RequestStatus? submitStatus,
    String? message,
  }) {
    return AuthState(
      isLogInSuccessful: isLogInSuccessful ?? this.isLogInSuccessful,
      submitStatus: submitStatus ?? this.submitStatus,
      message: message ?? this.message,
    );
  }
}
