import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_available_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_used_text.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';

class HomeBenefitItemWidget extends StatelessWidget {
  const HomeBenefitItemWidget({
    super.key,
    required this.nftBenefitEntity,
    this.isShowImage = true,
    //required this.nearBySpaceEntity,
  });

  //final NearBySpaceEntity nearBySpaceEntity;
  final BenefitEntity nftBenefitEntity;
  final bool isShowImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (isShowImage)
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: CustomImageView(
                  url: nftBenefitEntity.spaceImage,
                  width: 54,
                  height: 54,
                  radius: BorderRadius.circular(2),
                ),
              ),
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
                : GestureDetector(
                    onTap: () {
                      //  NearBySpaceEntity nearBySpaceEntity,
                      //  String selectedNftTokenAddress,
                      // RedeemBenefitScreen.push(
                      //   context,
                      //   widget.spacesResponseEntity.spaces[0],
                      //   nftBenefitEntity.tokenAddress,
                      // );
                    },
                    child: const BenefitAvailableText(),
                  ),
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
