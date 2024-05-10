import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class PointsItemWidget extends StatelessWidget {
  const PointsItemWidget({
    super.key,
    required this.nftPointsEntity,
    required this.isLastItem,
  });

  final NftPointsEntity nftPointsEntity;
  final bool isLastItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Stack(
              children: [
                nftPointsEntity.imageUrl == ""
                    ? CustomImageView(
                        imagePath: "assets/images/place_holder_card.png",
                        width: 48,
                        height: 64,
                        radius: BorderRadius.circular(2),
                        fit: BoxFit.cover,
                      )
                    : CustomImageView(
                        url: nftPointsEntity.imageUrl,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nftPointsEntity.name, style: fontCompactSm(color: fore2)),
                const VerticalSpace(5),
                Text(
                  "${nftPointsEntity.totalPoints} P",
                  style: fontCompactLgBold(),
                ),
              ],
            ),
            const Spacer(),
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
        isLastItem
            ? const SizedBox(height: 20)
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: fore5),
              )
      ],
    );
  }
}
