import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_available_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_unavailable_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_used_text.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/presentation/screens/benefit_redeem_initiate_widget.dart';

class HomeBenefitItemWidget extends StatelessWidget {
  const HomeBenefitItemWidget({
    super.key,
    required this.benefitEntity,
    this.isShowImage = true,
  });

  final BenefitEntity benefitEntity;
  final bool isShowImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BenefitRedeemInitiateWidget(
          tokenAddress: benefitEntity.tokenAddress,
          selectedBenefitEntity: benefitEntity,
          onAlertCancel: () {
            Navigator.pop(context);
          },
          childWidget: Row(
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
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      benefitEntity.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: fontCompactMdMedium(),
                    ),
                  ),
                  const VerticalSpace(5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      benefitEntity.spaceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: fontCompactSm(color: fore3),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              getKoreanTranslation(context, benefitEntity.state)
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: fore5),
        )
      ],
    );
  }

  Widget getKoreanTranslation(BuildContext context, String state) {
    switch (state) {
      case 'available':
        return const BenefitAvailableText();

      case 'unavailable':
        return const BenefitUnavailableText();
      case 'used':
        return const BenefitUsedText();
      default:
        return const BenefitUnavailableText();
    }
  }
}
