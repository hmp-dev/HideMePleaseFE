import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class HomeMemberItemWidget extends StatelessWidget {
  const HomeMemberItemWidget({
    super.key,
    required this.nftPointsEntity,
    required this.isLastItem,
    this.onTap,
  });

  final NftPointsEntity nftPointsEntity;
  final bool isLastItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text("1", style: fontCompactSmBold()),
                  CustomImageView(
                    svgPath: "assets/icons/ic_atiangle_arrow_up_pink.svg",
                    width: 20,
                    height: 20,
                    radius: BorderRadius.circular(50),
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              const HorizontalSpace(3),
              Stack(
                children: [
                  nftPointsEntity.imageUrl == ""
                      ? CustomImageView(
                          imagePath: "assets/images/place_holder_card.png",
                          width: 36,
                          height: 36,
                          radius: BorderRadius.circular(50),
                          fit: BoxFit.cover,
                        )
                      : CustomImageView(
                          url: nftPointsEntity.imageUrl,
                          width: 36,
                          height: 36,
                          radius: BorderRadius.circular(2),
                          fit: BoxFit.cover,
                        ),
                ],
              ),
              const HorizontalSpace(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nftPointsEntity.name, style: fontCompactLgBold()),
                  const VerticalSpace(5),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "${nftPointsEntity.totalPoints} P",
                    style: fontCompactLgBold(),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: DefaultImage(
                      path: "assets/icons/ic_angle_arrow_right.svg",
                      width: 24,
                      height: 24,
                      color: fore3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isLastItem
              ? const SizedBox(height: 20)
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: fore5),
                )
        ],
      ),
    );
  }
}
