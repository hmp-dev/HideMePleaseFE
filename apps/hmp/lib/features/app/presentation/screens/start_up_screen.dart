import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/model_banner_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mobile/features/common/presentation/services/background_location_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/core/storage/secure_storage.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen>
    with TickerProviderStateMixin {
  bool _isNavigating = false;
  bool _hasProcessedInitialState = false;

  @override
  void initState() {
    super.initState();
    // Post-frame callback to ensure widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Call onStart to update auth status
      await getIt<AppCubit>().onStart();

      // Directly call initialization logic instead of relying on BlocListener
      // This prevents issues with state already being initialized
      final appState = getIt<AppCubit>().state;

      print('🎯 [StartUpScreen] Post-frame init - isLoggedIn: ${appState.isLoggedIn}, initialized: ${appState.initialized}');

      if (!appState.isLoggedIn) {
        // Not logged in - navigate to login
        if (mounted) {
          _isNavigating = true;
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.socialLogin, (Route<dynamic> route) => false);
        }
      } else {
        // User is logged in - proceed with initialization
        _initializeLoggedInUser();
      }
    });
  }

  /// Initialize app for logged-in users
  Future<void> _initializeLoggedInUser() async {
    if (_isNavigating || !mounted) return;

    print('🎯 [StartUpScreen] Initializing for logged-in user...');

    // Location permission will be requested after navigation to AppView
    // This prevents context loss during system permission popups

    await getIt<ModelBannerCubit>().onGetModelBannerInfo();
    await getIt<ProfileCubit>().init();
    await _updateAppInfo();

    print('🔄 Checking for active check-in...');
    await getIt<SpaceCubit>().restoreCheckInState();

    // Fetch wallets - this will trigger the WalletsCubit listener for routing
    await getIt<WalletsCubit>().onGetAllWallets();

    print('✅ [StartUpScreen] Initialization completed');
  }

  /// Update app version and OS info silently in the background
  Future<void> _updateAppInfo() async {
    try {
      '🔄 [StartUpScreen] Updating app version and OS info...'.log();

      // Get app info
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // Get OS info
      String appOS = '';
      if (Platform.isIOS) {
        appOS = 'ios';
      } else if (Platform.isAndroid) {
        appOS = 'android';
      }

      '📱 [StartUpScreen] App version: $appVersion, OS: $appOS'.log();

      // Update profile silently (without EasyLoading)
      final profileCubit = getIt<ProfileCubit>();
      final updateRequest = UpdateProfileRequestDto(
        appOS: appOS,
        appVersion: appVersion,
      );

      await profileCubit.updateProfileSilently(updateRequest);
      '✅ [StartUpScreen] App info updated successfully'.log();
    } catch (e) {
      '❌ [StartUpScreen] Failed to update app info: $e'.log();
      // Error should not affect the startup process
    }
  }

  // start UP Logic
  //==> Check if User is LoggedIn --> in not loggedIn navigate to Social Login View
  //---->  If logged in get UserProfile date
  //---->  If logged in get userConnected Wallets
  //----> If no wallet Connected -> goto Home with showing Connect a Wallet View
  //----> If Wallet Connected -> fetch list for selected Tokens and  go to home view with  showing view connected wallets and Tokens as slider

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppCubit, AppState>(
          bloc: getIt<AppCubit>(),
          listenWhen: (previous, current) {
            // IMPORTANT: Only process when initialized is true
            // This ensures onStart() has completed and auth status is determined
            if (!current.initialized) {
              print('🎯 StartUpScreen: State not initialized yet, waiting...');
              return false;
            }

            // Process first time OR when isLoggedIn changes
            if (!_hasProcessedInitialState) {
              print('🎯 StartUpScreen: First state (after init) - isLoggedIn: ${current.isLoggedIn}, initialized: ${current.initialized}');
              return true;
            }

            final isLoggedInChanged = previous.isLoggedIn != current.isLoggedIn;
            if (isLoggedInChanged) {
              print('🎯 StartUpScreen: State changed - isLoggedIn: ${previous.isLoggedIn} → ${current.isLoggedIn}');
            }
            return isLoggedInChanged;
          },
          listener: (context, state) async {
            // Mark as processed
            _hasProcessedInitialState = true;

            // Prevent duplicate navigation
            if (_isNavigating) {
              print('⚠️ StartUpScreen: Already navigating, skipping');
              return;
            }

            print('🎯 StartUpScreen: AppCubit state received');
            print('🎯 Is logged in: ${state.isLoggedIn}');

            if (!state.isLoggedIn) {
              // Not logged in - navigate to login immediately
              _isNavigating = true;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.socialLogin, (Route<dynamic> route) => false);
            } else {
              // User is logged in - proceed with initialization
              ("-------inside state.isLoggedIn: ${state.isLoggedIn}").log();

              // Location permission will be requested after navigation to AppView
              // This prevents context loss during system permission popups

              await getIt<ModelBannerCubit>().onGetModelBannerInfo();

              // WelcomeNft is no longer used - commented out to prevent requests
              // await getIt<NftCubit>().onGetWelcomeNft();
              // User is logged in
              // a - init
              await getIt<ProfileCubit>().init();

              // Update app version and OS info after profile is loaded
              await _updateAppInfo();

              // Restore check-in state from local storage
              print('🔄 Checking for active check-in...');
              await getIt<SpaceCubit>().restoreCheckInState();

              // Now fetch wallets - this will trigger routing to AppView
              await getIt<WalletsCubit>().onGetAllWallets();
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          bloc: getIt<ProfileCubit>(),
          listener: (context, profileState) {
            if (profileState.isSubmitSuccess) {}
          },
        ),
        BlocListener<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          listenWhen: (previous, current) =>
              previous.submitStatus != current.submitStatus ||
              previous.connectedWallets != current.connectedWallets,
          listener: (context, walletsState) async {
            // Prevent duplicate navigation
            if (_isNavigating) {
              print('⚠️ StartUpScreen: Already navigating (WalletsCubit), skipping');
              return;
            }

            if (walletsState.submitStatus == RequestStatus.success) {
              // e- fetch Free Welcome NFT which also calls to fetch Selected NFTs

              if (walletsState.connectedWallets.isEmpty) {
                // If a wallet is NOT Connected
                // Update Home View to Show with Before Wallet Connected
                // and then Navigate to Home View

                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.beforeWalletConnected);

                // Check if onboarding has been completed
                final prefs = await SharedPreferences.getInstance();

                // Check onboarding version
                final savedVersion = prefs.getInt(StorageValues.onboardingVersion) ?? 0;
                final isNewVersion = savedVersion < StorageValues.CURRENT_ONBOARDING_VERSION;

                '🔄 Onboarding version check - Saved: $savedVersion, Current: ${StorageValues.CURRENT_ONBOARDING_VERSION}'.log();

                // Check for NFT minting and profile image BEFORE resetting flags
                final hasMintedNft = prefs.getBool(StorageValues.hasMintedNft) ?? false;
                final hasWallet = prefs.getBool(StorageValues.hasWallet) ?? false;
                final hasProfileParts = prefs.getBool(StorageValues.hasProfileParts) ?? false;

                // 기존 사용자 식별: 지갑이 있거나 프로필 파츠가 있는 경우
                final isExistingUser = hasWallet || hasProfileParts || hasMintedNft;

                // If new version, reset onboarding flags ONLY for new users
                if (isNewVersion) {
                  if (isExistingUser) {
                    '🆕 New onboarding version detected, but user is existing - keeping flags...'.log();
                    '✅ Existing user identified - Wallet: $hasWallet, ProfileParts: $hasProfileParts, Minted: $hasMintedNft'.log();
                    // 기존 사용자는 버전만 업데이트하고 플래그는 유지
                    await prefs.setInt(StorageValues.onboardingVersion, StorageValues.CURRENT_ONBOARDING_VERSION);
                  } else {
                    '🆕 New onboarding version detected, resetting flags for new user...'.log();
                    await prefs.remove(StorageValues.onboardingCompleted);
                    await prefs.remove(StorageValues.onboardingCurrentStep);
                    await prefs.remove(StorageValues.hasMintedNft);
                    await prefs.remove(StorageValues.hasProfileParts);
                  }
                }

                final onboardingCompleted = prefs.getBool(StorageValues.onboardingCompleted) ?? false;
                final showOnboardingAfterLogout = prefs.getBool(StorageValues.showOnboardingAfterLogout) ?? false;
                final savedStep = prefs.getInt(StorageValues.onboardingCurrentStep);

                // Check current profile status
                final profileCubit = getIt<ProfileCubit>();
                final userProfile = profileCubit.state.userProfileEntity;
                final hasProfileImage = userProfile?.finalProfileImageUrl?.isNotEmpty == true;

                // 🚨 실제 프로필 파츠 확인
                final hasActualProfileParts = userProfile?.profilePartsString?.isNotEmpty == true;

                // 백엔드 API의 onboardingCompleted 체크
                final backendOnboardingCompleted = userProfile?.onboardingCompleted ?? false;
                '🔍 백엔드 API onboardingCompleted: $backendOnboardingCompleted'.log();

                // Check nickname validity
                final isValidNickname = userProfile?.nickName != null &&
                                        userProfile!.nickName.isNotEmpty &&
                                        !userProfile.nickName.startsWith('HMP');

                // Enhanced skip logic: 실제 데이터가 있는지 확인
                final hasActualData = hasActualProfileParts && hasWallet && hasMintedNft && hasProfileImage && isValidNickname;

                '📊 Onboarding check - ProfileParts: $hasActualProfileParts, Wallet: $hasWallet, Minted: $hasMintedNft, ProfileImage: $hasProfileImage, ValidNickname: $isValidNickname'.log();
                '📊 Local onboardingCompleted: $onboardingCompleted, Backend onboardingCompleted: $backendOnboardingCompleted, Has actual data: $hasActualData'.log();

                if (context.mounted) {
                  // 🔄 우선순위: 백엔드 API > 로컬 플래그 > 실제 데이터

                  // 1️⃣ 최우선: 백엔드 API onboardingCompleted가 true면 → 홈으로 (로컬 동기화)
                  if (backendOnboardingCompleted) {
                    '✅ 백엔드 API 온보딩 완료 확인 - 홈 화면으로 이동 (로컬 동기화)'.log();
                    if (!onboardingCompleted) {
                      await prefs.setBool(StorageValues.onboardingCompleted, true);
                      '💾 로컬 플래그를 백엔드 API와 동기화'.log();
                    }
                    const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "true");
                    _isNavigating = true;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.appScreen, (Route<dynamic> route) => false);
                    return;
                  }

                  // 2️⃣ 로컬 onboardingCompleted가 true이고 특수 조건이 없으면 → 홈으로
                  // 기존 사용자는 버전 업데이트 시에도 홈으로 진입
                  if (onboardingCompleted && (!isNewVersion || isExistingUser) && !showOnboardingAfterLogout && savedStep == null) {
                    '✅ 로컬 플래그 완료됨 - 홈 화면으로 이동 (백엔드 false여도 무시)'.log();
                    const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "true");
                    _isNavigating = true;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.appScreen, (Route<dynamic> route) => false);
                    return;
                  }

                  // 3️⃣ onboardingCompleted는 false지만 실제 데이터가 모두 있으면 → 홈으로 (플래그 업데이트)
                  // 기존 사용자는 버전 업데이트 시에도 홈으로 진입
                  if (!onboardingCompleted && hasActualData && (!isNewVersion || isExistingUser) && !showOnboardingAfterLogout) {
                    '✅ 실제 데이터 완료 확인 - 로컬 플래그 업데이트 후 홈으로'.log();
                    await prefs.setBool(StorageValues.onboardingCompleted, true);
                    const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "true");
                    _isNavigating = true;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.appScreen, (Route<dynamic> route) => false);
                    return;
                  }

                  // 4️⃣ 그 외의 경우 → 온보딩으로
                  '🚀 온보딩 화면으로 이동 - 새 버전: $isNewVersion, 로그아웃 후: $showOnboardingAfterLogout, 완료: $onboardingCompleted, 저장된 단계: $savedStep'.log();

                  // Clear the flag if it was set
                  if (showOnboardingAfterLogout) {
                    await prefs.setBool(StorageValues.showOnboardingAfterLogout, false);
                  }

                  // Show onboarding screen
                  _isNavigating = true;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.onboardingScreen, (Route<dynamic> route) => false);
                }
              } else {
                // If a wallet is Connected
                // Update Home View to Show with Wallet Connected
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.afterWalletConnected);

                // === 온보딩 검증 추가 ===
                final prefs = await SharedPreferences.getInstance();

                // Check onboarding version
                final savedVersion = prefs.getInt(StorageValues.onboardingVersion) ?? 0;
                final isNewVersion = savedVersion < StorageValues.CURRENT_ONBOARDING_VERSION;

                '🔄 Onboarding version check (With Wallet) - Saved: $savedVersion, Current: ${StorageValues.CURRENT_ONBOARDING_VERSION}'.log();

                // Check for NFT minting and profile image BEFORE resetting flags
                final hasMintedNft = prefs.getBool(StorageValues.hasMintedNft) ?? false;
                final hasProfileParts = prefs.getBool(StorageValues.hasProfileParts) ?? false;

                // 기존 사용자 식별: 지갑은 이미 있으므로 프로필 파츠나 민팅 확인
                final isExistingUser = true; // 지갑이 있다면 기존 사용자

                // If new version, reset onboarding flags ONLY for new users
                if (isNewVersion) {
                  if (isExistingUser) {
                    '🆕 New onboarding version detected (With Wallet), but user is existing - keeping flags...'.log();
                    '✅ Existing user identified - Wallet: true, ProfileParts: $hasProfileParts, Minted: $hasMintedNft'.log();
                    // 기존 사용자는 버전만 업데이트하고 플래그는 유지
                    await prefs.setInt(StorageValues.onboardingVersion, StorageValues.CURRENT_ONBOARDING_VERSION);
                  } else {
                    '🆕 New onboarding version detected (With Wallet), resetting flags for new user...'.log();
                    await prefs.remove(StorageValues.onboardingCompleted);
                    await prefs.remove(StorageValues.onboardingCurrentStep);
                    await prefs.remove(StorageValues.hasMintedNft);
                    await prefs.remove(StorageValues.hasProfileParts);
                  }
                }

                final onboardingCompleted = prefs.getBool(StorageValues.onboardingCompleted) ?? false;
                final showOnboardingAfterLogout = prefs.getBool(StorageValues.showOnboardingAfterLogout) ?? false;
                final savedStep = prefs.getInt(StorageValues.onboardingCurrentStep);

                // Check current profile status
                final profileCubit = getIt<ProfileCubit>();
                final userProfile = profileCubit.state.userProfileEntity;
                final hasProfileImage = userProfile?.finalProfileImageUrl?.isNotEmpty == true;

                // 🚨 실제 프로필 파츠 확인
                final hasActualProfileParts = userProfile?.profilePartsString?.isNotEmpty == true;

                // 백엔드 API의 onboardingCompleted 체크
                final backendOnboardingCompleted = userProfile?.onboardingCompleted ?? false;
                '🔍 백엔드 API onboardingCompleted (With Wallet): $backendOnboardingCompleted'.log();

                // Check nickname validity
                final isValidNickname = userProfile?.nickName != null &&
                                        userProfile!.nickName.isNotEmpty &&
                                        !userProfile.nickName.startsWith('HMP');

                // Enhanced skip logic: 실제 데이터가 있는지 확인 (지갑은 이미 있음)
                final hasActualData = hasActualProfileParts && hasMintedNft && hasProfileImage && isValidNickname;

                '📊 Onboarding check (With Wallet) - ProfileParts: $hasActualProfileParts, Minted: $hasMintedNft, ProfileImage: $hasProfileImage, ValidNickname: $isValidNickname'.log();
                '📊 Local onboardingCompleted: $onboardingCompleted, Backend onboardingCompleted: $backendOnboardingCompleted, Has actual data: $hasActualData'.log();

                if (context.mounted) {
                  // 🔄 우선순위: 백엔드 API > 로컬 플래그 > 실제 데이터

                  // 1️⃣ 최우선: 백엔드 API onboardingCompleted가 true면 → 홈으로 (로컬 동기화)
                  if (backendOnboardingCompleted) {
                    '✅ 백엔드 API 온보딩 완료 확인 (With Wallet) - 홈 화면으로 이동 (로컬 동기화)'.log();
                    if (!onboardingCompleted) {
                      await prefs.setBool(StorageValues.onboardingCompleted, true);
                      '💾 로컬 플래그를 백엔드 API와 동기화'.log();
                    }

                    bool wasNoWallet = (await const SecureStorage().read(StorageValues.wasOnWelcomeWalletConnectScreen)) == "true";

                    _isNavigating = true;
                    if(wasNoWallet && StackedService.navigatorKey?.currentContext!=null){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyMembershipSettingsScreen(),
                        ),
                              (Route<dynamic> route) => false
                      );
                      Future.delayed(const Duration(seconds: 1), () => const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "false"));
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.appScreen, (Route<dynamic> route) => false);
                    }
                    return;
                  }

                  // 2️⃣ 로컬 onboardingCompleted가 true이고 특수 조건이 없으면 → 홈으로
                  if (onboardingCompleted && (!isNewVersion || isExistingUser) && !showOnboardingAfterLogout && savedStep == null) {
                    '✅ 로컬 플래그 완료됨 (With Wallet) - 홈 화면으로 이동 (백엔드 false여도 무시)'.log();

                    bool wasNoWallet = (await const SecureStorage().read(StorageValues.wasOnWelcomeWalletConnectScreen)) == "true";

                    _isNavigating = true;
                    if(wasNoWallet && StackedService.navigatorKey?.currentContext!=null){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyMembershipSettingsScreen(),
                        ),
                              (Route<dynamic> route) => false
                      );
                      Future.delayed(const Duration(seconds: 1), () => const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "false"));
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.appScreen, (Route<dynamic> route) => false);
                    }
                    return;
                  }

                  // 3️⃣ onboardingCompleted는 false지만 실제 데이터가 모두 있으면 → 홈으로 (플래그 업데이트)
                  if (!onboardingCompleted && hasActualData && (!isNewVersion || isExistingUser) && !showOnboardingAfterLogout) {
                    '✅ 실제 데이터 완료 확인 (With Wallet) - 로컬 플래그 업데이트 후 홈으로'.log();
                    await prefs.setBool(StorageValues.onboardingCompleted, true);

                    bool wasNoWallet = (await const SecureStorage().read(StorageValues.wasOnWelcomeWalletConnectScreen)) == "true";

                    _isNavigating = true;
                    if(wasNoWallet && StackedService.navigatorKey?.currentContext!=null){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyMembershipSettingsScreen(),
                        ),
                              (Route<dynamic> route) => false
                      );
                      Future.delayed(const Duration(seconds: 1), () => const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "false"));
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.appScreen, (Route<dynamic> route) => false);
                    }
                    return;
                  }

                  // 4️⃣ 그 외의 경우 → 온보딩으로
                  '🚀 온보딩 화면으로 이동 (With Wallet) - 새 버전: $isNewVersion, 로그아웃 후: $showOnboardingAfterLogout, 완료: $onboardingCompleted, 저장된 단계: $savedStep'.log();

                  // Clear the flag if it was set
                  if (showOnboardingAfterLogout) {
                    await prefs.setBool(StorageValues.showOnboardingAfterLogout, false);
                  }

                  // Show onboarding screen
                  _isNavigating = true;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.onboardingScreen, (Route<dynamic> route) => false);
                }
              }
            }

            if (walletsState.submitStatus == RequestStatus.failure) {
              await getIt.reset();
              await configureDependencies();
              if (context.mounted) {
                _isNavigating = true;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.serverErrorPage, (Route<dynamic> route) => false);
              }
            }
          },
        ),
      ],
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/loader.json',
              ),
              Text(
                "It is Startup Screen",
                style: fontBodyMd(color: Colors.transparent),
              )
            ],
          ),
        ),
      ),
    );
  }
}
