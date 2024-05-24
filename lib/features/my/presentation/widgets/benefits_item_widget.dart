import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/domain/entities/nft_benefit_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class BenefitItemWidget extends StatelessWidget {
  const BenefitItemWidget({
    super.key,
    required this.nftBenefitEntity,
  });

  final NftBenefitEntity nftBenefitEntity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              CustomImageView(
                url: nftBenefitEntity.spaceImage,
                width: 68,
                height: 68,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
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
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: fore5),
          )
        ],
      ),
    );
  }
}
