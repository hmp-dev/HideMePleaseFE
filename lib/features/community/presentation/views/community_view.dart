import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_dto.dart';
import 'package:mobile/features/community/presentation/widgets/nft_community_card_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class CommunityView extends StatefulWidget {
  final List<NftCommunityEntity> allNftCommunities;
  final int communityCount;
  final int itemCount;
  final List<NftCommunityEntity> hotNftCommunities;
  final List<NftCommunityEntity> userNftCommunities;
  final GetNftCommunityOrderBy allNftCommOrderBy;

  const CommunityView({
    super.key,
    required this.allNftCommunities,
    required this.communityCount,
    required this.itemCount,
    required this.hotNftCommunities,
    required this.userNftCommunities,
    required this.allNftCommOrderBy,
  });

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopTitleBar(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        LocaleKeys.evenPeopleWithNftTitle.tr(),
                        style: fontTitle05Medium(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.getAFreeNft.tr(),
                            style: fontCompactSm(color: fore2),
                          ),
                          CustomImageView(
                            svgPath: 'assets/icons/ic_angle_arrow_down.svg',
                            color: fore2,
                            width: 16,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                CustomImageView(
                  imagePath: 'assets/images/connect.png',
                  width: 88,
                  height: 88,
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.allCommunity.tr(),
                      style: fontTitle07Medium(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.communityCount.toString(),
                      style: fontTitle07(color: fore2),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.byPoints.tr(),
                      style: fontCompactSm(color: fore2),
                    ),
                    const SizedBox(width: 5),
                    DefaultImage(
                      path: "assets/icons/ic_arrow_down.svg",
                      width: 14,
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.center,
                children: List.generate(
                  widget.allNftCommunities.length,
                  (index) {
                    return NftCommunityCardWidget(
                      title: widget.allNftCommunities[index].name,
                      imagePath: widget.allNftCommunities[index].collectionLogo,
                      people: widget.allNftCommunities[index].people,
                      rank: widget.allNftCommunities[index].rank,
                      timeAgo: widget.allNftCommunities[index].timeAgo,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildTopTitleBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      height: 75,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Chat me", style: fontBody2Bold()),
            const AlarmsIconButton(),
          ],
        ),
      ),
    );
  }
}
