import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/services/image_retry_service.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/onboarding/presentation/widgets/page_pop_view.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_first.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_second.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_third.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_fourth.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_fifth.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_wallet_exists.dart';
import 'package:mobile/features/onboarding/presentation/widgets/onboarding_page_profile_exists.dart';
import 'package:mobile/features/onboarding/presentation/widgets/test_onboarding_widget.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/onboarding/presentation/widgets/gradient_button.dart';
import 'package:mobile/features/onboarding/models/character_profile.dart';
import 'package:mobile/features/onboarding/services/character_image_service.dart';
import 'package:mobile/features/onboarding/services/image_upload_service.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';
import 'package:mobile/features/nft/infrastructure/dtos/mint_nft_request_dto.dart';
import 'package:mobile/app/core/env/app_env.dart';

/// OnBoardingScreen is a stateful widget that represents the onboarding screen.
///
/// It is responsible for displaying the onboarding slides to the user.
/// The widget is implemented using the stateful widget pattern where the
/// state is managed by the [_OnBoardingScreenState] class.
class OnBoardingScreen extends StatefulWidget {
  /// Creates a new instance of [OnBoardingScreen].
  ///
  /// The [key] parameter is used to uniquely identify the widget throughout the
  /// widget tree.
  const OnBoardingScreen({super.key});

