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
  @override
  void initState() {
    getIt<AppCubit>().onStart();
    //getIt<ProfileCubit>().onStart();
    super.initState();
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
          listener: (context, state) async {
            print('🎯 StartUpScreen: AppCubit state received');
            print('🎯 Is logged in: ${state.isLoggedIn}');

            if (!state.isLoggedIn) {
              // Not logged in - navigate to login immediately
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.socialLogin, (Route<dynamic> route) => false);
            } else {
              // User is logged in - proceed with initialization
              ("-------inside state.isLoggedIn: ${state.isLoggedIn}").log();

              // Check background location permission ONLY for logged-in users
              if (context.mounted) {
                print('🎯 StartUpScreen: Checking background location for logged-in user...');
                await BackgroundLocationService.checkAndRequestBackgroundLocation(context);
                print('🎯 StartUpScreen: BackgroundLocationService completed');
              }

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

              // Now fetch wallets after permission dialog is handled
              // This ensures navigation doesn't interrupt the dialog
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

                // If new version, reset onboarding flags
                if (isNewVersion) {
                  '🆕 New onboarding version detected, resetting flags...'.log();
                  await prefs.remove(StorageValues.onboardingCompleted);
                  await prefs.remove(StorageValues.onboardingCurrentStep);
                  await prefs.remove(StorageValues.hasMintedNft);
                  await prefs.remove(StorageValues.hasProfileParts);
                }

                final onboardingCompleted = prefs.getBool(StorageValues.onboardingCompleted) ?? false;
                final showOnboardingAfterLogout = prefs.getBool(StorageValues.showOnboardingAfterLogout) ?? false;
                final savedStep = prefs.getInt(StorageValues.onboardingCurrentStep);

                // Check for NFT minting and profile image
                final hasMintedNft = prefs.getBool(StorageValues.hasMintedNft) ?? false;
                final hasWallet = prefs.getBool(StorageValues.hasWallet) ?? false;
                final hasProfileParts = prefs.getBool(StorageValues.hasProfileParts) ?? false;

                // Check current profile status
                final profileCubit = getIt<ProfileCubit>();
                final userProfile = profileCubit.state.userProfileEntity;
                final hasProfileImage = userProfile?.finalProfileImageUrl?.isNotEmpty == true;

                // 🚨 최우선: 백엔드 API의 onboardingCompleted 체크
                final backendOnboardingCompleted = userProfile?.onboardingCompleted ?? false;
                '🔍 백엔드 API onboardingCompleted: $backendOnboardingCompleted'.log();

                // 백엔드 API에서 온보딩이 완료되지 않았으면 무조건 온보딩 화면으로
                if (!backendOnboardingCompleted && context.mounted) {
                  '🚀 백엔드 API에서 온보딩 미완료 확인 - 온보딩 화면으로 이동'.log();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.onboardingScreen, (Route<dynamic> route) => false);
                  return; // 여기서 종료
                }

                // 🚨 실제 프로필 파츠 확인
                final hasActualProfileParts = userProfile?.profilePartsString?.isNotEmpty == true;

                // Check nickname validity
                final isValidNickname = userProfile?.nickName != null &&
                                        userProfile!.nickName.isNotEmpty &&
                                        !userProfile.nickName.startsWith('HMP');

                // Enhanced skip logic: profilePartsString이 없으면 무조건 온보딩
                final shouldSkipOnboarding = hasActualProfileParts && hasWallet && hasMintedNft && hasProfileImage && isValidNickname;

                '📊 Onboarding check - ProfileParts: $hasActualProfileParts, Wallet: $hasWallet, Minted: $hasMintedNft, ProfileImage: $hasProfileImage, ValidNickname: $isValidNickname'.log();
                '🎯 Should skip onboarding: $shouldSkipOnboarding'.log();

                if (context.mounted) {
                  // Show onboarding if:
                  // 1. New version detected (isNewVersion)
                  // 2. User logged out and logged back in (showOnboardingAfterLogout flag)
                  // 3. Onboarding not completed yet (unless skip conditions are met)
                  // 4. There's a saved step (user left mid-onboarding) and onboarding not completed
                  //if (true) { //debug
                  if (isNewVersion || (!shouldSkipOnboarding && (showOnboardingAfterLogout || !onboardingCompleted || (savedStep != null && !onboardingCompleted)))) {
                    '🚀 온보딩 화면으로 이동 - 새 버전: $isNewVersion, 로그아웃 후: $showOnboardingAfterLogout, 완료: $onboardingCompleted, 저장된 단계: $savedStep'.log();
                    
                    // Clear the flag if it was set
                    if (showOnboardingAfterLogout) {
                      await prefs.setBool(StorageValues.showOnboardingAfterLogout, false);
                    }
                    
                    // Show onboarding screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.onboardingScreen, (Route<dynamic> route) => false);
                  } else {
                    // Returning user or skip conditions met - go to home
                    if (shouldSkipOnboarding && !onboardingCompleted) {
                      '✅ Skipping onboarding - all conditions met'.log();
                      // Mark onboarding as completed if skipping due to having all requirements
                      await prefs.setBool(StorageValues.onboardingCompleted, true);
                    }
                    const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "true");
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.appScreen, (Route<dynamic> route) => false);
                  }
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

                // If new version, reset onboarding flags
                if (isNewVersion) {
                  '🆕 New onboarding version detected (With Wallet), resetting flags...'.log();
                  await prefs.remove(StorageValues.onboardingCompleted);
                  await prefs.remove(StorageValues.onboardingCurrentStep);
                  await prefs.remove(StorageValues.hasMintedNft);
                  await prefs.remove(StorageValues.hasProfileParts);
                }

                final onboardingCompleted = prefs.getBool(StorageValues.onboardingCompleted) ?? false;
                final showOnboardingAfterLogout = prefs.getBool(StorageValues.showOnboardingAfterLogout) ?? false;

                // Check for NFT minting and profile image
                final hasMintedNft = prefs.getBool(StorageValues.hasMintedNft) ?? false;
                final hasProfileParts = prefs.getBool(StorageValues.hasProfileParts) ?? false;

                // Check current profile status
                final profileCubit = getIt<ProfileCubit>();
                final userProfile = profileCubit.state.userProfileEntity;
                final hasProfileImage = userProfile?.finalProfileImageUrl?.isNotEmpty == true;

                // 🚨 최우선: 백엔드 API의 onboardingCompleted 체크
                final backendOnboardingCompleted = userProfile?.onboardingCompleted ?? false;
                '🔍 백엔드 API onboardingCompleted (With Wallet): $backendOnboardingCompleted'.log();

                // 백엔드 API에서 온보딩이 완료되지 않았으면 무조건 온보딩 화면으로
                if (!backendOnboardingCompleted && context.mounted) {
                  '🚀 백엔드 API에서 온보딩 미완료 확인 (With Wallet) - 온보딩 화면으로 이동'.log();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.onboardingScreen, (Route<dynamic> route) => false);
                  return; // 여기서 종료
                }

                // 🚨 실제 프로필 파츠 확인
                final hasActualProfileParts = userProfile?.profilePartsString?.isNotEmpty == true;

                // Check nickname validity
                final isValidNickname = userProfile?.nickName != null &&
                                        userProfile!.nickName.isNotEmpty &&
                                        !userProfile.nickName.startsWith('HMP');

                // Enhanced skip logic: profilePartsString이 없으면 무조건 온보딩 (지갑은 이미 있음)
                final shouldSkipOnboarding = hasActualProfileParts && hasMintedNft && hasProfileImage && isValidNickname;

                '📊 Onboarding check (With Wallet) - ProfileParts: $hasActualProfileParts, Minted: $hasMintedNft, ProfileImage: $hasProfileImage, ValidNickname: $isValidNickname'.log();
                '🎯 Should skip onboarding (With Wallet): $shouldSkipOnboarding'.log();

                if (context.mounted) {
                  // Show onboarding if:
                  // 1. New version detected (isNewVersion)
                  // 2. User logged out and logged back in (showOnboardingAfterLogout flag)
                  // 3. Onboarding not completed yet (unless skip conditions are met)
                  if (isNewVersion || (!shouldSkipOnboarding && (showOnboardingAfterLogout || !onboardingCompleted))) {
                    '🚀 온보딩 화면으로 이동 (With Wallet) - 새 버전: $isNewVersion, 로그아웃 후: $showOnboardingAfterLogout, 완료: $onboardingCompleted'.log();

                    // Clear the flag if it was set
                    if (showOnboardingAfterLogout) {
                      await prefs.setBool(StorageValues.showOnboardingAfterLogout, false);
                    }

                    // Show onboarding screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.onboardingScreen, (Route<dynamic> route) => false);
                  } else {
                    // Returning user or skip conditions met - check wasNoWallet
                    if (shouldSkipOnboarding && !onboardingCompleted) {
                      '✅ Skipping onboarding (With Wallet) - all conditions met'.log();
                      // Mark onboarding as completed if skipping due to having all requirements
                      await prefs.setBool(StorageValues.onboardingCompleted, true);
                    }

                    bool wasNoWallet = (await const SecureStorage().read(StorageValues.wasOnWelcomeWalletConnectScreen)) == "true";

                    if(wasNoWallet && StackedService.navigatorKey?.currentContext!=null){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyMembershipSettingsScreen(),
                        ),
                              (Route<dynamic> route) => false
                      );
                      /*Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.appScreen, (Route<dynamic> route) => false);*/
                      Future.delayed(const Duration(seconds: 1), () => const SecureStorage().write(StorageValues.wasOnWelcomeWalletConnectScreen, "false"));
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.appScreen, (Route<dynamic> route) => false);
                    }
                  }
                }
              }
            }

            if (walletsState.submitStatus == RequestStatus.failure) {
              await getIt.reset();
              await configureDependencies();
              if (context.mounted) {
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
