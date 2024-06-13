part of 'nick_name_cubit.dart';

class NickNameState extends BaseState {
  final bool isNickNameAvailable;
  final String errorMessage;
  final String nickName;
  final bool nickNameError;

  @override
  final RequestStatus status;

  const NickNameState({
    required this.isNickNameAvailable,
    required this.status,
    required this.errorMessage,
    required this.nickName,
    required this.nickNameError,
  });

  factory NickNameState.initial() => const NickNameState(
        isNickNameAvailable: false,
        status: RequestStatus.initial,
        errorMessage: '',
        nickName: '',
        nickNameError: false,
      );

  @override
  List<Object?> get props =>
      [isNickNameAvailable, status, errorMessage, nickName, nickNameError];

  @override
  NickNameState copyWith({
    bool? isNickNameAvailable,
    RequestStatus? status,
    String? errorMessage,
    String? nickName,
    bool? nickNameError,
  }) {
    return NickNameState(
      isNickNameAvailable: isNickNameAvailable ?? this.isNickNameAvailable,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nickName: nickName ?? this.nickName,
      nickNameError: nickNameError ?? this.nickNameError,
    );
  }
}
