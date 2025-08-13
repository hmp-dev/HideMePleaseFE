import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/pref_keys.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';

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
  String selectedProfile = '';
  CharacterProfile? selectedCharacter;
  String nickname = '';
  bool _debugMode = false; // Debug mode flag
  // to prevent double tap while in process to check location and navigate

  @override
  void initState() {
    // New onboarding screens (2 new + 2 existing)
    // Total 4 screens now

    // Initialize Wepin SDK for wallet creation
    _initializeWepin();

    // call function to check if location is enabled with error handling
    try {
      getIt<EnableLocationCubit>().checkLocationEnabled();
    } catch (e) {
      '❌ Error checking location: $e'.log();
    }
    
    // Load saved onboarding state
    _loadOnboardingState();

    super.initState();
  }

  Future<void> _initializeWepin() async {
    try {
      '🔧 Initializing Wepin SDK for onboarding...'.log();
      final wepinCubit = getIt<WepinCubit>();
      
      // Initialize Wepin SDK with current language
      await wepinCubit.initializeWepinSDK(
        selectedLanguageCode: context.locale.languageCode,
      );
      
      '✅ Wepin SDK initialized successfully'.log();
    } catch (e) {
      '❌ Failed to initialize Wepin SDK: $e'.log();
    }
  }
  
  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check debug mode
    _debugMode = prefs.getBool(StorageValues.onboardingDebugMode) ?? false;
    
    // Always load saved step regardless of debug mode
    final savedStep = prefs.getInt(StorageValues.onboardingCurrentStep) ?? 0;
    setState(() {
      currentSlideIndex = savedStep;
    });
    
    if (_debugMode) {
      '🐛 디버그 모드 활성화 - 온보딩 표시 (저장된 단계: $savedStep)'.log();
    } else {
      '📱 온보딩 상태 복원: 스텝 $savedStep'.log();
    }
  }
  
  Future<void> _saveCurrentStep() async {
    // Always save current step regardless of debug mode
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageValues.onboardingCurrentStep, currentSlideIndex);
    '💾 온보딩 진행 상태 저장: 스텝 $currentSlideIndex'.log();
  }

  void _goToNextPage() async {
    if (currentSlideIndex == 0) {
      '🚀 첫 번째 온보딩 화면에서 다음 버튼 클릭'.log();
      
      // First page - check for Ethereum wallet
      bool hasWallet = await _checkEthereumWallet();
      
      if (hasWallet) {
        '✅ 지갑이 있음 - 두 번째 화면 스킵'.log();
        // Skip wallet creation page, go directly to character selection
        _moveToPage(2);
      } else {
        '❌ 지갑이 없음 - 지갑 생성 화면으로 이동'.log();
        // No wallet, go to wallet creation page
        _moveToPage(1);
      }
    } else if (currentSlideIndex < 4) {
      _moveToPage(currentSlideIndex + 1);
    }
  }
  
  void _moveToPage(int pageIndex) {
    setState(() {
      currentSlideIndex = pageIndex;
    });
    // Save state immediately when entering new page
    _saveCurrentStep();
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
    
    try {
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
      
      // If only initialized, need to login first
      if (status == WepinLifeCycle.initialized) {
        '🔄 Wepin needs login - opening Wepin widget for OAuth login...'.log();
        
        try {
          setState(() {
            _isConfirming = false;
          });
          
          // Start polling for wallet creation with onboarding flag
          '🔄 Starting wallet check timer for onboarding before opening widget'.log();
          wepinCubit.startWalletCheckTimer(isFromOnboarding: true);
          
          // Open Wepin widget which will handle OAuth login and wallet creation
          await wepinCubit.state.wepinWidgetSDK!.openWidget(context);
          
          // Widget closed, but polling will continue to check for wallet
          '📱 Wepin widget closed - polling continues in background'.log();
          
          return; // Exit here as polling will handle wallet detection
        } catch (e) {
          '❌ Error opening Wepin widget: $e'.log();
          wepinCubit.stopWalletCheckTimer(); // Stop polling on error
          setState(() {
            _isConfirming = false;
          });
          return;
        }
      }
      
      // Register to create wallet
      if (status == WepinLifeCycle.login || status == WepinLifeCycle.loginBeforeRegister) {
        '🚀 Starting Wepin registration...'.log();
        await wepinCubit.state.wepinWidgetSDK!.register(context);
        
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
          await wepinCubit.saveWalletsToHMPBackend(accounts);
          
          // Wallet created successfully, move to next page
          setState(() {
            _isConfirming = false;
          });
          _moveToPage(2); // Move to character selection
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
        '❌ Wepin not in correct state for registration: $status'.log();
      }
    } catch (e) {
      setState(() {
        _isConfirming = false;
      });
      '❌ Error creating Wepin wallet: $e'.log();
    }
  }

  void _goToPreviousPage() {
    if (currentSlideIndex > 0) {
      _moveToPage(currentSlideIndex - 1);
    }
  }

  String _getButtonText() {
    switch (currentSlideIndex) {
      case 0:
        return '이해했어!';  // 첫 번째 화면 (하미플 세계 소개)
      case 1:
        return '지갑을 만들게!';  // 두 번째 화면 (지갑 소개)
      case 2:
        return '이렇게 할게!';  // 세 번째 화면 (캐릭터 선택)
      case 3:
        return '이렇게 할게!';  // 네 번째 화면 (닉네임 입력)
      case 4:
        return '하미플 세계로 입장!';  // 다섯 번째 화면 (완료)
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

  @override
  void dispose() {
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
              // Check if wallet checking is active
              if (wepinState.isCheckingWallet) {
                '⏱️ Wallet check in progress: ${wepinState.walletCheckCounter}s'.log();
              }
              
              // Check if wallet was created from onboarding
              if (wepinState.walletCreatedFromOnboarding && currentSlideIndex == 1) {
                '✅ Wallet creation from onboarding detected!'.log();
                
                // Reset the flag to prevent duplicate navigation
                getIt<WepinCubit>().resetOnboardingWalletFlag();
                
                // Move to next page when wallet is created
                Future.delayed(const Duration(milliseconds: 500), () {
                  _moveToPage(2); // Move to character selection
                });
              }
            },
          ),
          BlocListener<EnableLocationCubit, EnableLocationState>(
            bloc: getIt<EnableLocationCubit>(),
            listener: (context, state) {
          if (state.submitStatus == RequestStatus.success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.startUpScreen,
              (route) => false,
            );
          }

          if ((state.submitStatus == RequestStatus.failure) &&
              state.isLocationDenied) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.startUpScreen,
              (route) => false,
            );
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
                        const OnboardingPageFirst(),  // 2. 지갑 소개
                        OnboardingPageThird(           // 3. 캐릭터 선택 (1/10 ~ 10/10 변경 가능)
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
                          selectedProfile: selectedProfile,
                          selectedCharacter: selectedCharacter,
                          onNicknameChanged: (name) {
                            setState(() {
                              nickname = name;
                            });
                          },
                        ),
                        OnboardingPageFifth(           // 5. 완료 축하
                          selectedProfile: selectedProfile,
                          selectedCharacter: selectedCharacter,
                          nickname: nickname,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  currentSlideIndex == 0 || currentSlideIndex == 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60.0),
                          child: _isConfirming && currentSlideIndex == 1
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : GradientButton(
                                  text: _getButtonText(),
                                  onPressed: currentSlideIndex == 1 
                                      ? _createWepinWallet 
                                      : _goToNextPage,
                                ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60.0),
                          child: currentSlideIndex + 1 == 5
                              ? GradientButton(
                                  text: '하미플 세계로 입장!',
                                  onPressed: _isConfirming
                                            ? () {}
                                            : () async {
                                                setState(
                                                    () => _isConfirming = true);
                                                
                                                '🚀 온보딩 완료 - 프로필 업데이트 시작'.log();
                                                '📝 닉네임: $nickname'.log();
                                                '🎨 캐릭터: $selectedProfile'.log();
                                                if (selectedCharacter != null) {
                                                  '🎭 캐릭터 상세 정보: ${selectedCharacter!.toJsonString()}'.log();
                                                }
                                                
                                                // Update user profile with nickname and character
                                                try {
                                                  final profileCubit = getIt<ProfileCubit>();
                                                  
                                                  // Create update profile request
                                                  final updateRequest = UpdateProfileRequestDto(
                                                    nickName: nickname,
                                                    profilePartsString: selectedCharacter?.toJsonString(),
                                                  );
                                                  
                                                  // Update profile
                                                  await profileCubit.onUpdateUserProfile(updateRequest);
                                                  '✅ 프로필 업데이트 성공'.log();
                                                } catch (e) {
                                                  '❌ 프로필 업데이트 실패: $e'.log();
                                                }
                                                
                                                // Save onboarding completion and clear saved step
                                                final prefs = await SharedPreferences.getInstance();
                                                await prefs.setBool(StorageValues.onboardingCompleted, true);
                                                await prefs.remove(StorageValues.onboardingCurrentStep);
                                                '✅ 온보딩 완료 - 저장된 단계 초기화'.log();
                                                
                                                // Start background task for image merging and S3 upload
                                                _startImageUploadTask(selectedCharacter);
                                                
                                                // Navigate directly to app screen
                                                Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  Routes.appScreen,
                                                  (route) => false,
                                                );
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

  /// Start background task to merge character layers and upload to S3
  Future<void> _startImageUploadTask(CharacterProfile? character) async {
    if (character == null) {
      '⚠️ No character selected for image upload'.log();
      return;
    }

    // Run in background using Future.microtask
    Future.microtask(() async {
      try {
        '🎨 Starting character image merge and upload process'.log();
        
        // Step 1: Merge character layers
        final imageBytes = await CharacterImageService.mergeCharacterLayers(character);
        if (imageBytes == null) {
          '❌ Failed to merge character layers'.log();
          return;
        }
        '✅ Successfully merged character layers (${imageBytes.length} bytes)'.log();

        // Step 2: Upload to S3
        final uploadService = getIt<ImageUploadService>();
        final fileName = CharacterImageService.generateFileName(character.id);
        
        final s3Url = await uploadService.uploadCharacterImageToS3(
          imageBytes: imageBytes,
          fileName: fileName,
        );

        if (s3Url == null) {
          '❌ Failed to upload image to S3'.log();
          return;
        }
        '✅ Successfully uploaded to S3: $s3Url'.log();

        // Step 3: Update profile with final image URL
        final profileCubit = getIt<ProfileCubit>();
        final updateRequest = UpdateProfileRequestDto(
          finalProfileImageUrl: s3Url,
        );
        
        await profileCubit.onUpdateUserProfile(updateRequest);
        '✅ Profile updated with final image URL'.log();

        // Step 4: Refresh profile to get updated data
        await profileCubit.onGetUserProfile();
        '✅ Profile refreshed with new image URL'.log();

      } catch (e) {
        '❌ Error in background image upload task: $e'.log();
      }
    });
  }
}
