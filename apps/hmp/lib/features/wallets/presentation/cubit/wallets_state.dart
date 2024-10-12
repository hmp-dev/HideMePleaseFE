part of 'wallets_cubit.dart';

/// State class for the Wallets feature.
///
/// This class holds the current state of the Wallets feature, including the
/// [W3MService], list of [ConnectedWalletEntity], [RequestStatus], and
/// [errorMessage].
class WalletsState extends BaseState {
  /// The Wallet Connect service.
  final W3MService? w3mService;

  /// The list of connected wallets.
  final List<ConnectedWalletEntity> connectedWallets;

  /// The error message.
  final bool isEventViewActive;

  /// The error message.
  final String errorMessage;

  /// The request status.
  @override
  final RequestStatus submitStatus;

  /// Creates a [WalletsState] with the given parameters.
  const WalletsState({
    this.w3mService,
    required this.connectedWallets,
    this.submitStatus = RequestStatus.initial,
    this.isEventViewActive = false,
    required this.errorMessage,
  });

  /// Creates an initial [WalletsState].
  factory WalletsState.initial() => const WalletsState(
        w3mService: null,
        connectedWallets: [],
        submitStatus: RequestStatus.initial,
        isEventViewActive: false,
        errorMessage: "",
      );

  /// Checks if Klip wallet is connected.
  ///
  /// Returns `true` if there is at least one connected wallet with the
  /// provider 'klip'. Otherwise, returns `false`.
  bool get isKlipWalletConnected => connectedWallets
      .where((element) => element.provider.toLowerCase() == 'klip')
      .isNotEmpty;

  bool get isWepinWalletConnected => connectedWallets
      .where((element) => element.provider.toLowerCase() == 'wepin_evm')
      .isNotEmpty;

  /// The list of objects to be used for equality checks.
  @override
  List<Object?> get props => [
        w3mService,
        connectedWallets,
        submitStatus,
        isEventViewActive,
        errorMessage,
      ];

  /// Creates a copy of the [WalletsState] with the given parameters.
  ///
  /// If a parameter is not provided, the corresponding field from the current
  /// instance will be used.
  @override
  WalletsState copyWith({
    W3MService? w3mService,
    List<ConnectedWalletEntity>? connectedWallets,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    bool? isEventViewActive,
    String? errorMessage,
  }) {
    return WalletsState(
      w3mService: w3mService ?? this.w3mService,
      connectedWallets: connectedWallets ?? this.connectedWallets,
      submitStatus: submitStatus ?? this.submitStatus,
      isEventViewActive: isEventViewActive ?? this.isEventViewActive,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
