part of 'wepin_cubit.dart';

class WepinState extends BaseState {
  final String socialTokenIsAppleOrGoogle;
  final String appleIdToken;
  final String googleAccessToken;
  final WepinWidgetSDK? wepinWidgetSDK;
  final WepinLifeCycle wepinLifeCycleStatus;
  final List<WepinAccount> accounts;
  final bool isPerformWepinWalletSave;
  final bool isPerformWepinWelcomeNftRedeem;
  final bool isWepinModelOpen;

  @override
  final bool isLoading;
  final String? error;

  @override
  final RequestStatus submitStatus;

  const WepinState({
    this.socialTokenIsAppleOrGoogle = '',
    this.appleIdToken = '',
    this.googleAccessToken = '',
    this.wepinWidgetSDK,
    this.submitStatus = RequestStatus.initial,
    required this.wepinLifeCycleStatus,
    this.accounts = const [],
    this.isPerformWepinWalletSave = false,
    this.isPerformWepinWelcomeNftRedeem = false,
    this.isWepinModelOpen = false,
    this.isLoading = false,
    this.error,
  });

  factory WepinState.initial() => const WepinState(
        socialTokenIsAppleOrGoogle: '',
        appleIdToken: '',
        googleAccessToken: '',
        wepinWidgetSDK: null,
        wepinLifeCycleStatus: WepinLifeCycle.notInitialized,
        isLoading: true,
        accounts: [],
        isPerformWepinWalletSave: false,
        isPerformWepinWelcomeNftRedeem: false,
        isWepinModelOpen: false,
      );

  @override
  List<Object?> get props => [
        wepinWidgetSDK,
        socialTokenIsAppleOrGoogle,
        appleIdToken,
        googleAccessToken,
        submitStatus,
        wepinLifeCycleStatus,
        accounts,
        isPerformWepinWalletSave,
        isPerformWepinWelcomeNftRedeem,
        isWepinModelOpen,
        isLoading,
        error,
      ];

  @override
  WepinState copyWith({
    WepinWidgetSDK? wepinWidgetSDK,
    String? socialTokenIsAppleOrGoogle,
    String? appleIdToken,
    String? googleAccessToken,
    RequestStatus? submitStatus,
    WepinLifeCycle? wepinLifeCycleStatus,
    List<WepinAccount>? accounts,
    bool? isPerformWepinWalletSave,
    bool? isPerformWepinWelcomeNftRedeem,
    bool? isWepinModelOpen,
    bool? isLoading,
    String? error,
  }) {
    return WepinState(
      wepinWidgetSDK: wepinWidgetSDK ?? this.wepinWidgetSDK,
      socialTokenIsAppleOrGoogle:
          socialTokenIsAppleOrGoogle ?? this.socialTokenIsAppleOrGoogle,
      appleIdToken: appleIdToken ?? this.appleIdToken,
      googleAccessToken: googleAccessToken ?? this.googleAccessToken,
      submitStatus: submitStatus ?? this.submitStatus,
      wepinLifeCycleStatus: wepinLifeCycleStatus ?? this.wepinLifeCycleStatus,
      accounts: accounts ?? this.accounts,
      isPerformWepinWalletSave:
          isPerformWepinWalletSave ?? this.isPerformWepinWalletSave,
      isPerformWepinWelcomeNftRedeem:
          isPerformWepinWelcomeNftRedeem ?? this.isPerformWepinWelcomeNftRedeem,
      isWepinModelOpen: isWepinModelOpen ?? this.isWepinModelOpen,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
