part of 'auth_cubit.dart';

class AuthState extends BaseState {
  final bool isLogInSuccessful;
  final String message;
  final WepinWidgetSDK? wepinSDK;

  @override
  final RequestStatus submitStatus;

  const AuthState({
    required this.isLogInSuccessful,
    this.submitStatus = RequestStatus.initial,
    this.message = "",
    this.wepinSDK,
  });

  factory AuthState.initial() => const AuthState(
        isLogInSuccessful: false,
        submitStatus: RequestStatus.initial,
        message: "",
        wepinSDK: null,
      );

  @override
  List<Object?> get props => [
        isLogInSuccessful,
        submitStatus,
        message,
        wepinSDK,
      ];

  @override
  AuthState copyWith({
    bool? isLogInSuccessful,
    RequestStatus? submitStatus,
    String? message,
    WepinWidgetSDK? wepinSDK,
  }) {
    return AuthState(
      isLogInSuccessful: isLogInSuccessful ?? this.isLogInSuccessful,
      submitStatus: submitStatus ?? this.submitStatus,
      message: message ?? this.message,
      wepinSDK: wepinSDK ?? this.wepinSDK,
    );
  }
}
