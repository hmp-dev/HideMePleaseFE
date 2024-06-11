import 'package:flutter/material.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/community/presentation/views/community_details_view.dart';

class CommunityDetailsScreen extends StatelessWidget {
  const CommunityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommunityDetailsView(
      onEnterChat: () {},
      nftEntity: const TopCollectionNftEntity(
          pointFluctuation: 0,
          tokenAddress: '',
          name: "Ukraine UN Ape",
          chain: "ETHEREUM",
          collectionLogo:
              "https://i.seadn.io/gae/DJc1oH2TtKvfFSy1a1Q0g9Wy56iaZ-q_WOFjiydpw6AACsHsd4bSJ8lmaY-NpxbGxFwcGi7z5FeSu-vhJXYjXqbVnxHgu1_hSNZCxvw?w=500&auto=format",
          totalPoints: 4,
          communityRank: 1,
          ownedCollection: false),
    );
  }
}
