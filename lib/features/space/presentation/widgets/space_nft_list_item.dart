import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/top_used_nft_entity.dart';

class SpaceTopNFTListItem extends StatelessWidget {
  const SpaceTopNFTListItem({
    super.key,
    required this.topUsedNftEntity,
    required this.score,
  });

  final TopUsedNftEntity topUsedNftEntity;
  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidth(score),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getImageWidget(score),
          const VerticalSpace(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text('$score', style: fontCompactLgBold()),
                  topUsedNftEntity.pointFluctuation > 0
                      ? CustomImageView(
                          svgPath: "assets/icons/ic_arrow_up_pink.svg",
                          width: 10,
                          height: 10,
                        )
                      : CustomImageView(
                          svgPath: "assets/icons/ic_arrow_blue_down.svg",
                          width: 10,
                          height: 10,
                        )
                ],
              ),
              const HorizontalSpace(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: getWidth(score) - 20,
                    child: Text(
                      topUsedNftEntity.name,
                      overflow: TextOverflow.ellipsis,
                      style: fontCompactMd(),
                    ),
                  ),
                  Text("${topUsedNftEntity.totalPoints} P",
                      style: fontCompactSmBold()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  getImageWidget(score) {
    if (score == 1) {
      return buildImageWidget(117, 156);
    }

    if (score == 2) {
      return buildImageWidget(108, 143);
    }

    if (score == 3) {
      return buildImageWidget(98, 130);
    }
  }

  double getWidth(score) {
    if (score == 1) {
      return 117.0;
    } else if (score == 2) {
      return 108.0;
    } else {
      return 98.0;
    }
  }

  Stack buildImageWidget(
    double width,
    double height,
  ) {
    return Stack(
      children: [
        topUsedNftEntity.collectionLogo == ""
            ? CustomImageView(
                imagePath: "assets/images/place_holder_card.png",
                width: width,
                height: height,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
              )
            : CustomImageView(
                url: topUsedNftEntity.collectionLogo,
                width: width,
                height: height,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
              ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 4),
          child: DefaultImage(
            path:
                "assets/chain-logos/${topUsedNftEntity.chain.toLowerCase()}_chain.svg",
            width: 14,
            height: 14,
          ),
        ),
      ],
    );
  }
}
