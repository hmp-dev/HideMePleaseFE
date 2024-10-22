import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/community/presentation/cubit/community_cubit.dart';
import 'package:mobile/features/community/presentation/screens/community_details_screen.dart';
import 'package:mobile/features/community/presentation/views/community_view.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/features/wepin/wepin_wallet_connect_list_tile.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    getIt<CommunityCubit>().onStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      bloc: getIt<CommunityCubit>(),
      builder: (context, state) {
        return BlocBuilder<NftCubit, NftState>(
          bloc: getIt<NftCubit>(),
          buildWhen: (previous, current) =>
              previous.welcomeNftEntity != current.welcomeNftEntity,
          builder: (context, nftState) {
            return BlocBuilder<HomeCubit, HomeState>(
                bloc: getIt<HomeCubit>(),
                buildWhen: (previous, current) =>
                    previous.homeViewType != current.homeViewType,
                builder: (context, homeState) {
                  return CommunityView(
                    onRefresh: () => getIt<CommunityCubit>().onStart(),
                    onLoadMore: () => getIt<CommunityCubit>()
                        .onGetAllNftCommunitiesLoadMore(),
                    onCommunityTap: (community) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CommunityDetailsScreen(
                                  nftCommunity: community)));
                    },
                    onEnterChat: (community) {
                      CommunityChatScreen.push(context,
                          channel: community.tokenAddress);
                    },
                    onConnectWallet: () async {
                      if (getIt<WalletsCubit>().state.reownAppKitModal !=
                          null) {
                        getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
                        //
                        await Future.delayed(const Duration(milliseconds: 100));
                        //
                        getIt<WalletsCubit>().onConnectWallet(
                            context: context, isFromWePinWalletConnect: true);
                      }
                    },
                    onGetFreeNft: () {},
                    onOrderByChanged: (orderBy) =>
                        getIt<CommunityCubit>().onOrderByChanged(orderBy),
                    welcomeNft: nftState.welcomeNftEntity,
                    orderBy: state.allNftCommOrderBy,
                    allNftCommunities: state.allNftCommunities,
                    communityCount: state.communityCount,
                    itemCount: state.itemCount,
                    hotNftCommunities: state.hotNftCommunities,
                    userNftCommunities: state.userNftCommunities,
                    allNftCommOrderBy: state.allNftCommOrderBy,
                    isWalletConnected: homeState.homeViewType ==
                        HomeViewType.afterWalletConnected,
                    redeemedFreeNft:
                        !nftState.welcomeNftEntity.freeNftAvailable,
                    isLoadingMore: state.isLoadingMore,
                  );
                });
          },
        );
      },
    );
  }
}
