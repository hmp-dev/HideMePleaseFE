part of 'wallets_cubit.dart';

class WalletsState extends BaseState {
  final W3MService? w3mService;
  final List<ConnectedWalletEntity> connectedWallets;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const WalletsState({
    this.w3mService,
    required this.connectedWallets,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
  });

  factory WalletsState.initial() => const WalletsState(
        w3mService: null,
        connectedWallets: [],
        submitStatus: RequestStatus.initial,
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        w3mService,
        connectedWallets,
        submitStatus,
        errorMessage,
      ];

  @override
  WalletsState copyWith({
    W3MService? w3mService,
    List<ConnectedWalletEntity>? connectedWallets,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
  }) {
    return WalletsState(
      w3mService: w3mService ?? this.w3mService,
      connectedWallets: connectedWallets ?? this.connectedWallets,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
