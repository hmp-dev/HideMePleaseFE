// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/screens/space_selection_screen.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_wallet_connected.dart';
import 'package:mobile/features/home/presentation/views/home_view_before_login.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen_with_space.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _initWallets();
    // Ask for device location
    getIt<EnableLocationCubit>().onAskDeviceLocation();
  }

  void _initWallets() async {
    await SolanaWalletProvider.initialize();
    // initialize the w3mService
    getIt<WalletsCubit>().init(solWallet: SolanaWalletProvider.of(context));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      getIt<NftBenefitsCubit>().onGetNftBenefitsLoadMore();
    }

    if (_scrollController.offset >= 80 && _isVisible) {
      setState(() {
        _isVisible = false;
      });
    } else if (_scrollController.offset < 80 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WalletsCubit, WalletsState>(
          // only listen to navigate to MyMembershipSettingsScreen
          // when a new wallet is connected
          listenWhen: (previous, current) =>
              previous.connectedWallets.length <
              current.connectedWallets.length,
          bloc: getIt<WalletsCubit>(),
          listener: (context, state) {
            if (state.isSubmitSuccess) {
              // call to get nft collections
              getIt<NftCubit>().onGetNftCollections();
              // show the AfterLoginWithNFT screen
              getIt<HomeCubit>()
                  .onUpdateHomeViewType(HomeViewType.afterWalletConnected);
              // navigate to MyMembershipSettingsScreen
              MyMembershipSettingsScreen.push(context);
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
                RedeemBenefitScreen.push(
                  context,
                  nearBySpaceEntity: const NearBySpaceEntity.empty(),
                  selectedBenefitEntity: state.selectedBenefitEntity,
                  isMatchedSpaceFound: false,
                );
              } else if (state.spacesResponseEntity.spaces.isNotEmpty) {
                // Determine which view to show based on selectedBenefitEntity
                if (state.selectedBenefitEntity.spaceId.isNotEmpty) {
                  "inside state.selectedBenefitEntity.spaceId != '' :${state.selectedBenefitEntity.spaceId}"
                      .log();

                  bool isSpaceMatched = false;
                  NearBySpaceEntity matchedSpace =
                      const NearBySpaceEntity.empty();

                  for (var space in state.spacesResponseEntity.spaces) {
                    if (state.selectedSpaceDetailEntity.id.isNotEmpty) {
                      "inside Selected SpaceID is not null: ${state.selectedSpaceDetailEntity.id}"
                          .log();
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
                    RedeemBenefitScreenWithSpace.push(
                      context,
                      isMatchedSpaceFound: isSpaceMatched,
                      space: state.selectedSpaceDetailEntity,
                      selectedBenefitEntity: state.selectedBenefitEntity,
                    );
                  } else if (isSpaceMatched) {
                    "inside space selected".log();
                    RedeemBenefitScreen.push(
                      context,
                      nearBySpaceEntity: matchedSpace,
                      selectedBenefitEntity: state.selectedBenefitEntity,
                      isMatchedSpaceFound: true,
                    );
                  } else {
                    "inside space ELSE selected".log();
                    RedeemBenefitScreen.push(
                      context,
                      nearBySpaceEntity: state.spacesResponseEntity.spaces[0],
                      selectedBenefitEntity: state.selectedBenefitEntity,
                      isMatchedSpaceFound: false,
                    );
                  }
                } else {
                  // Show Space Selection View if there are multiple spaces, otherwise show Redeem Benefit View
                  // if (state.spacesResponseEntity.spaces.length > 1) {
                  //   SpaceSelectionScreen.show(
                  //       context, state.spacesResponseEntity.spaces);
                  // } else {

                  // Do not Show SpaceSelectionScreen Directly Go to RedeemBenefitScreen
                  RedeemBenefitScreen.push(
                    context,
                    nearBySpaceEntity: state.spacesResponseEntity.spaces[0],
                  );
                  //}
                }
              } else if (state.selectedSpaceDetailEntity.id.isNotEmpty) {
                "inside nearby spaces are empty and state.selectedSpaceDetailEntity.id != ''"
                    .log();
                RedeemBenefitScreenWithSpace.push(
                  context,
                  isMatchedSpaceFound: false,
                  space: state.selectedSpaceDetailEntity,
                  selectedBenefitEntity: state.selectedBenefitEntity,
                );
              } else {
                SpaceSelectionScreen.show(context, []);

                // here I need the Token Address to pass and  fetch and show the NFT benefits list
              }
            }
          },
        ),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        bloc: getIt<HomeCubit>(),
        builder: (context, state) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            bloc: getIt<ProfileCubit>(),
            buildWhen: (previous, current) =>
                previous.userProfileEntity != current.userProfileEntity,
            builder: (context, profileState) {
              return UpgradeAlert(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: getHomeView(
                      state.homeViewType, profileState.userProfileEntity),
                ),
              );
            },
          );
        },
      ),
    );
  }

  getHomeView(
    HomeViewType homeViewType,
    UserProfileEntity userProfile,
  ) {
    if (homeViewType == HomeViewType.afterWalletConnected) {
      return HomeViewAfterWalletConnected(
        isOverIconNavVisible: _isVisible,
        homeViewScrollController: _scrollController,
        userProfile: userProfile,
      );
    } else {
      return HomeViewBeforeLogin(
        onConnectWallet: () {
          if (getIt<WalletsCubit>().state.w3mService != null) {
            getIt<WalletsCubit>().onConnectWallet(context);
          }
        },
      );
    }
  }
}
