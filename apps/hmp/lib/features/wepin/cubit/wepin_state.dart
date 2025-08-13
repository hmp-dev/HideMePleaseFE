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
  final bool isCountDownFinished;
  final bool isCheckingWallet;
  final int walletCheckCounter;
  final bool isOnboardingFlow;
  final bool walletCreatedFromOnboarding;

  @override
  final bool isLoading;
  final String? error;

  @override
  final RequestStatus submitStatus;

  @override
  RequestStatus get status {
    if (error != null && error!.isNotEmpty) {
      return RequestStatus.failure;
    }
    if (isLoading) {
      return RequestStatus.loading;
    }
    if (wepinLifeCycleStatus == WepinLifeCycle.login && accounts.isNotEmpty) {
      return RequestStatus.success;
    }
    return RequestStatus.initial;
  }

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
    this.isCountDownFinished = false,
    this.isCheckingWallet = false,
    this.walletCheckCounter = 0,
    this.isOnboardingFlow = false,
    this.walletCreatedFromOnboarding = false,
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
        isCountDownFinished: false,
        isWepinModelOpen: false,
        isCheckingWallet: false,
        walletCheckCounter: 0,
        isOnboardingFlow: false,
        walletCreatedFromOnboarding: false,
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
        isCountDownFinished,
        isCheckingWallet,
        walletCheckCounter,
        isOnboardingFlow,
        walletCreatedFromOnboarding,
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
    bool? isCountDownFinished,
    bool? isCheckingWallet,
    int? walletCheckCounter,
    bool? isOnboardingFlow,
    bool? walletCreatedFromOnboarding,
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
      isCountDownFinished: isCountDownFinished ?? this.isCountDownFinished,
      isCheckingWallet: isCheckingWallet ?? this.isCheckingWallet,
      walletCheckCounter: walletCheckCounter ?? this.walletCheckCounter,
      isOnboardingFlow: isOnboardingFlow ?? this.isOnboardingFlow,
      walletCreatedFromOnboarding: walletCreatedFromOnboarding ?? this.walletCreatedFromOnboarding,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
