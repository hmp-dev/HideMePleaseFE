import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_available_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_unavailable_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_used_text.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen_with_space.dart';

class SpaceBenefitItemWidget extends StatelessWidget {
  const SpaceBenefitItemWidget({
    super.key,
    required this.benefitEntity,
    required this.spaceDetailEntity,
    this.isShowImage = true,
  });

  final BenefitEntity benefitEntity;
  final SpaceDetailEntity spaceDetailEntity;
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
                  url: benefitEntity.spaceImage,
                  width: 54,
                  height: 54,
                  radius: BorderRadius.circular(2),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    benefitEntity.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fontCompactMdMedium(),
                  ),
                ),
                const VerticalSpace(5),
                Text(benefitEntity.nftCollectionName,
                    style: fontCompactSm(color: fore3)),
              ],
            ),
            const Spacer(),
            getKoreanTranslation(
                context, benefitEntity.state, spaceDetailEntity),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: fore5),
        )
      ],
    );
  }

  Widget getKoreanTranslation(
      BuildContext context, String state, SpaceDetailEntity space) {
    switch (state) {
      case 'available':
        return GestureDetector(
          onTap: () {
            final user = getIt<EnableLocationCubit>().state;

            // if locationState (user Current Location is same as spaceDetailEntity latitude)

            bool isMatchedSpaceFound = isUserInSpace(
                user.latitude, user.longitude, space.latitude, space.longitude);

            RedeemBenefitScreenWithSpace.push(
              context,
              space: spaceDetailEntity,
              selectedBenefitEntity: benefitEntity,
              isMatchedSpaceFound: isMatchedSpaceFound,
            );
          },
          child: const BenefitAvailableText(),
        );
      case 'unavailable':
        return const BenefitUnavailableText();
      case 'used':
        return const BenefitUsedText();
      default:
        return const SizedBox.shrink();
    }
  }
}
