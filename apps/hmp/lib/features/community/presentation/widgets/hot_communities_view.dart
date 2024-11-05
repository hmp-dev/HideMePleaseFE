import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/presentation/widgets/nft_hot_community_card_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class HotCommunitiesView extends StatelessWidget {
  const HotCommunitiesView({
    super.key,
    required this.onCommunityTap,
    required this.hotNftCommunities,
  });

  final void Function(NftCommunityEntity) onCommunityTap;
  final List<NftCommunityEntity> hotNftCommunities;

  @override
  Widget build(BuildContext context) {
    if (hotNftCommunities.isEmpty) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CustomImageView(
                svgPath: 'assets/icons/fire.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  LocaleKeys.trending_community.tr(),
                  // 'Hot한 커뮤니티',
                  style: fontCompactMdMedium(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 290,
          child: ListView.separated(
            padding: const EdgeInsets.only(
                top: 32, bottom: 8.0, left: 20.0, right: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: hotNftCommunities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              return NftHotCommunityCardWidget(
                onTap: () => onCommunityTap(hotNftCommunities[index]),
                title: hotNftCommunities[index].name,
                networkLogo: hotNftCommunities[index].chainLogo,
                imagePath: hotNftCommunities[index].collectionLogo,
                people: hotNftCommunities[index].people,
                rank: hotNftCommunities[index].rank,
                timeAgo: hotNftCommunities[index].timeAgo,
                totalMembers: "${hotNftCommunities[index].totalMembers}",
              );
            },
          ),
        ),
      ],
    );
  }
}
