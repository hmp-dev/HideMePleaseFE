import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_benefit_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_available_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_used_text.dart';

class HomeBenefitItemWidget extends StatelessWidget {
  const HomeBenefitItemWidget({
    super.key,
    required this.nftBenefitEntity,
  });

  final NftBenefitEntity nftBenefitEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CustomImageView(
              url: nftBenefitEntity.spaceImage,
              width: 54,
              height: 54,
              radius: BorderRadius.circular(2),
            ),
            const HorizontalSpace(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nftBenefitEntity.description,
                    style: fontCompactMdMedium()),
                const VerticalSpace(5),
                Text(nftBenefitEntity.spaceName,
                    style: fontCompactSm(color: fore3)),
              ],
            ),
            const Spacer(),
            nftBenefitEntity.used
                ? const BenefitUsedText()
                : const BenefitAvailableText(),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: fore5),
        )
      ],
    );
  }
}
