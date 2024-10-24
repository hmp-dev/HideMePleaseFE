// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/enum/social_login_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/infrastructure/datasources/auth_local_data_source.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/home/presentation/widgets/notice_dialog.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/screens/space_selection_screen.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_wallet_connected.dart';
import 'package:mobile/features/home/presentation/views/home_view_before_wallet_connect.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/model_banner_cubit.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen_with_space.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/wepin_wallet_connect_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'package:upgrader/upgrader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _isVisible = true;

  String googleAccessToken = '';
  String socialTokenIsAppleOrGoogle = '';
  String appleIdToken = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _initWallets();
    _checkAndShowModelBannerDialog();
    initValues();
  }

  initValues() async {
    socialTokenIsAppleOrGoogle =
        await getIt<AuthLocalDataSource>().getSocialTokenIsAppleOrGoogle() ??
            '';

    if (socialTokenIsAppleOrGoogle == SocialLoginType.APPLE.name) {
      appleIdToken =
          await getIt<SecureStorage>().read(StorageValues.appleIdToken) ?? '';
    }

    if (socialTokenIsAppleOrGoogle == SocialLoginType.GOOGLE.name) {
      googleAccessToken =
          await getIt<AuthCubit>().refreshGoogleAccessToken() ?? '';
    }

    setState(() {});
  }

  void _initWallets() async {
    await SolanaWalletProvider.initialize();
    // initialize the w3mService
    getIt<WalletsCubit>()
        .init(context: context, solWallet: SolanaWalletProvider.of(context));
    // initialize the WepinSDK and Login
    getIt<WepinCubit>()
        .initWepinSDK(selectedLanguageCode: context.locale.languageCode);

    // getIt<WepinCubit>().initWepinSDK(
    //   selectedLanguageCode: context.locale.languageCode,
    // );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      getIt<NftBenefitsCubit>().onGetNftBenefitsLoadMore();
    }

    if (_scrollController.offset >= 80 && _isVisible) {
      // fetch nft benefits
      if (getIt<NftBenefitsCubit>().state.nftBenefitList.isEmpty) {
        "fetch nft benefits with scroll listener".log();
        final selectedNftTokensList =
            getIt<NftCubit>().state.selectedNftTokensList;
        if (selectedNftTokensList.isNotEmpty) {
          getIt<NftBenefitsCubit>().onGetNftBenefits(
              tokenAddress: selectedNftTokensList[0].tokenAddress);
        }
      }
      setState(() {
        _isVisible = false;
      });
    } else if (_scrollController.offset < 80 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  Future<void> _checkAndShowModelBannerDialog() async {
    final modelBannerInfo = getIt<ModelBannerCubit>().state.modelBannerEntity;

    "modelBannerInfo modelBannerInfo.startDate : ${modelBannerInfo.startDate}"
        .log();
    "modelBannerInfo modelBannerInfo.endDate : ${modelBannerInfo.endDate}"
        .log();
    "modelBannerInfo image : ${modelBannerInfo.image}".log();
    "Current : ${DateTime.now}".log();
    "is Today is in between ${isTodayWithinDateRange(modelBannerInfo.startDate, modelBannerInfo.endDate)}"
        .log();

    if (isTodayWithinDateRange(
        modelBannerInfo.startDate, modelBannerInfo.endDate)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get current date
      DateTime now = DateTime.now();

      // Get last skip date from SharedPreferences
      int skipDateMillis = prefs.getInt('sevenDaySkipDate') ?? 0;
      DateTime skipDate = DateTime.fromMillisecondsSinceEpoch(skipDateMillis);

      // Calculate the difference in days between the current date and the skip date
      int differenceInDays = now.difference(skipDate).inDays;

      // Show the dialog here
      Log.debug('day passed to skip are : $differenceInDays');
      // If it has been seven or more days since the skip date, show the dialog
      if (differenceInDays >= 7) {
        // Show the dialog here
        Log.debug('Showing daily service notice dialog.');
        showDailyServiceNoticeDialog(modelBannerInfo.image);
      }
    }
  }

  bool isTodayWithinDateRange(String startDate, String endDate) {
    // Try to parse the startDate and endDate strings into DateTime objects
    DateTime? start = DateTime.tryParse(startDate);
    DateTime? end = DateTime.tryParse(endDate);

    // If either date fails to parse, return true
    if (start == null || end == null) {
      return true;
    }

    // Get the current date and time
    DateTime now = DateTime.now();

    // Check if the current date and time is within the range
    return now.isAfter(start) && now.isBefore(end);
  }

  showDailyServiceNoticeDialog(String imageUrl) async {
    // sow NoticeDialog on firstLoad after Sign Up
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      NoticeDialog.show(
        context: context,
        imageUrl: imageUrl,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override

  /// Builds the widget tree for the [HomeScreen]
  ///
  /// This function sets up the widget tree for the [HomeScreen] and returns a
  /// [MultiBlocListener] widget. It listens to changes in the [WalletsCubit]
  /// and [NearBySpacesCubit] states and updates the UI accordingly. It also
  /// builds the [HomeView] based on the [HomeViewType] state.
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      // Listen to changes in the [WalletsCubit] and perform actions accordingly
      listeners: [
        BlocListener<WalletsCubit, WalletsState>(
          listenWhen: (previous, current) =>
              previous.connectedWallets.length <
              current.connectedWallets.length,
          bloc: getIt<WalletsCubit>(),
          listener: (context, state) {
            if (state.isSubmitSuccess) {
              "I am listing submit success inside HomeScreen".log();
              // Show the AfterLoginWithNFT screen
              getIt<HomeCubit>()
                  .onUpdateHomeViewType(HomeViewType.afterWalletConnected);
              // Apply conditions to decide whether to navigate to MyMembershipSettingsScreen
              // based on the newly connected Wallet type and user freeNftClaimed status
              if (state.connectedWallets.isNotEmpty &&
                  hasKlipProvider(state.connectedWallets)) {
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.afterWalletConnected);
              } else if (state.connectedWallets.isNotEmpty &&
                  hasWePinProvider(state.connectedWallets)) {
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.afterWalletConnected);
              } else {
                // Fetch nft collections
                getIt<NftCubit>().onGetNftCollections();
                getIt<HomeCubit>()
                    .onUpdateHomeViewType(HomeViewType.afterWalletConnected);
                // Navigate to MyMembershipSettingsScreen
                MyMembershipSettingsScreen.push(context);
              }
            }
          },
        ),
        BlocListener<NearBySpacesCubit, NearBySpacesState>(
          bloc: getIt<NearBySpacesCubit>(),
          listenWhen: (previous, current) =>
              current.spacesResponseEntity.spaces !=
              previous.spacesResponseEntity.spaces,
          listener: (context, state) async {
            if (state.isSubmitSuccess) {
              if (state.spacesResponseEntity.spaces.isEmpty &&
                  state.selectedBenefitEntity.spaceId.isNotEmpty) {
                // Navigate to RedeemBenefitScreen with empty space
                RedeemBenefitScreen.push(
                  context,
                  nearBySpaceEntity: const NearBySpaceEntity.empty(),
                  selectedBenefitEntity: state.selectedBenefitEntity,
                  isMatchedSpaceFound: false,
                );
              } else if (state.spacesResponseEntity.spaces.isNotEmpty) {
                // Determine which view to show based on selectedBenefitEntity
                if (state.selectedBenefitEntity.spaceId.isNotEmpty) {
                  // Check if the selected space is present in the list of spaces
                  bool isSpaceMatched = false;
                  NearBySpaceEntity matchedSpace =
                      const NearBySpaceEntity.empty();

                  for (var space in state.spacesResponseEntity.spaces) {
                    if (state.selectedSpaceDetailEntity.id.isNotEmpty) {
                      if (space.id == state.selectedSpaceDetailEntity.id) {
                        isSpaceMatched = true;
                        matchedSpace = space;
                        break;
                      }
                    } else if (space.id ==
                        state.selectedBenefitEntity.spaceId) {
                      isSpaceMatched = true;
                      matchedSpace = space;
                      break;
                    }
                  }

                  await Future.delayed(const Duration(milliseconds: 500));

                  if (state.selectedSpaceDetailEntity.id.isNotEmpty) {
                    // Navigate to RedeemBenefitScreenWithSpace
                    RedeemBenefitScreenWithSpace.push(
                      context,
                      isMatchedSpaceFound: isSpaceMatched,
                      space: state.selectedSpaceDetailEntity,
                      selectedBenefitEntity: state.selectedBenefitEntity,
                    );
                  } else if (isSpaceMatched) {
                    // Navigate to RedeemBenefitScreen with matched space
                    RedeemBenefitScreen.push(
                      context,
                      nearBySpaceEntity: matchedSpace,
                      selectedBenefitEntity: state.selectedBenefitEntity,
                      isMatchedSpaceFound: true,
                    );
                  } else {
                    // Navigate to RedeemBenefitScreen with first space
                    RedeemBenefitScreen.push(
                      context,
                      nearBySpaceEntity: state.spacesResponseEntity.spaces[0],
                      selectedBenefitEntity: state.selectedBenefitEntity,
                      isMatchedSpaceFound: false,
                    );
                  }
                } else {
                  // Navigate to RedeemBenefitScreen with first space
                  RedeemBenefitScreen.push(
                    context,
                    nearBySpaceEntity: state.spacesResponseEntity.spaces[0],
                  );
                }
              } else if (state.selectedSpaceDetailEntity.id.isNotEmpty) {
                // Navigate to RedeemBenefitScreenWithSpace with empty spaces
                RedeemBenefitScreenWithSpace.push(
                  context,
                  isMatchedSpaceFound: false,
                  space: state.selectedSpaceDetailEntity,
                  selectedBenefitEntity: state.selectedBenefitEntity,
                );
              } else {
                // Show SpaceSelectionScreen
                SpaceSelectionScreen.show(context, []);
              }
            }
          },
        ),
      ],
      // Build the widget tree based on the HomeState and NftState
      child: BlocBuilder<HomeCubit, HomeState>(
        bloc: getIt<HomeCubit>(),
        builder: (context, state) {
          return BlocBuilder<NftCubit, NftState>(
            bloc: getIt<NftCubit>(),
            builder: (context, nftState) {
              return kDebugMode
                  ? SingleChildScrollView(
                      controller: _scrollController,
                      child: getHomeView(state.homeViewType),
                    )
                  : UpgradeAlert(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: getHomeView(state.homeViewType),
                      ),
                    );
            },
          );
        },
      ),
    );
  }

  getHomeView(HomeViewType homeViewType) {
    if (homeViewType == HomeViewType.afterWalletConnected) {
      return HomeViewAfterWalletConnected(
        isOverIconNavVisible: _isVisible,
        homeViewScrollController: _scrollController,
      );
    } else {
      return HomeViewBeforeWalletConnect(
        // googleAccessToken: googleAccessToken,
        // socialTokenIsAppleOrGoogle: socialTokenIsAppleOrGoogle,
        // appleIdToken: appleIdToken,
        // selectedLanguage: context.locale.languageCode,
        onConnectWallet: () async {
          getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
          //
          await Future.delayed(const Duration(milliseconds: 100));
          //
          getIt<WalletsCubit>().onConnectWallet(
              context: context, isFromWePinWelcomeNftRedeem: true);
        },
      );
    }
  }

  bool hasKlipProvider(List<ConnectedWalletEntity> connectedWallets) {
    bool result = false;
    if (connectedWallets.isEmpty) {
      result = false;
    }
    for (var wallet in connectedWallets) {
      if (wallet.provider == 'KLIP') {
        result = true;
      }
    }
    return result;
  }

  bool hasWePinProvider(List<ConnectedWalletEntity> connectedWallets) {
    bool result = false;
    if (connectedWallets.isEmpty) {
      result = false;
    }
    for (var wallet in connectedWallets) {
      if (wallet.provider == 'WEPIN_EVM') {
        result = true;
      }
    }
    return result;
  }
}
