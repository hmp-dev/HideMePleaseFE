import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/dashed_divider.dart';

class BenefitTitleWidget extends StatelessWidget {
  const BenefitTitleWidget({
    super.key,
    required this.nftBenefitEntity,
  });

  final BenefitEntity nftBenefitEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              children: [
                nftBenefitEntity.spaceImage == ""
                    ? CustomImageView(
                        imagePath: "assets/images/place_holder_card.png",
                        width: 48,
                        height: 64,
                        radius: BorderRadius.circular(2),
                        fit: BoxFit.cover,
                      )
                    : CustomImageView(
                        url: nftBenefitEntity.spaceImage,
                        width: 48,
                        height: 64,
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
              ],
            ),
            const HorizontalSpace(20),
            Text(nftBenefitEntity.spaceName, style: fontTitle05Bold()),
          ],
        ),
        const VerticalSpace(20),
        const DashedDivider(),
      ],
    );
  }
}
