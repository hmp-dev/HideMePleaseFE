part of 'wepin_cubit.dart';

class WepinState extends BaseState {
  final WepinLifeCycle wepinLifeCycleStatus;
  final List<WepinAccount> accounts;
  final List<WepinNFT> nfts;
  final List<WepinAccountBalanceInfo> balances;
  final String? userEmail;
  @override
  final bool isLoading;
  final String? error;

  @override
  final RequestStatus submitStatus;

  const WepinState({
    this.submitStatus = RequestStatus.initial,
    required this.wepinLifeCycleStatus,
    this.accounts = const [],
    this.nfts = const [],
    this.balances = const [],
    this.userEmail,
    this.isLoading = false,
    this.error,
  });

  factory WepinState.initial() => const WepinState(
        wepinLifeCycleStatus: WepinLifeCycle.notInitialized,
        isLoading: true,
        accounts: [],
        nfts: [],
        balances: [],
      );

  @override
  List<Object?> get props => [
        submitStatus,
        wepinLifeCycleStatus,
        accounts,
        nfts,
        balances,
        userEmail,
        isLoading,
        error,
      ];

  @override
  WepinState copyWith({
    RequestStatus? submitStatus,
    WepinLifeCycle? lifeCycle,
    List<WepinAccount>? accounts,
    List<WepinNFT>? nfts,
    List<WepinAccountBalanceInfo>? balances,
    String? userEmail,
    bool? isLoading,
    String? error,
  }) {
    return WepinState(
      submitStatus: submitStatus ?? this.submitStatus,
      wepinLifeCycleStatus: lifeCycle ?? wepinLifeCycleStatus,
      accounts: accounts ?? this.accounts,
      nfts: nfts ?? this.nfts,
      balances: balances ?? this.balances,
      userEmail: userEmail ?? this.userEmail,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
