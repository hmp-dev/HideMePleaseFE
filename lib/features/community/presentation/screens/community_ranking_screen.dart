import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/community/presentation/cubit/community_rankings_cubit.dart';
import 'package:mobile/features/community/presentation/screens/community_details_screen.dart';
import 'package:mobile/features/community/presentation/views/community_ranking_view.dart';

class CommunityRankingScreen extends StatelessWidget {
  const CommunityRankingScreen({super.key, required this.nftInfo});

  final TopCollectionNftEntity nftInfo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityRankingsCubit, CommunityRankingsState>(
      bloc: getIt<CommunityRankingsCubit>()..onStart(nftInfo: nftInfo),
      builder: (context, state) {
        return CommunityRankingView(
          onRetry: () =>
              getIt<CommunityRankingsCubit>().onStart(nftInfo: nftInfo),
          onLoadMore: () =>
              getIt<CommunityRankingsCubit>().onLoadMore(nftInfo: nftInfo),
          onCommunityTap: (nft) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CommunityDetailsScreen(
                          nftCommunity: NftCommunityEntity.empty().copyWith(
                        tokenAddress: nft.tokenAddress,
                        name: nft.name,
                        collectionLogo: nft.collectionLogo,
                      )))),
          isLoadingMore: state.isLoadingMore,
          isLoading: state.isLoading,
          isError: state.isFailure,
          topNfts: state.topNfts,
          allLoaded: state.isLoadedAll,
          selectedNft: nftInfo,
        );
      },
    );
  }
}
