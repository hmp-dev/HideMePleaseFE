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
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/nearby_spaces_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_detail_cubit.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen_from_benefit_tap.dart';
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
    if (_scrollController.offset >= 80 && _isVisible) {
      setState(() {
        _isVisible = false;
      });

      "ScrollController: ${_scrollController.offset} $_isVisible".log();
    } else if (_scrollController.offset < 80 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });

      "ScrollController: ${_scrollController.offset} $_isVisible".log();
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
              if (state.spacesResponseEntity.spaces.isNotEmpty) {
                // check if state.selectedBenefitEntity is null
                // if null then show Space Selection View
                // otherwise show Redeem Benefit View

                if (state.selectedBenefitEntity.spaceId != '') {
                  "inside state.selectedBenefitEntity.spaceId != '' :${state.selectedBenefitEntity.spaceId} "
                      .log();

                  // check if in state.spacesResponseEntity.spaces  any of space id is equal
                  // to state.selectedBenefitEntity.id
                  // if yes then show Space Selection View
                  // otherwise show Redeem Benefit View
                  bool isSpaceMatched = false;
                  NearBySpaceEntity matchedSpace =
                      const NearBySpaceEntity.empty();
                  for (var space in state.spacesResponseEntity.spaces) {
                    if (space.id == state.selectedBenefitEntity.spaceId) {
                      isSpaceMatched = true;
                      matchedSpace = space;
                      break;
                    }
                  }

                  await Future.delayed(const Duration(milliseconds: 500));
                  if (isSpaceMatched) {
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
                  // space list has more than 1 show Space Selection View
                  // otherwise show Redeem Benefit View
                  if (state.spacesResponseEntity.spaces.length > 1) {
                    SpaceSelectionScreen.show(
                        context, state.spacesResponseEntity.spaces);
                  } else {
                    RedeemBenefitScreen.push(
                      context,
                      nearBySpaceEntity: state.spacesResponseEntity.spaces[0],
                    );
                  }
                }
              } else {
                SpaceSelectionScreen.show(context, []);
              }
            }
          },
        ),
        BlocListener<SpaceDetailCubit, SpaceDetailState>(
          bloc: getIt<SpaceDetailCubit>(),
          listener: (context, state) {
            if (state.isSubmitSuccess) {
              if (state.submitStatus == RequestStatus.success) {
                RedeemBenefitScreenFromBenefitTap.push(context,
                    state.selectedBenefitEntity, state.spaceDetailEntity);
              }
            }
          },
        ),
      ],
      child: BlocConsumer<HomeCubit, HomeState>(
        bloc: getIt<HomeCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          return UpgradeAlert(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: getHomeView(state.homeViewType),
            ),
          );
        },
      ),
    );
  }

  getHomeView(HomeViewType homeViewType) {
    if (homeViewType == HomeViewType.afterWalletConnected) {
      return HomeViewAfterWalletConnected(isOverIconNavVisible: _isVisible);
    } else {
      return const HomeViewBeforeLogin();
    }
  }
}
