import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/presentation/cubit/dummy_data.dart';
import 'package:mobile/features/community/presentation/widgets/participated_community_nft_view.dart';

class UserCommunitiesView extends StatelessWidget {
  const UserCommunitiesView({
    super.key,
    required this.onTap,
    required this.onEnterChat,
    required this.userNftCommunities,
  });

  final void Function(NftCommunityEntity) onTap;
  final void Function(NftCommunityEntity) onEnterChat;
  final List<NftCommunityEntity> userNftCommunities;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '대화중인 커뮤니티',
                      style: fontTitle07Medium(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    userNftCommunities.length.toString(),
                    style: fontTitle07(color: fore2),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '전체 리스트',
                  style: fontCompactSm(color: fore2),
                ),
                const SizedBox(width: 5),
                DefaultImage(
                  path: "assets/icons/arrow_right.svg",
                  width: 14,
                  height: 14,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 483.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: userNftCommunities.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: userNftCommunities.length == 1
                    ? MediaQuery.of(context).size.width - 40.0
                    : MediaQuery.of(context).size.width * 0.75,
                child: ParticipatedCommunityNftView(
                  onTap: () => onTap(userNftCommunities[index]),
                  onEnterChat: () => onEnterChat(userNftCommunities[index]),
                  communityPeoples: userNftCommunities[index].people,
                  recentMsgs: recentDummyMsgs,
                  communityName: userNftCommunities[index].name,
                  collectionLogo: userNftCommunities[index].collectionLogo,
                  networkLogo:
                      "assets/chain-logos/${userNftCommunities[index].chain.toLowerCase()}_chain.svg",
                  unreadMsgCount: 99,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
