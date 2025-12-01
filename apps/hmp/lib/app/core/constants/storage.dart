abstract class StorageValues {
  static const String accessToken = 'accessToken';
  static const String userId = 'userId';
  static const String refreshToken = 'refreshToken';
  static const String talkPlusToken = 'talkPlusToken';
  static const String talkPlusUserId = 'talkPlusUserId';

  static const String googleAccessToken = 'googleAccessToken';
  static const String googleIdToken = 'googleIdToken';
  static const String appleIdToken = 'appleIdToken';

  static const String socialTokenIsAppleOrGoogle = 'socialTokenIsAppleOrGoogle';

  // Authentication status flag (for auto-login validation)
  static const String isAuthenticated = 'isAuthenticated';
  static const String wasOnWelcomeWalletConnectScreen = 'wasOnWelcomeWalletConnectScreen';
  static const String wepinToken = 'wepinToken';
  
  // Onboarding related constants
  static const String onboardingCurrentStep = 'onboardingCurrentStep';
  static const String onboardingCompleted = 'onboardingCompleted';
  static const String showOnboardingAfterLogout = 'showOnboardingAfterLogout';
  static const String onboardingVersion = 'onboardingVersion';
  static const int CURRENT_ONBOARDING_VERSION = 2; // 새 온보딩 버전
  
  // Wallet and Profile status
  static const String hasWallet = 'hasWallet';
  static const String hasProfileParts = 'hasProfileParts';
  
  // NFT Minting status
  static const String hasMintedNft = 'hasMintedNft';
  static const String mintingTransactionId = 'mintingTransactionId';
  
  // Check-in related constants
  static const String activeCheckInSpaceId = 'activeCheckInSpaceId';
  static const String checkInTimestamp = 'checkInTimestamp';
  static const String checkInLatitude = 'checkInLatitude';
  static const String checkInLongitude = 'checkInLongitude';
  static const String checkInSpaceName = 'checkInSpaceName';
  static const String checkInBenefitId = 'checkInBenefitId';
  static const String checkInBenefitDescription = 'checkInBenefitDescription';

  // Daily check-in tracking
  static const String dailyCheckedInSpaces = 'dailyCheckedInSpaces';
  static const String lastCheckInDate = 'lastCheckInDate';
}
