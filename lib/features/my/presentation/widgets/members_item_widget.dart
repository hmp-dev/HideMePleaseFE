import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MembersItemWidget extends StatelessWidget {
  const MembersItemWidget({
    super.key,
    required this.isLastItem,
    required this.nft,
    required this.onTap,
  });

  final bool isLastItem;
  final SelectedNFTEntity nft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                buildImageWidget(),
                const HorizontalSpace(20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 150,
                      child: Text(
                        nft.name,
                        overflow: TextOverflow.ellipsis,
                        style: fontTitle04Bold(),
                      ),
                    ),
                    const VerticalSpace(5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.communityPoints.tr(),
                            style: fontCompactSm(color: fore2),
                          ),
                          Text(
                            "${formatNumberWithCommas('${nft.totalPoints}')} P",
                            style: fontCompactLgBold(),
                          ),
                        ],
                      ),
                    ),
                    const VerticalSpace(5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.communityRanking.tr(),
                            style: fontCompactSm(color: fore2),
                          ),
                          Text(
                            "${nft.communityRank}위",
                            style: fontCompactLgBold(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isLastItem
                ? const SizedBox(height: 20)
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: fore5),
                  )
          ],
        ),
      ),
    );
  }

  Stack buildImageWidget() {
    return Stack(
      children: [
        nft.imageUrl == ""
            ? CustomImageView(
                imagePath: "assets/images/place_holder_card.png",
                width: 90,
                height: 120,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
              )
            : CustomImageView(
                url: nft.imageUrl,
                width: 90,
                height: 120,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
              ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 4),
          child: DefaultImage(
            path: "assets/chain-logos/ethereum_chain.svg",
            width: 14,
            height: 14,
          ),
        ),
        Positioned(
          bottom: 10,
          left: 5,
          child: Container(
            decoration: BoxDecoration(
              color: black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "${nft.totalPoints}${LocaleKeys.people.tr()}",
                style: fontCompactXs(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
