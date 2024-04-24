part of 'wallets_cubit.dart';

class WalletsState extends BaseState {
  final List<ConnectedWalletEntity> connectedWallets;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const WalletsState({
    required this.connectedWallets,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
  });

  factory WalletsState.initial() => const WalletsState(
        connectedWallets: [],
        submitStatus: RequestStatus.initial,
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        connectedWallets,
        submitStatus,
        errorMessage,
      ];

  @override
  WalletsState copyWith({
    List<ConnectedWalletEntity>? connectedWallets,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
  }) {
    return WalletsState(
      connectedWallets: connectedWallets ?? this.connectedWallets,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
