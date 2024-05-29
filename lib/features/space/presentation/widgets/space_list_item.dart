import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';

class SpaceListItem extends StatelessWidget {
  const SpaceListItem({
    super.key,
    required this.spaceEntity,
  });

  final SpaceEntity spaceEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(right: 20, top: 20, left: 20),
              width: MediaQuery.of(context).size.width * 0.7,
              height: 170,
              child: Column(
                children: [
                  Row(
                    children: [
                      spaceEntity.image == ""
                          ? CustomImageView(
                              imagePath: "assets/images/place_holder_card.png",
                              width: 102,
                              height: 136,
                              radius: BorderRadius.circular(2),
                              fit: BoxFit.cover,
                            )
                          : CustomImageView(
                              url: spaceEntity.image,
                              width: 102,
                              height: 136,
                              radius: BorderRadius.circular(2),
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(width: 15),
                      SizedBox(
                        height: 136,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 5),
                            spaceEntity.hotPoints > 0
                                ? Row(
                                    children: [
                                      Text(
                                        "이번 주 핫 플레이스",
                                        style: fontCompactSm(color: pink),
                                      ),
                                      const HorizontalSpace(5),
                                      Text(
                                        "${spaceEntity.hotPoints} P",
                                        style: fontCompactSmBold(color: pink),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            //이번 주 핫 플레이스
                            Text(
                              spaceEntity.name,
                              style: fontTitle05Bold(),
                            ),
                            Text(
                              spaceEntity.benefitDescription,
                              style: fontCompactSm(),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                DefaultImage(
                                  path: "assets/icons/eyes-icon.svg",
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${spaceEntity.hidingCount}명 숨어있어요",
                                  style: fontCompactSm(color: fore2),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 5),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              child: spaceEntity.hot
                  ? CustomImageView(
                      svgPath: "assets/images/badge_hot.svg",
                      width: 96,
                      height: 56,
                      radius: BorderRadius.circular(2),
                      fit: BoxFit.cover,
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
        const Divider(
          color: fore5,
        )
      ],
    );
  }
}
