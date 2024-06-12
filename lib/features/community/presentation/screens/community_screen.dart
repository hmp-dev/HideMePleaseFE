import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/community/presentation/cubit/community_cubit.dart';
import 'package:mobile/features/community/presentation/screens/community_details_screen.dart';
import 'package:mobile/features/community/presentation/views/community_view.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';

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
        return BlocBuilder<HomeCubit, HomeState>(
            bloc: getIt<HomeCubit>(),
            buildWhen: (previous, current) =>
                previous.homeViewType != current.homeViewType,
            builder: (context, homeState) {
              return CommunityView(
                onRefresh: () => getIt<CommunityCubit>().onStart(),
                onCommunityTap: (community) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CommunityDetailsScreen(nftCommunity: community)));
                },
                onEnterChat: (community) {},
                onConnectWallet: () {},
                onGetFreeNft: () {},
                totalFreeNfts: '2,000',
                remainingFreeNfts: '692 남음',
                redeemedFreeNfts: '1,308',
                allNftCommunities: state.allNftCommunities,
                communityCount: state.communityCount,
                itemCount: state.itemCount,
                hotNftCommunities: state.hotNftCommunities,
                userNftCommunities: state.userNftCommunities,
                allNftCommOrderBy: state.allNftCommOrderBy,
                isWalletConnected:
                    true, // homeState.homeViewType == HomeViewType.afterWalletConnected,
                redeemedFreeNft: true,
              );
            });
      },
    );
  }
}
