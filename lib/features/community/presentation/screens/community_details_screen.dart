import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/community/presentation/cubit/community_details_cubit.dart';
import 'package:mobile/features/community/presentation/views/community_details_view.dart';
import 'package:mobile/features/my/presentation/screens/member_details_screen.dart';

class CommunityDetailsScreen extends StatelessWidget {
  const CommunityDetailsScreen({super.key, required this.nftCommunity});

  final NftCommunityEntity nftCommunity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityDetailsCubit, CommunityDetailsState>(
      bloc: getIt<CommunityDetailsCubit>()
        ..onStart(tokenAddress: nftCommunity.tokenAddress),
      builder: (context, state) {
        return CommunityDetailsView(
          onEnterChat: () {},
          onRetry: () => getIt<CommunityDetailsCubit>()
              .onStart(tokenAddress: nftCommunity.tokenAddress),
          onMemberTap: (member) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MemberDetailsScreen(member: member)),
            );
          },
          nftEntity: TopCollectionNftEntity(
            pointFluctuation: state.nftInfo.pointFluctuation,
            tokenAddress: nftCommunity.tokenAddress,
            name: nftCommunity.name,
            chain: state.nftNetworkInfo.network,
            collectionLogo: nftCommunity.collectionLogo,
            totalPoints: state.nftInfo.totalPoints,
            communityRank: state.nftInfo.communityRank,
            ownedCollection: state.nftInfo.ownedCollection,
          ),
          nftNetwork: state.nftNetworkInfo,
          communityMembers: state.communityMembers,
          membersCount: state.membersCount,
          nftBenefits: state.nftBenefits,
          benefitCount: state.benefitCount,
          infoLoading: state.isLoading,
          infoError: state.isFailure,
          membersLoading: state.isMembersLoading,
          membersError: state.isMembersError,
        );
      },
    );
  }
}