  /// Pushes the [OnBoardingScreen] widget to the navigation stack.
  ///
  /// This method takes a [BuildContext] as a parameter and returns a [Future]
  /// that resolves to the result of the navigation. The widget is wrapped in a
  /// [MaterialPageRoute] and pushed onto the navigation stack using the
  /// [Navigator.push] method.
  static Future<T?> push<T extends Object?>(BuildContext context) async {
    return await Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => const OnBoardingScreen(),
      ),
    );
  }

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// This method is called when inflating the widget's element, and should
  /// return a new instance of the associated [State] class.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass.
  ///
  /// The framework will call this method multiple times over the lifetime of
  /// a [StatefulWidget], for example when the widget is inserted into the
  /// tree, when the widget is updated, or when the widget is removed from the
  /// tree. It is therefore critical that the [createState] method return
  /// consistently distinct objects.
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  var currentSlideIndex = 0;
  bool dontShowCheckBox = false;
  bool _isConfirming = false;
  bool _isCheckingWallet = false; // Add wallet checking state
  bool _hasExistingWallet = false; // Track if user has existing wallet
  bool _hasExistingProfile = false; // Track if user has existing profile parts
  bool _hasExistingNickname = false; // Track if user has existing nickname
  bool _isWepinInitialized = false; // Track if Wepin SDK is initialized
  bool _hasMintedNft = false; // Guard flag to prevent duplicate minting
  Timer? _walletCreationTimeoutTimer; // Timeout timer for wallet creation
  String selectedProfile = '';
  CharacterProfile? selectedCharacter;
  String nickname = '';
  bool _debugMode = false; // Debug mode flag
  // to prevent double tap while in process to check location and navigate

  @override
  void initState() {
    super.initState();
    
    // New onboarding screens (2 new + 2 existing)
    // Total 4 screens now

    // call function to check if location is enabled with error handling
    try {
      getIt<EnableLocationCubit>().checkLocationEnabled();
    } catch (e) {
      '❌ Error checking location: $e'.log();
    }
    
    // Load saved onboarding state
    _loadOnboardingState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize Wepin SDK only once when dependencies are ready
    if (!_isWepinInitialized) {
      _isWepinInitialized = true;
      _initializeWepin();
    }
  }

  Future<void> _initializeWepin() async {
    try {
      '🔧 Initializing Wepin SDK for onboarding...'.log();
      '📱 Current onboarding step: $currentSlideIndex'.log();
      
      final wepinCubit = getIt<WepinCubit>();
      
      // Initialize Wepin SDK with current language
      await wepinCubit.initializeWepinSDK(
        selectedLanguageCode: context.locale.languageCode,
      );
      
      '✅ Wepin SDK initialized successfully'.log();
      
      // Check for existing WePIN wallet after SDK is ready
      await _checkExistingWepinWallet();
    } catch (e) {
      '❌ Failed to initialize Wepin SDK: $e'.log();
    }
  }
  
  Future<void> _checkExistingWepinWallet() async {
    try {
      '🔍 Checking for existing WePIN wallet...'.log();
      
      final wepinCubit = getIt<WepinCubit>();
      if (wepinCubit.state.wepinWidgetSDK == null) {
        '⚠️ WePIN SDK not initialized for wallet check'.log();
        return;
      }
      
      // Check if user is registered with WePIN and has actual wallet
      bool isRegistered = false;
      bool hasActualWallet = false;
      
      try {
        // Try to get current user to check if registered
        final currentUser = await wepinCubit.state.wepinWidgetSDK!.login.getCurrentWepinUser();
        isRegistered = (currentUser != null && currentUser.userInfo != null);
        '🔍 WePIN user check: ${isRegistered ? "Existing user found" : "No user found"}'.log();
        
        if (isRegistered && currentUser!.userInfo != null) {
          '📧 Existing user email: ${currentUser.userInfo!.email}'.log();
          
          // Check if user has actual wallet addresses
          final walletsCubit = getIt<WalletsCubit>();
          await walletsCubit.onGetAllWallets();
          '💼 Connected wallets count: ${walletsCubit.state.connectedWallets.length}'.log();
          
          if (walletsCubit.state.connectedWallets.isNotEmpty) {
            // Check for Ethereum wallet specifically
            try {
              final ethereumWallet = walletsCubit.state.connectedWallets.firstWhere(
                (wallet) => wallet.provider.toLowerCase() == 'ethereum',
                orElse: () => walletsCubit.state.connectedWallets.first,
              );
              '💼 Found wallet: ${ethereumWallet.provider} - ${ethereumWallet.publicAddress}'.log();
              hasActualWallet = true;
            } catch (e) {
              '⚠️ Error finding wallet: $e'.log();
              hasActualWallet = false;
            }
          } else {
            '⚠️ WePIN user exists but no wallet addresses found'.log();
            hasActualWallet = false;
          }
        }
      } catch (e) {
        '⚠️ Error checking WePIN user: $e'.log();
      }
      
      if (isRegistered && hasActualWallet) {
        '✅ Existing WePIN user with wallet detected'.log();
        
        // Try to get the current status
        final status = await wepinCubit.state.wepinWidgetSDK!.getStatus();
        '📊 Current WePIN status: $status'.log();
        
        // User has both WePIN account and wallet address
        if (mounted) {
          setState(() {
            _hasExistingWallet = true;
          });
        }

        // Optionally try to login silently
        if (status == WepinLifeCycle.initialized) {
          try {
            '🔐 Attempting silent login for existing user...'.log();
            // This would need to be implemented based on stored credentials
            // For now, just mark that wallet exists
          } catch (e) {
            '⚠️ Silent login failed: $e'.log();
          }
        }
      } else if (isRegistered && !hasActualWallet) {
        '⚠️ WePIN user exists but no wallet - need to create wallet'.log();
        if (mounted) {
          setState(() {
            _hasExistingWallet = false;
          });
        }
      } else {
        '🆕 New WePIN user - will need to create account and wallet'.log();
        if (mounted) {
          setState(() {
            _hasExistingWallet = false;
          });
        }
      }
    } catch (e) {
      '❌ Error checking existing WePIN wallet: $e'.log();
    }
  }
  
  Future<void> _checkUserProfile() async {
    try {
      '🔍 Checking for existing user profile...'.log();

      // Get user profile to check for existing profile parts
      final profileCubit = getIt<ProfileCubit>();
      await profileCubit.onGetUserProfile();
      final userProfile = profileCubit.state.userProfileEntity;

      bool hasValidProfile = false;

      if (userProfile != null) {
        // Check if we have profile parts string
        // This is the only reliable indicator during onboarding
        // Image URL validation removed: image only exists AFTER profile is saved to server
        if (userProfile.profilePartsString != null && userProfile.profilePartsString!.isNotEmpty) {
          '✅ Profile parts exist: ${userProfile.profilePartsString!.length} characters'.log();
          hasValidProfile = true;
        }

        if (hasValidProfile) {
          '✅ Valid profile found - skipping character selection'.log();
          '   - ProfileParts: ${userProfile.profilePartsString?.isNotEmpty ?? false}'.log();
          '   - ValidImage: ${hasValidProfile}'.log();

          // Check if user has a nickname
          final hasNickname = userProfile.nickName?.isNotEmpty ?? false;
          '   - Nickname: ${hasNickname ? userProfile.nickName : "없음"}'.log();

          if (mounted) {
            setState(() {
              _hasExistingProfile = true;
              _hasExistingNickname = hasNickname;
            });
          }
        } else {
          '🆕 No valid profile found - character selection needed'.log();
          if (mounted) {
            setState(() {
              _hasExistingProfile = false;
              _hasExistingNickname = false;
            });
          }
        }
      } else {
        '🆕 No user profile - character selection needed'.log();
        if (mounted) {
          setState(() {
            _hasExistingProfile = false;
            _hasExistingNickname = false;
          });
        }
      }
    } catch (e) {
      '❌ Error checking user profile: $e'.log();
      if (mounted) {
        setState(() {
          _hasExistingProfile = false;
          _hasExistingNickname = false;
        });
      }
    }
  }

  /// Validate if an image URL actually contains valid image data
  /// Uses retry logic to handle server-side image generation delays
  Future<bool> _validateImageUrl(String imageUrl) async {
    try {
      // Don't validate empty URLs
      if (imageUrl.isEmpty) return false;

      '🔍 Starting image validation with retry logic for: $imageUrl'.log();

      // Use the ImageRetryService with fast onboarding mode
      final isValid = await ImageRetryService.validateImageWithRetry(imageUrl, isOnboarding: true);

      if (isValid) {
        '✅ Image validated successfully after retries'.log();
      } else {
        '❌ Image validation failed after all retries'.log();
      }

      return isValid;
    } catch (e) {
      'Error validating image URL: $e'.log();
      return false;
    }
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check debug mode
    //_debugMode = prefs.getBool(StorageValues.onboardingDebugMode) ?? false;
    
    // Always load saved step regardless of debug mode
    final savedStep = prefs.getInt(StorageValues.onboardingCurrentStep) ?? 0;
    
    // If there's a saved step > 0, show resume popup
    if (savedStep > 0 && mounted) {
      '📱 저장된 온보딩 단계 발견: $savedStep'.log();
      _showResumePopup(savedStep);
    } else {
      setState(() {
        currentSlideIndex = savedStep;
      });
    }
    
    if (_debugMode) {
      '🐛 디버그 모드 활성화 - 온보딩 표시 (저장된 단계: $savedStep)'.log();
    } else {
      '📱 온보딩 상태 복원: 스텝 $savedStep'.log();
    }
  }
  
  Future<void> _showResumePopup(int savedStep) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.onboarding_continue_process.tr(),
                  style: TextStyle(
                    fontFamily: 'LINESeedKR',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.onboarding_previous_process_found.tr(),
                  style: TextStyle(
                    fontFamily: 'LINESeedKR',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: '확인했어!',
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentSlideIndex = savedStep;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _saveCurrentStep() async {
    // Don't save if we're on the final page or if onboarding is completed
    if (currentSlideIndex >= 4) {
      '⏭️ 마지막 페이지 - 상태 저장 건너뛰기'.log();
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Check if onboarding is already completed
    final isCompleted = prefs.getBool(StorageValues.onboardingCompleted) ?? false;
    if (isCompleted) {
      '✅ 온보딩 이미 완료됨 - 상태 저장 건너뛰기'.log();
      return;
    }

    // Always save current step regardless of debug mode
    await prefs.setInt(StorageValues.onboardingCurrentStep, currentSlideIndex);
    '💾 온보딩 진행 상태 저장: 스텝 $currentSlideIndex'.log();
  }

  void _goToNextPage() async {
    // Hide keyboard if visible
    FocusScope.of(context).unfocus();
    
    if (currentSlideIndex == 0) {
      '🚀 첫 번째 온보딩 화면에서 다음 버튼 클릭'.log();
      
      // First page - check for Ethereum wallet
      bool hasWallet = await _checkEthereumWallet();
      
      setState(() {
        _hasExistingWallet = hasWallet;
      });
      
      if (hasWallet) {
        '✅ 지갑이 있음 - 지갑 있음 화면으로 이동'.log();
        // Show wallet exists page
        await _moveToPage(1);
      } else {
        '❌ 지갑이 없음 - 지갑 생성 화면으로 이동'.log();
        // No wallet, go to wallet creation page
        await _moveToPage(1);
      }
    } else if (currentSlideIndex == 1) {
      // From wallet page, check if user has existing profile
      await _checkUserProfile();

      if (_hasExistingWallet) {
        // User has existing wallet
        if (_hasExistingProfile) {
          '🆗 프로필 파츠 있음 - 프로필 존재 화면으로 이동'.log();
          await _moveToPage(2); // Show profile exists page
        } else {
          '🆕 프로필 파츠 없음 - 캐릭터 선택 화면으로 이동'.log();
          await _moveToPage(2); // Go to character selection
        }
      } else {
        // Just created wallet, check profile
        if (_hasExistingProfile) {
          '🆗 새 지갑 생성 + 프로필 존재 - 프로필 존재 화면으로'.log();
          await _moveToPage(2); // Show profile exists page
        } else {
          '🆕 새 지갑 생성 + 프로필 없음 - 캐릭터 선택으로'.log();
          await _moveToPage(2); // Go to character selection
        }
      }
    } else if (currentSlideIndex == 2 && _hasExistingProfile) {
      // From profile exists page, check if user has nickname
      if (_hasExistingNickname) {
        // User has both profile and nickname, skip to final page
        '✅ 프로필과 닉네임 모두 있음 - 완료 화면으로 이동'.log();
        await _moveToPage(4); // Skip nickname input, go to final page
      } else {
        // User has profile but no nickname, go to nickname input
        '⚠️ 프로필은 있지만 닉네임 없음 - 닉네임 입력 화면으로 이동'.log();
        await _moveToPage(3); // Go to nickname input page
      }
    } else if (currentSlideIndex < 4) {
      await _moveToPage(currentSlideIndex + 1);
    }
  }
  
  Future<void> _moveToPage(int pageIndex) async {
    setState(() {
      currentSlideIndex = pageIndex;
    });
    // Save state immediately when entering new page
    await _saveCurrentStep();
    '📍 온보딩 페이지 이동: $pageIndex'.log();
  }
  
  Future<bool> _checkEthereumWallet() async {
    try {
      // Check if Wepin SDK is initialized
      final wepinCubit = getIt<WepinCubit>();
      if (wepinCubit.state.wepinWidgetSDK == null) {
        '❌ Wepin SDK is not initialized'.log();
        return false;
      }
      
      // Check Wepin status
      final status = await wepinCubit.state.wepinWidgetSDK!.getStatus();
      '📊 Wepin status: $status'.log();
      
      // If not logged in, try to login first
      if (status == WepinLifeCycle.initialized) {
        '🔄 Wepin initialized but not logged in, attempting login...'.log();
        await wepinCubit.loginSocialAuthProvider();
        
        // Check status again after login attempt
        final newStatus = await wepinCubit.state.wepinWidgetSDK!.getStatus();
        '📊 Wepin status after login attempt: $newStatus'.log();
        
        if (newStatus != WepinLifeCycle.login) {
          '❌ Failed to login to Wepin'.log();
          return false;
        }
      } else if (status != WepinLifeCycle.login) {
        '❌ Wepin is not in login state and cannot proceed'.log();
        return false;
      }
      
      // Get accounts and check for Ethereum wallet
      final accounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
      '📋 Total accounts found: ${accounts.length}'.log();
      
      // Log all accounts
      for (var account in accounts) {
        '💳 Account - Network: ${account.network}, Address: ${account.address}'.log();
      }
      
      // Check for Ethereum accounts
      final ethereumAccounts = accounts.where((account) => 
        account.network.toLowerCase() == 'ethereum'
      ).toList();
      
      if (ethereumAccounts.isNotEmpty) {
        '✅ Found ${ethereumAccounts.length} Ethereum wallet(s)'.log();
        for (var eth in ethereumAccounts) {
          '🔷 Ethereum Address: ${eth.address}'.log();
        }
        return true;
      } else {
        '❌ No Ethereum wallet found'.log();
        return false;
      }
    } catch (e) {
      '❌ Error checking Ethereum wallet: $e'.log();
      return false;
    }
  }
  
  Future<void> _createWepinWallet() async {
    '🎯 지갑 생성 버튼 클릭됨!'.log();

    // Cancel any existing timeout timer
    _walletCreationTimeoutTimer?.cancel();

    // 세션 ID로 Crashlytics 로그 추적
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseCrashlytics.instance.setCustomKey('wallet_session_id', sessionId);
    await FirebaseCrashlytics.instance.log('[Wallet-$sessionId] _createWepinWallet initiated');

    try {
      // Set timeout timer (45 seconds - increased for backend processing)
      _walletCreationTimeoutTimer = Timer(const Duration(seconds: 45), () async {
        '⏰ Wallet creation timeout after 45 seconds'.log();
        await FirebaseCrashlytics.instance.log('[Onboarding] TIMEOUT: Wallet creation took more than 45 seconds');
        await logErrorWithDeviceInfo(
          'Wallet creation timeout',
          StackTrace.current,
          reason: 'Onboarding: 45 second timeout reached'
        );
        if (mounted && _isConfirming) {
          setState(() {
            _isConfirming = false;
          });
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('시간 초과'),
              content: Text('지갑 생성이 너무 오래 걸립니다.\n\n네트워크 상태를 확인하고 다시 시도해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createWepinWallet(); // 재시도
                  },
                  child: Text('다시 시도'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
              ],
            ),
          );
        }
      });

      final wepinCubit = getIt<WepinCubit>();

      // Check if SDK is initialized
      if (wepinCubit.state.wepinWidgetSDK == null) {
        '❌ Wepin SDK not initialized for wallet creation'.log();
        '🔄 Attempting to initialize Wepin SDK now...'.log();
        
        // Try to initialize SDK if not already done
        await wepinCubit.initializeWepinSDK(
          selectedLanguageCode: context.locale.languageCode,
        );
        
        // Check again after initialization
        if (wepinCubit.state.wepinWidgetSDK == null) {
          '❌ Failed to initialize Wepin SDK'.log();
          return;
        }
      }
      
      // Get current status
      var status = await wepinCubit.state.wepinWidgetSDK!.getStatus();
      '🔄 Wepin status before wallet creation: $status'.log();
      
      // Show loading
      setState(() {
        _isConfirming = true;
      });
      
      // Check if user is already registered with WePIN
      bool isRegistered = false;
      try {
        // Try to get current user to check if registered
        final currentUser = await wepinCubit.state.wepinWidgetSDK!.login.getCurrentWepinUser();
        isRegistered = (currentUser != null && currentUser.userInfo != null);
        '🔍 WePIN user check: ${isRegistered ? "Existing user found" : "No user found"}'.log();
        if (isRegistered && currentUser!.userInfo != null) {
          '📧 Existing user email: ${currentUser.userInfo!.email}'.log();
        }
      } catch (e) {
        '⚠️ Error checking WePIN user: $e'.log();
      }
      
      // If only initialized, need to login first using the new flow
      if (status == WepinLifeCycle.initialized) {
        '🔄 Wepin SDK initialized, performing login flow...'.log();
        
        try {
          // Get stored social login tokens (반환값 직접 사용 - state 동기화 문제 해결)
          final tokens = await wepinCubit.getSocialLoginValues();
          await FirebaseCrashlytics.instance.log('[Wallet] START: socialType=${tokens.socialType}, hasToken=${tokens.hasToken}');

          // Check if we have tokens for login (반환값 직접 사용)
          final socialType = tokens.socialType;
          final idToken = tokens.idToken;

          if (socialType == 'GOOGLE') {
            '🔑 Using Google ID token for Wepin login'.log();
          } else if (socialType == 'APPLE') {
            '🔑 Using Apple ID token for Wepin login'.log();
          }

          if (idToken.isEmpty) {
            '❌ No ID token available for Wepin login'.log();

            // Fallback: Open widget for OAuth login
            '📱 Opening Wepin widget for OAuth login...'.log();
            setState(() {
              _isConfirming = false;
            });

            // Open widget which will show login UI and wait for completion
            await wepinCubit.openWepinWidget(context);

            '📱 Wepin widget closed - checking wallet immediately'.log();

            // After WePIN OAuth login, check user status and save tokens
            await _checkAndSaveWepinUser();
            await _saveWepinTokensAfterOAuth();

            // Check status after widget closes
            try {
              final statusAfterWidget = await wepinCubit.state.wepinWidgetSDK!.getStatus();
              '📊 Wepin status after widget closed: $statusAfterWidget'.log();

              if (statusAfterWidget == WepinLifeCycle.login) {
                '✅ User registered and logged in, getting accounts immediately'.log();

                // Get accounts immediately - no polling needed!
                final accounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
                '💼 Found ${accounts.length} accounts immediately after registration'.log();

                if (accounts.isNotEmpty) {
                  // Save wallets to backend
                  '📍 Saving wallets to backend...'.log();
                  await wepinCubit.saveWalletsToHMPBackend(accounts);
                  '✅ Wallets saved successfully'.log();

                  // Check user profile
                  await _checkUserProfile();

                  setState(() {
                    _isConfirming = false;
                    _hasExistingWallet = true;
                  });

                  // Navigate to next page
                  if (_hasExistingProfile) {
                    '🆗 지갑 생성 완료 + 프로필 존재 - 프로필 화면으로'.log();
                  } else {
                    '🆕 지갑 생성 완료 + 프로필 없음 - 캐릭터 선택으로'.log();
                  }
                  await _moveToPage(2);
                  return;
                } else {
                  '⚠️ No accounts found after registration'.log();
                  setState(() => _isConfirming = false);
                  return;
                }
              } else {
                '⚠️ Not in login state after widget closed: $statusAfterWidget'.log();
                setState(() => _isConfirming = false);
                return;
              }
            } catch (e) {
              '❌ Error checking wallet after widget closed: $e'.log();
              setState(() => _isConfirming = false);
              return;
            }
          }
          
          // Perform login with ID token using the new flow
          '📍 Performing Wepin login with ID token...'.log();
          final wepinUser = await wepinCubit.loginSocialAuthProvider();

          if (wepinUser == null) {
            '❌ Login failed, opening widget for manual login'.log();

            setState(() {
              _isConfirming = false;
            });

            // Open widget for manual login
            await wepinCubit.openWepinWidget(context);

            await _checkAndSaveWepinUser();
            await _saveWepinTokensAfterOAuth();

            // Check status and handle wallet creation immediately
            final statusAfterWidget = await wepinCubit.state.wepinWidgetSDK!.getStatus();
            if (statusAfterWidget == WepinLifeCycle.login) {
              final accounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
              if (accounts.isNotEmpty) {
                await wepinCubit.saveWalletsToHMPBackend(accounts);
                await _checkUserProfile();
                setState(() {
                  _isConfirming = false;
                  _hasExistingWallet = true;
                });
                await _moveToPage(2);
              }
            }
            return;
          }

          // Check userStatus after login
          final userStatus = wepinUser.userStatus;
          '📊 User status after login: ${userStatus?.loginStatus}'.log();

          if (userStatus?.loginStatus != 'complete') {
            '📝 Registration required, calling register()'.log();

            // Call register and wait for completion
            final registeredUser = await wepinCubit.state.wepinWidgetSDK!.register(context);
            '✅ Registration complete: ${registeredUser.userStatus?.loginStatus}'.log();

            // Immediately get accounts after registration - NO POLLING!
            final accounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
            '💼 Found ${accounts.length} accounts after registration'.log();

            if (accounts.isNotEmpty) {
              await wepinCubit.saveWalletsToHMPBackend(accounts);
              await _checkUserProfile();

              setState(() {
                _isConfirming = false;
                _hasExistingWallet = true;
              });

              await _moveToPage(2);
              return;
            }
          }

          '✅ Login successful and user registration complete, checking wallets'.log();
          // Continue to check existing wallets below
          status = WepinLifeCycle.login;
        } catch (e) {
          '❌ Error during login flow: $e'.log();
          wepinCubit.stopWalletCheckTimer(); // Stop polling on error
          setState(() {
            _isConfirming = false;
          });
          return;
        }
      }
      
      // Handle based on WePIN status
      if (status == WepinLifeCycle.login) {
        '🔍 Already logged in, checking existing wallets...'.log();

        // User is already logged in, check if they have wallets
        '📍 Step 0: Getting Wepin accounts...'.log();
        await FirebaseCrashlytics.instance.log('[Onboarding] Step 0: Getting Wepin accounts');
        final accounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
        '✅ Step 0 Complete: Found ${accounts.length} accounts'.log();
        await FirebaseCrashlytics.instance.log('[Onboarding] Step 0 Complete: Found ${accounts.length} accounts');
        '📋 Account details: ${accounts.map((a) => '${a.network}:${a.address.substring(0, 10)}...').join(", ")}'.log();
        
        if (accounts.isNotEmpty) {
          // User already has wallets
          for (var account in accounts) {
            '💳 Existing - Network: ${account.network}, Address: ${account.address}'.log();
          }
          
          final ethereumAccounts = accounts.where((account) => 
            account.network.toLowerCase() == 'ethereum'
          ).toList();
          
          if (ethereumAccounts.isNotEmpty) {
            '✅ Ethereum wallet already exists!'.log();

            // Save wallets to backend (in case not saved)
            '📍 Step 1: Saving wallets to backend...'.log();
            await FirebaseCrashlytics.instance.log('[Onboarding] Step 1: Saving wallets to backend');
            try {
              await wepinCubit.saveWalletsToHMPBackend(accounts);
              '✅ Step 1 Complete: Wallets saved successfully'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Step 1 Complete: Wallets saved successfully');
            } catch (e) {
              '❌ Step 1 Failed: Failed to save wallets to backend: $e'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Step 1 FAILED: $e');
              await logErrorWithDeviceInfo(e, StackTrace.current, reason: 'Onboarding: Save wallets to backend failed');
              if (mounted) {
                setState(() => _isConfirming = false);
                final retry = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Text('지갑 저장 실패'),
                    content: Text('지갑 정보를 서버에 저장하지 못했습니다.\n\n에러: $e\n\n다시 시도하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('재시도'),
                      ),
                    ],
                  ),
                );
                if (retry == true) {
                  return _createWepinWallet();
                }
              }
              return;
            }

            // Wait for profile check to complete before moving to next page
            '📍 Step 2: Checking user profile...'.log();
            await FirebaseCrashlytics.instance.log('[Onboarding] Step 2: Checking user profile');
            try {
              await _checkUserProfile();
              '✅ Step 2 Complete: Profile check done (exists: $_hasExistingProfile)'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Step 2 Complete: Profile exists=$_hasExistingProfile');
            } catch (e) {
              '❌ Step 2 Failed: Failed to check user profile: $e'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Step 2 FAILED: $e');
              await logErrorWithDeviceInfo(e, StackTrace.current, reason: 'Onboarding: Check user profile failed');
              // 기본값으로 설정 (새 사용자로 간주)
              setState(() {
                _hasExistingProfile = false;
              });
              '⚠️ Assuming new user due to profile check failure'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Assuming new user (profile check failed)');
            }

            setState(() {
              _isConfirming = false;
              _hasExistingWallet = true;
            });

            if (_hasExistingProfile) {
              '🆗 지갑 생성 완료 + 프로필 존재 - 프로필 화면으로'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] SUCCESS: Wallet exists + Profile exists -> Moving to profile page');
              await _moveToPage(2); // Show profile exists page
            } else {
              '🆕 지갑 생성 완료 + 프로필 없음 - 캐릭터 선택으로'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] SUCCESS: Wallet exists + New user -> Moving to character selection');
              await _moveToPage(2); // Move to character selection
            }
          } else {
            '⚠️ Has wallets but no Ethereum wallet'.log();
            // May need to create Ethereum wallet specifically
            setState(() {
              _isConfirming = false;
            });
          }
        } else {
          '⚠️ Logged in but no wallets found - may need finalize'.log();
          
          // Try to finalize wallet creation
          try {
            '🔄 Attempting to finalize wallet creation...'.log();
            await wepinCubit.state.wepinWidgetSDK!.finalize();
            
            // Check accounts again
            final newAccounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
            if (newAccounts.isNotEmpty) {
              '✅ Wallets created after finalize'.log();

              '📍 Step 1 (Finalize): Saving wallets to backend...'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Step 1 (Finalize): Saving wallets to backend');
              try {
                await wepinCubit.saveWalletsToHMPBackend(newAccounts);
                '✅ Step 1 (Finalize) Complete: Wallets saved successfully'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] Step 1 (Finalize) Complete: Wallets saved');
              } catch (e) {
                '❌ Step 1 (Finalize) Failed: Failed to save wallets to backend: $e'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] Step 1 (Finalize) FAILED: $e');
                await logErrorWithDeviceInfo(e, StackTrace.current, reason: 'Onboarding (Finalize): Save wallets failed');
                if (mounted) {
                  setState(() => _isConfirming = false);
                  final retry = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text('지갑 저장 실패'),
                      content: Text('지갑 정보를 서버에 저장하지 못했습니다.\n\n에러: $e\n\n다시 시도하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('재시도'),
                        ),
                      ],
                    ),
                  );
                  if (retry == true) {
                    return _createWepinWallet();
                  }
                }
                return;
              }

              // Wait for profile check to complete before moving to next page
              '📍 Step 2 (Finalize): Checking user profile...'.log();
              await FirebaseCrashlytics.instance.log('[Onboarding] Step 2 (Finalize): Checking user profile');
              try {
                await _checkUserProfile();
                '✅ Step 2 (Finalize) Complete: Profile check done (exists: $_hasExistingProfile)'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] Step 2 (Finalize) Complete: Profile exists=$_hasExistingProfile');
              } catch (e) {
                '❌ Step 2 (Finalize) Failed: Failed to check user profile: $e'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] Step 2 (Finalize) FAILED: $e');
                await logErrorWithDeviceInfo(e, StackTrace.current, reason: 'Onboarding (Finalize): Check profile failed');
                // 기본값으로 설정 (새 사용자로 간주)
                setState(() {
                  _hasExistingProfile = false;
                });
                '⚠️ Assuming new user due to profile check failure'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] Assuming new user (Finalize: profile check failed)');
              }

              setState(() {
                _isConfirming = false;
              });

              if (_hasExistingProfile) {
                '🆗 지갑 finalize 완료 + 프로필 존재 - 프로필 화면으로'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] SUCCESS (Finalize): Wallet created + Profile exists -> Profile page');
                await _moveToPage(2); // Show profile exists page
              } else {
                '🆕 지갑 finalize 완료 + 프로필 없음 - 캐릭터 선택으로'.log();
                await FirebaseCrashlytics.instance.log('[Onboarding] SUCCESS (Finalize): Wallet created + New user -> Character selection');
                await _moveToPage(2); // Move to character selection
              }
            } else {
              '❌ Still no wallets after finalize'.log();
              setState(() {
                _isConfirming = false;
              });
            }
          } catch (e) {
            '❌ Error during finalize: $e'.log();
            setState(() {
              _isConfirming = false;
            });
          }
        }
        
        // Check user status and save tokens
        await _checkAndSaveWepinUser();
        await _saveWepinTokensAfterOAuth();
        
      } else if (status == WepinLifeCycle.loginBeforeRegister) {
        '🚀 Starting Wepin registration for new user...'.log();
        
        // New user needs registration
        await wepinCubit.state.wepinWidgetSDK!.register(context);
        
        // After registration, check user status and save tokens
        await _checkAndSaveWepinUser();
        await _saveWepinTokensAfterOAuth();
        
        // Wait a moment for wallet creation
        await Future.delayed(const Duration(seconds: 1));
        
        // Check if wallet was created successfully
        final accounts = await wepinCubit.state.wepinWidgetSDK!.getAccounts();
        '📋 Accounts after registration: ${accounts.length}'.log();
        
        // Log all created accounts
        for (var account in accounts) {
          '💳 Created - Network: ${account.network}, Address: ${account.address}'.log();
        }
        
        final ethereumAccounts = accounts.where((account) => 
          account.network.toLowerCase() == 'ethereum'
        ).toList();
        
        if (ethereumAccounts.isNotEmpty) {
          '✅ Ethereum wallet created successfully!'.log();
          for (var eth in ethereumAccounts) {
            '🔷 New Ethereum Address: ${eth.address}'.log();
          }

          // Save wallets to backend
          try {
            await wepinCubit.saveWalletsToHMPBackend(accounts);
          } catch (e) {
            '⚠️ Failed to save wallets to backend after registration, but continuing: $e'.log();
          }

          // Wallet created successfully, check profile before moving
          setState(() {
            _isConfirming = false;
          });
          try {
            await _checkUserProfile();
          } catch (e) {
            '⚠️ Failed to check user profile after registration, but continuing: $e'.log();
          }
          if (_hasExistingProfile) {
            '🆗 새 지갑 생성 + 프로필 존재 - 프로필 화면으로'.log();
            await _moveToPage(2); // Show profile exists page
          } else {
            '🆕 새 지갑 생성 + 프로필 없음 - 캐릭터 선택으로'.log();
            await _moveToPage(2); // Move to character selection
          }
        } else {
          '❌ No Ethereum wallet created'.log();
          setState(() {
            _isConfirming = false;
          });
        }
      } else {
        setState(() {
          _isConfirming = false;
        });
        '❌ Wepin not in correct state for wallet creation: $status'.log();
      }
    } catch (e) {
      '❌ Error creating Wepin wallet: $e'.log();
      if (mounted) {
        _showWalletCreationErrorDialog('지갑 생성 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    } finally {
      // Cancel timeout timer
      _walletCreationTimeoutTimer?.cancel();
      _walletCreationTimeoutTimer = null;

      // CRITICAL: Always reset _isConfirming to prevent infinite loading
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
        '✅ _isConfirming reset in finally block'.log();
      }
    }
  }

  /// Shows error dialog for wallet creation failures
  void _showWalletCreationErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            '지갑 생성 오류',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                '확인',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Retry wallet creation
                _createWepinWallet();
              },
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkAndSaveWepinUser() async {
    try {
      '🔍 WePIN 사용자 상태 확인 중...'.log();
      
      final wepinCubit = getIt<WepinCubit>();
      if (wepinCubit.state.wepinWidgetSDK == null) {
        '❌ WePIN SDK not initialized'.log();
        return;
      }
      
      // 현재 WePIN 사용자 확인
      try {
        final currentUser = await wepinCubit.state.wepinWidgetSDK!.login.getCurrentWepinUser();
        
        if (currentUser != null && currentUser.userInfo != null) {
          '✅ WePIN 사용자 로그인 확인: ${currentUser.userInfo!.email}'.log();
          '📊 로그인 상태: ${currentUser.userStatus?.loginStatus}'.log();
          '📊 Provider: ${currentUser.userInfo!.provider}'.log();
          
          // 로그인 상태를 SharedPreferences에 저장
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('wepin_logged_in', true);
          await prefs.setString('wepin_user_email', currentUser.userInfo!.email);
          await prefs.setString('wepin_user_provider', currentUser.userInfo!.provider ?? '');
          
          '✅ WePIN 로그인 상태 저장 완료'.log();
        } else {
          '⚠️ WePIN 사용자 정보 없음'.log();
          await _clearWepinLoginState();
        }
      } catch (e) {
        '❌ getCurrentWepinUser 에러: $e'.log();
        
        // InvalidLoginSession 오류 처리
        if (e.toString().contains('InvalidLoginSession')) {
          '🔄 InvalidLoginSession 감지 - 세션 복구 시도'.log();
          await _handleInvalidLoginSession(wepinCubit);
        } else {
          // 다른 오류의 경우 로그인 상태 정리
          await _clearWepinLoginState();
        }
      }
    } catch (e) {
      '❌ _checkAndSaveWepinUser 에러: $e'.log();
      await _clearWepinLoginState();
    }
  }

  /// InvalidLoginSession 오류 처리 및 세션 복구
  Future<void> _handleInvalidLoginSession(WepinCubit wepinCubit) async {
    try {
      '🔄 세션 복구 프로세스 시작...'.log();
      
      // 1. 현재 Wepin 상태 확인
      final currentStatus = await wepinCubit.state.wepinWidgetSDK!.getStatus();
      '📊 현재 Wepin 상태: $currentStatus'.log();
      
      // 2. 세션 정리 - Wepin 로그아웃 시도
      try {
        '🧹 Wepin 세션 정리 시도...'.log();
        await wepinCubit.state.wepinWidgetSDK!.login.logoutWepin();
        '✅ Wepin 로그아웃 완료'.log();
      } catch (logoutError) {
        '⚠️ Wepin 로그아웃 실패 (무시 가능): $logoutError'.log();
      }
      
      // 3. 상태 업데이트
      final newStatus = await wepinCubit.state.wepinWidgetSDK!.getStatus();
      wepinCubit.updateWepinStatus(newStatus);
      '📊 정리 후 Wepin 상태: $newStatus'.log();
      
      // 4. 로컬 상태 정리
      await _clearWepinLoginState();
      
      // 5. 소셜 로그인 토큰 새로고침 시도
      '🔄 소셜 로그인 토큰 새로고침 시도...'.log();
      await wepinCubit.getSocialLoginValues();
      
      // 6. 토큰이 있으면 자동 재로그인 시도
      final hasValidToken = (wepinCubit.state.socialTokenIsAppleOrGoogle == 'GOOGLE' && 
                            wepinCubit.state.googleAccessToken?.isNotEmpty == true) ||
                           (wepinCubit.state.socialTokenIsAppleOrGoogle == 'APPLE' && 
                            wepinCubit.state.appleIdToken?.isNotEmpty == true);
                            
      if (hasValidToken) {
        '🔄 유효한 토큰 발견 - 자동 재로그인 시도...'.log();
        
        try {
          await wepinCubit.loginSocialAuthProvider();
          
          // 재로그인 후 상태 확인
          final recoveredStatus = await wepinCubit.state.wepinWidgetSDK!.getStatus();
          '📊 복구 후 Wepin 상태: $recoveredStatus'.log();
          
          if (recoveredStatus == WepinLifeCycle.login) {
            '✅ 세션 복구 성공'.log();
            
            // 복구된 사용자 정보 다시 확인
            try {
              final recoveredUser = await wepinCubit.state.wepinWidgetSDK!.login.getCurrentWepinUser();
              if (recoveredUser != null && recoveredUser.userInfo != null) {
                '✅ 복구된 사용자 정보 저장: ${recoveredUser.userInfo!.email}'.log();
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('wepin_logged_in', true);
                await prefs.setString('wepin_user_email', recoveredUser.userInfo!.email);
                await prefs.setString('wepin_user_provider', recoveredUser.userInfo!.provider ?? '');
              }
            } catch (userCheckError) {
              '⚠️ 복구 후 사용자 정보 확인 실패: $userCheckError'.log();
            }
          } else {
            '⚠️ 재로그인 후에도 상태가 login이 아님: $recoveredStatus'.log();
          }
        } catch (reloginError) {
          '❌ 자동 재로그인 실패: $reloginError'.log();
        }
      } else {
        '⚠️ 유효한 토큰이 없어 자동 재로그인 불가'.log();
      }
      
    } catch (e) {
      '❌ 세션 복구 실패: $e'.log();
      await _clearWepinLoginState();
    }
  }

  /// Wepin 로그인 상태 정리
  Future<void> _clearWepinLoginState() async {
    try {
      '🧹 Wepin 로그인 상태 정리 중...'.log();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wepin_logged_in');
      await prefs.remove('wepin_user_email');
      await prefs.remove('wepin_user_provider');
      '✅ Wepin 로그인 상태 정리 완료'.log();
    } catch (e) {
      '❌ Wepin 로그인 상태 정리 실패: $e'.log();
    }
  }

  Future<void> _saveWepinTokensAfterOAuth() async {
    try {
      '🔄 Attempting to save WePIN OAuth tokens to app storage...'.log();
      
      // Get current Firebase user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        '❌ No Firebase user found after WePIN OAuth'.log();
        return;
      }
      
      '✅ Firebase user found: ${firebaseUser.uid}'.log();
      
      // Get provider data to determine login type
      final providerData = firebaseUser.providerData;
      String? loginType;
      
      for (final provider in providerData) {
        if (provider.providerId == 'google.com') {
          loginType = 'GOOGLE';
          break;
        } else if (provider.providerId == 'apple.com') {
          loginType = 'APPLE';
          break;
        }
      }
      
      if (loginType == null) {
        '❌ Could not determine login type from Firebase user'.log();
        return;
      }
      
      '🔑 Login type detected: $loginType'.log();
      
      // Save login type
      final secureStorage = getIt<SecureStorage>();
      await secureStorage.write(StorageValues.socialTokenIsAppleOrGoogle, loginType);
      
      // Get and save tokens based on login type
      if (loginType == 'GOOGLE') {
        // WePIN handles OAuth internally, so we need to use Firebase ID token
        try {
          // First, always save Firebase ID token as it's most reliable
          final firebaseIdToken = await firebaseUser.getIdToken();
          if (firebaseIdToken != null) {
            await secureStorage.write(StorageValues.googleIdToken, firebaseIdToken);
            '✅ Firebase ID token saved for Google login'.log();
          }
          
          // Also try to get Google tokens if available
          try {
            final googleSignIn = GoogleSignIn();
            final googleUser = googleSignIn.currentUser ?? await googleSignIn.signInSilently();
            
            if (googleUser != null) {
              final googleAuth = await googleUser.authentication;
              
              // Save Google access token if available
              if (googleAuth.accessToken != null) {
                await secureStorage.write(StorageValues.googleAccessToken, googleAuth.accessToken!);
                '✅ Google access token also saved'.log();
              }
              
              // If we get a Google ID token, update it (prefer this over Firebase token)
              if (googleAuth.idToken != null) {
                await secureStorage.write(StorageValues.googleIdToken, googleAuth.idToken!);
                '✅ Google ID token updated with native token'.log();
              }
            } else {
              '⚠️ GoogleSignIn session not available (normal for WePIN OAuth)'.log();
            }
          } catch (googleError) {
            '⚠️ Could not get native Google tokens (expected with WePIN): $googleError'.log();
          }
        } catch (e) {
          '❌ Error saving tokens: $e'.log();
        }
      } else if (loginType == 'APPLE') {
        // For Apple, we mainly use Firebase ID token
        try {
          final firebaseIdToken = await firebaseUser.getIdToken();
          if (firebaseIdToken != null) {
            await secureStorage.write(StorageValues.appleIdToken, firebaseIdToken);
            '✅ Apple ID token (Firebase) saved'.log();
          }
        } catch (e) {
          '❌ Error saving Apple token: $e'.log();
        }
      }
      
      '✅ Token saving process completed'.log();
    } catch (e) {
      '❌ Error in _saveWepinTokensAfterOAuth: $e'.log();
    }
  }

  Future<void> _goToPreviousPage() async {
    // Prevent going back if confirming
    if (_isConfirming) {
      '⚠️ 처리 중 - 뒤로 가기 차단'.log();
      return;
    }

    if (currentSlideIndex > 0) {
      '⬅️ 이전 페이지로 이동: ${currentSlideIndex} -> ${currentSlideIndex - 1}'.log();
      await _moveToPage(currentSlideIndex - 1);
    }
  }

  String _getButtonText() {
    switch (currentSlideIndex) {
      case 0:
        return LocaleKeys.onboarding_understood.tr();  // 첫 번째 화면 (하미플 세계 소개)
      case 1:
        return _hasExistingWallet
            ? LocaleKeys.onboarding_confirmed.tr()  // 지갑 있음 화면
            : LocaleKeys.onboarding_create_wallet.tr();  // 지갑 소개
      case 2:
        return _hasExistingProfile
            ? LocaleKeys.onboarding_confirmed.tr()  // 프로필 이미 있음 화면
            : LocaleKeys.onboarding_lets_do_this.tr();  // 세 번째 화면 (캐릭터 선택)
      case 3:
        return LocaleKeys.onboarding_lets_do_this.tr();  // 네 번째 화면 (닉네임 입력)
      case 4:
        return LocaleKeys.onboarding_enter_world.tr();  // 다섯 번째 화면 (완료)
      default:
        return LocaleKeys.next.tr();
    }
  }

  bool _canProceed() {
    // Disable button on nickname screen if nickname is invalid
    if (currentSlideIndex == 3) {
      return nickname.isNotEmpty && nickname.length >= 2;
    }
    return true;
  }

  String _getLoadingMessage() {
    if (_isCheckingWallet || (currentSlideIndex == 1 && _isConfirming)) {
      return LocaleKeys.onboarding_creating_wallet.tr();
    } else if (currentSlideIndex == 4 && _isConfirming) {
      return LocaleKeys.onboarding_entering_world.tr();
    }
    return LocaleKeys.onboarding_please_wait.tr();
  }

  @override
  void dispose() {
    // Cancel wallet creation timeout timer
    _walletCreationTimeoutTimer?.cancel();
    _walletCreationTimeoutTimer = null;
    //sliderTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue background like social auth
      // convert BlocListener to BlocConsumer

      body: MultiBlocListener(
        listeners: [
          // Listen for wallet creation during polling
          BlocListener<WepinCubit, WepinState>(
            bloc: getIt<WepinCubit>(),
            listener: (context, wepinState) {
              // Update wallet checking state (keep for NFT redemption flow)
              if (wepinState.isCheckingWallet != _isCheckingWallet) {
                setState(() {
                  _isCheckingWallet = wepinState.isCheckingWallet;
                });
                if (wepinState.isCheckingWallet) {
                  '⏱️ Wallet check started - blocking UI'.log();
                } else {
                  '✅ Wallet check completed - unblocking UI'.log();
                }
              }

              // Note: walletCreatedFromOnboarding polling logic removed
              // Now using direct userStatus check and immediate getAccounts() call
            },
          ),
          BlocListener<EnableLocationCubit, EnableLocationState>(
            bloc: getIt<EnableLocationCubit>(),
            listener: (context, state) async {
          if (state.submitStatus == RequestStatus.success) {
            // 온보딩 완료 시 상태 업데이트
            await _updateOnboardingCompletedStatus();

            // Navigate directly to appScreen to avoid StartUpScreen re-checking and showing onboarding again
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.appScreen,
                (route) => false,
              );
            }
          }

          if ((state.submitStatus == RequestStatus.failure) &&
              state.isLocationDenied) {
            // 위치 권한이 거부되어도 온보딩 완료로 처리
            await _updateOnboardingCompletedStatus();

            // Navigate directly to appScreen to avoid StartUpScreen re-checking and showing onboarding again
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.appScreen,
                (route) => false,
              );
            }
          }
            },
          ),
        ],
        child: Stack(
          children: [
              Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  // Custom progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                            height: 8,
                            decoration: BoxDecoration(
                              color: index <= currentSlideIndex
                                  ? hmpBlue
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: IndexedStack(
                      index: currentSlideIndex,
                      children: <Widget>[
                        const OnboardingPageSecond(), // 1. 하미플 세계 소개
                        _hasExistingWallet 
                            ? const OnboardingPageWalletExists()  // 2. 지갑 있음 화면
                            : const OnboardingPageFirst(),        // 2. 지갑 소개
                        _hasExistingProfile
                            ? OnboardingPageProfileExists(  // 3. 프로필 이미지 있음 화면
                                userProfile: getIt<ProfileCubit>().state.userProfileEntity,
                              )
                            : OnboardingPageThird(                 // 3. 캐릭터 선택 (1/10 ~ 10/10 변경 가능)
                                onProfileSelected: (profile) {
                                  setState(() {
                                    selectedProfile = profile;
                                  });
                                },
                                onCharacterSelected: (character) {
                                  setState(() {
                                    selectedCharacter = character;
                                  });
                                },
                              ),
                        OnboardingPageFourth(          // 4. 닉네임 입력
                          selectedProfile: _hasExistingProfile
                              ? (getIt<ProfileCubit>().state.userProfileEntity?.profilePartsString ?? selectedProfile)
                              : selectedProfile,
                          selectedCharacter: _hasExistingProfile
                              ? null  // Use existing profile parts
                              : selectedCharacter,
                          userProfile: _hasExistingProfile
                              ? getIt<ProfileCubit>().state.userProfileEntity
                              : null,
                          onNicknameChanged: (name) {
                            setState(() {
                              nickname = name;
                            });
                          },
                        ),
                        OnboardingPageFifth(           // 5. 완료 축하
                          selectedProfile: _hasExistingProfile
                              ? (getIt<ProfileCubit>().state.userProfileEntity?.profilePartsString ?? selectedProfile)
                              : selectedProfile,
                          selectedCharacter: _hasExistingProfile
                              ? null  // Use existing profile parts
                              : selectedCharacter,
                          nickname: _hasExistingNickname
                              ? (getIt<ProfileCubit>().state.userProfileEntity?.nickName ?? nickname)
                              : nickname,
                          userProfile: _hasExistingProfile
                              ? getIt<ProfileCubit>().state.userProfileEntity
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  currentSlideIndex == 0 || currentSlideIndex == 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60.0),
                          child: GradientButton(
                                  text: _getButtonText(),
                                  onPressed: () {
                                    if (_isCheckingWallet || _isConfirming) {
                                      '⚠️ [Onboarding] Already processing, ignoring tap'.log();
                                      return;
                                    }
                                    if (currentSlideIndex == 1 && !_hasExistingWallet) {
                                      _createWepinWallet();
                                    } else {
                                      _goToNextPage();
                                    }
                                  },
                                ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60.0),
                          child: currentSlideIndex + 1 == 5
                              ? GradientButton(
                                  text: LocaleKeys.onboarding_enter_world.tr(),
                                  onPressed: () async {
                                                // Prevent multiple clicks
                                                if (_isConfirming) {
                                                  '⚠️ 이미 처리 중 - 중복 클릭 방지'.log();
                                                  return;
                                                }

                                                setState(
                                                    () => _isConfirming = true);

                                                try {
                                                  '🚀 온보딩 완료 버튼 클릭'.log();

                                                  // CRITICAL: Mark onboarding as completed FIRST to prevent restart loop
                                                  final prefs = await SharedPreferences.getInstance();
                                                  await prefs.setBool(StorageValues.onboardingCompleted, true);
                                                  await prefs.setInt(StorageValues.onboardingVersion, StorageValues.CURRENT_ONBOARDING_VERSION);
                                                  '✅ 온보딩 완료 플래그 먼저 설정 (재시작 방지)'.log();

                                                  // Clear saved step immediately to prevent navigation issues
                                                  try {
                                                    await prefs.remove(StorageValues.onboardingCurrentStep);
                                                    '🗑️ 저장된 온보딩 단계 즉시 삭제'.log();
                                                  } catch (e) {
                                                    '❌ Failed to clear saved step: $e'.log();
                                                    // Continue anyway since onboardingCompleted is already set
                                                  }

                                                // Check if user already has profile parts string (actual character data)
                                                final userProfile = getIt<ProfileCubit>().state.userProfileEntity;
                                                final hasExistingProfileParts =
                                                    userProfile?.profilePartsString?.isNotEmpty ?? false;

                                                // Determine what needs to be updated
                                                String? nicknameToUpdate = _hasExistingNickname ? null : nickname;
                                                // Only skip profileParts update if user already has profile parts data
                                                String? profilePartsToUpdate = hasExistingProfileParts ? null : selectedCharacter?.toJsonString();

                                                '📊 업데이트 필요 여부 확인'.log();
                                                '  - 기존 프로필 파츠: ${hasExistingProfileParts ? "있음" : "없음"}'.log();
                                                if (userProfile != null) {
                                                  '    - profilePartsString: ${userProfile.profilePartsString ?? "없음"}'.log();
                                                  '    - finalProfileImageUrl: ${userProfile.finalProfileImageUrl ?? "없음"}'.log();
                                                }
                                                '  - 닉네임 업데이트 필요: ${nicknameToUpdate != null} ${nicknameToUpdate != null ? "($nicknameToUpdate)" : "(기존 유지)"}'.log();
                                                '  - 프로필 파츠 업데이트 필요: ${profilePartsToUpdate != null} ${profilePartsToUpdate != null ? "(새 캐릭터)" : "(기존 프로필 유지)"}'.log();
                                                if (selectedCharacter != null) {
                                                  '  - 선택된 캐릭터 JSON: ${selectedCharacter!.toJsonString()}'.log();
                                                }

                                                // Process NFT minting FIRST, then save profile after success
                                                if (!hasExistingProfileParts && selectedCharacter != null) {
                                                  try {
                                                    '⏳ Waiting for image merge and NFT minting to complete...'.log();
                                                    // Pass nickname and profilePartsString to be saved AFTER minting succeeds
                                                    await _startImageUploadTask(selectedCharacter, nicknameToUpdate, profilePartsToUpdate);
                                                    '✅ Image processing and profile save completed'.log();
                                                  } catch (e) {
                                                    '❌ 민팅 및 프로필 저장 실패: $e'.log();
                                                    // Continue to navigation even if minting/profile update fails
                                                    // User can update profile later in app
                                                  }
                                                } else if (nicknameToUpdate != null || profilePartsToUpdate != null) {
                                                  // No minting needed, just update profile
                                                  try {
                                                    final profileCubit = getIt<ProfileCubit>();
                                                    final updateRequest = UpdateProfileRequestDto(
                                                      nickName: nicknameToUpdate,
                                                      profilePartsString: profilePartsToUpdate,
                                                      onboardingCompleted: true,
                                                    );
                                                    await profileCubit.onUpdateUserProfile(updateRequest);
                                                    '✅ 프로필 업데이트 성공'.log();
                                                  } catch (e) {
                                                    '❌ 프로필 업데이트 실패: $e'.log();
                                                  }
                                                } else {
                                                  '✅ 기존 프로필과 닉네임이 모두 있음 - 업데이트 건너뛰기'.log();
                                                  '📝 기존 닉네임: ${getIt<ProfileCubit>().state.userProfileEntity?.nickName}'.log();
                                                  '🎨 기존 프로필 이미지: ${getIt<ProfileCubit>().state.userProfileEntity?.finalProfileImageUrl}'.log();

                                                  // 프로필과 닉네임이 있어도 온보딩 완료 상태는 업데이트
                                                  try {
                                                    final profileCubit = getIt<ProfileCubit>();
                                                    final updateRequest = UpdateProfileRequestDto(
                                                      onboardingCompleted: true,
                                                    );
                                                    await profileCubit.onUpdateUserProfile(updateRequest);
                                                    '✅ 온보딩 완료 상태 업데이트 성공'.log();
                                                  } catch (e) {
                                                    '❌ 온보딩 완료 상태 업데이트 실패: $e'.log();
                                                  }
                                                }

                                                // All processing is complete, ready to navigate
                                                '✅ All onboarding tasks completed successfully'.log();

                                                // Navigate to app screen with safety checks
                                                if (!context.mounted) {
                                                  '❌ Context not mounted, cannot navigate'.log();
                                                  return;
                                                }

                                                '🚀 Navigating to app screen...'.log();
                                                await Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  Routes.appScreen,
                                                  (route) => false,
                                                );
                                                '✅ Successfully navigated to app screen'.log();

                                              } catch (e) {
                                                '❌ 온보딩 완료 처리 중 에러 발생: $e'.log();

                                                // Even on error, try to navigate to app since onboarding is marked complete
                                                if (context.mounted) {
                                                  '🔄 에러 발생했지만 앱 화면으로 이동 시도...'.log();
                                                  try {
                                                    await Navigator.pushNamedAndRemoveUntil(
                                                      context,
                                                      Routes.appScreen,
                                                      (route) => false,
                                                    );
                                                  } catch (navError) {
                                                    '❌ Navigation also failed: $navError'.log();
                                                  }
                                                }
                                              } finally {
                                                // CRITICAL: Always reset _isConfirming to prevent infinite loading
                                                if (mounted) {
                                                  setState(() {
                                                    _isConfirming = false;
                                                  });
                                                  '✅ _isConfirming 리셋 완료'.log();
                                                }
                                              }
                                            },
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                                  child: GradientButton(
                                    text: _getButtonText(),
                                    onPressed: _canProceed() ? _goToNextPage : () {},
                                  ),
                                ),
                        ),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 30,
                    ),
                  ),
                ],
              ),
              // Loading overlay when checking wallet or processing
              if (_isCheckingWallet || (_isConfirming && (currentSlideIndex == 1 || currentSlideIndex == 4)))
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _getLoadingMessage(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'LINESeedKR',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          LocaleKeys.onboarding_please_wait.tr(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'LINESeedKR',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ),
    );
  }

  setDontShowAgain(bool isDontShow) async {
    final prefs = await SharedPreferences.getInstance();
    if (isDontShow) {
      await prefs.setInt(isShowOnBoardingView, 1);
    } else {
      await prefs.setInt(isShowOnBoardingView, 0);
    }

    var isShowOnBoarding = prefs.getInt(isShowOnBoardingView);
    ("isShowOnBoarding: $isShowOnBoarding").log();
  }

  /// Process character image merge and NFT minting
  /// This should be awaited to ensure all processing completes before navigation
  /// nickname and profilePartsString will be saved to backend ONLY AFTER minting succeeds
  Future<void> _startImageUploadTask(CharacterProfile? character, String? nickname, String? profilePartsString) async {
    '🚀 _startImageUploadTask called with character: ${character != null}'.log();
    '📝 Nickname to save after minting: ${nickname != null}'.log();
    '📝 Profile parts to save after minting: ${profilePartsString != null}'.log();

    // Skip if user already has existing profile (no need to mint again)
    if (_hasExistingProfile) {
      '⚠️ User already has existing profile - skipping NFT minting'.log();
      return;
    }

    if (character == null) {
      '⚠️ No character selected for image upload'.log();
      return;
    }

    // Process image merge and NFT minting synchronously
    try {
      '🎨 Starting character image merge process'.log();
      '📝 Character ID: ${character.id}'.log();
      '🎨 Character layers:'.log();
      '  - Background: ${character.background}'.log();
      '  - Body: ${character.body}'.log();
      '  - Clothes: ${character.clothes}'.log();
      '  - Hair: ${character.hair}'.log();
      '  - Eyes: ${character.eyes}'.log();
      '  - Nose: ${character.nose}'.log();
      if (character.earAccessory != null) {
        '  - Ear Accessory: ${character.earAccessory}'.log();
      }

      // Step 1: Merge character layers
      final imageBytes = await CharacterImageService.mergeCharacterLayers(character);
      if (imageBytes == null) {
        '❌ Failed to merge character layers'.log();
        return;
      }
      '✅ Successfully merged character layers'.log();
      '📊 Image size: ${imageBytes.length} bytes (${(imageBytes.length / 1024).toStringAsFixed(2)} KB)'.log();

      // Step 2: Skip S3 upload (not needed as per user request)
      '⏭️ Skipping S3 upload (using server-side image generation)'.log();

      // Step 3: Save profile BEFORE minting (so user can retry if minting fails)
      final profileCubit = getIt<ProfileCubit>();
      if (nickname != null || profilePartsString != null) {
        '🚀 Saving profile before minting...'.log();
        final updateRequest = UpdateProfileRequestDto(
          nickName: nickname,
          profilePartsString: profilePartsString,
          onboardingCompleted: true,
        );
        await profileCubit.onUpdateUserProfile(updateRequest);
        '✅ Profile saved before minting'.log();

        // Save profile parts string locally if new character was created
        if (profilePartsString != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profilePartsString', profilePartsString);
          '💾 Profile parts saved to local storage'.log();
        }

        // Note: onUpdateUserProfile automatically calls onGetUserProfile (line 129 in profile_cubit.dart)
        // No need to call it again here
        '✅ Profile data refreshed via onUpdateUserProfile'.log();
      }

      // Step 4: Trigger NFT minting with API endpoint (fire and forget)
      '🚀 Calling _mintProfileNft() - Minting request sent (non-blocking)'.log();
      _mintProfileNft().then((_) {
        '✅ NFT minting completed in background'.log();
      }).catchError((e) {
        '❌ NFT minting failed in background: $e'.log();
      });
      '✅ Proceeding without waiting for minting'.log();

    } catch (e, stackTrace) {
      '❌ Error in image upload task: $e'.log();
      '📚 Stack trace: $stackTrace'.log();
    }
  }
  
  /// Mint profile NFT using server-generated image
  /// Profile is already saved before calling this function
  Future<void> _mintProfileNft() async {
    // Guard against duplicate minting
    if (_hasMintedNft) {
      '⚠️ NFT minting already in progress or completed, skipping duplicate call'.log();
      return;
    }

    // Set flag immediately to prevent concurrent calls
    _hasMintedNft = true;
    '🔒 Minting flag set to prevent duplicates'.log();

    try {
      '🎨 Starting profile NFT minting process'.log();

      // Get wallet address
      final walletsCubit = getIt<WalletsCubit>();
      await walletsCubit.onGetAllWallets();
      '💼 Connected wallets: ${walletsCubit.state.connectedWallets}'.log();

      if (walletsCubit.state.connectedWallets.isEmpty) {
        '❌ No wallet found for minting'.log();
        return;
      }

      // Get the first Ethereum wallet (provider field contains the network)
      final ethereumWallet = walletsCubit.state.connectedWallets.firstWhere(
        (wallet) => wallet.provider.toLowerCase() == 'ethereum',
        orElse: () => walletsCubit.state.connectedWallets.first,
      );

      final walletAddress = ethereumWallet.publicAddress;
      '💼 Using wallet ethereumWallet for minting: $ethereumWallet'.log();
      '💼 Using wallet address for minting: $walletAddress'.log();

      // Get user profile for metadata
      final profileCubit = getIt<ProfileCubit>();
      final userProfile = profileCubit.state.userProfileEntity;

      if (userProfile == null) {
        '❌ User profile not found'.log();
        return;
      }

      '✅ Profile found, proceeding with NFT minting'.log();

      // Construct URLs using server endpoints
      final imageUrl = '${appEnv.apiUrl}public/nft/user/${userProfile.id}/image';
      final metadataUrl = '${appEnv.apiUrl}public/nft/user/${userProfile.id}/metadata';
      '🖼️ Image URL: $imageUrl'.log();
      '📝 Metadata URL: $metadataUrl'.log();
      
      // Create mint request
      final mintRequest = MintNftRequestDto(
        walletAddress: walletAddress,
        imageUrl: imageUrl,
        metadataUrl: metadataUrl,
      );
      
      // Call minting API
      '📡 Calling NFT repository mintPfpNft()...'.log();
      final nftRepository = getIt<NftRepository>();
      final result = await nftRepository.mintPfpNft(request: mintRequest);
      '✅ NFT repository call completed, processing result...'.log();

      result.fold(
        (error) {
          '❌ NFT minting API call failed: ${error.message}'.log();
          '⚠️ Profile is already saved, user can retry minting later'.log();
          // Profile is already saved, user can retry minting later
        },
        (response) async {
          '✅ NFT minting API call successful!'.log();
          '🔗 Transaction Hash: ${response.transactionHash}'.log();
          '🎨 NFT Address: ${response.tokenAddress}'.log();
          '🎨 Token ID: ${response.tokenId}'.log();
          '⛓️ Chain: ${response.chain}'.log();
          '📝 Message: ${response.message}'.log();

          // Save minting status to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(StorageValues.hasMintedNft, true);
          await prefs.setString(StorageValues.mintingTransactionId, response.transactionHash);
          '💾 Minting status saved to storage'.log();
        },
      );
    } catch (e) {
      '❌ Error in NFT minting: $e'.log();
      // Reset flag on error to allow retry
      _hasMintedNft = false;
      '🔓 Minting flag reset due to error - retry possible'.log();
      // Non-blocking - user can continue even if minting fails
    }
  }
  
  // 온보딩 완료 시 지갑과 프로필 파츠 상태 업데이트
  Future<void> _updateOnboardingCompletedStatus() async {
    try {
      '📝 Updating onboarding completion status...'.log();
      
      // 지갑 상태 확인 및 저장
      await getIt<WalletsCubit>().onGetAllWallets();
      final hasWallet = getIt<WalletsCubit>().state.connectedWallets.isNotEmpty;
      
      // 프로필 상태 확인 및 저장
      await getIt<ProfileCubit>().onGetUserProfile();
      final userProfile = getIt<ProfileCubit>().state.userProfileEntity;
      final hasProfileParts = userProfile?.profilePartsString != null && 
                             userProfile!.profilePartsString!.isNotEmpty;
      
      // SharedPreferences에 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageValues.hasWallet, hasWallet);
      await prefs.setBool(StorageValues.hasProfileParts, hasProfileParts);
      await prefs.setBool(StorageValues.onboardingCompleted, true);
      // Save current onboarding version when updating status
      await prefs.setInt(StorageValues.onboardingVersion, StorageValues.CURRENT_ONBOARDING_VERSION);

      '✅ Onboarding status updated - Wallet: $hasWallet, ProfileParts: $hasProfileParts, Version: ${StorageValues.CURRENT_ONBOARDING_VERSION}'.log();
    } catch (e) {
      '❌ Error updating onboarding status: $e'.log();
    }
  }
}
