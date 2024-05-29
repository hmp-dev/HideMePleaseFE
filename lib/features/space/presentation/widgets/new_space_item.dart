import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/space/domain/entities/new_space_entity.dart';
import 'dart:math' as math;

class NewSpaceItem extends StatelessWidget {
  const NewSpaceItem({
    super.key,
    required this.newSpaceEntity,
  });

  final NewSpaceEntity newSpaceEntity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(right: 10, top: 20, left: 20),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: hmpBlue,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  newSpaceEntity.image == ""
                      ? CustomImageView(
                          imagePath: "assets/images/place_holder_card.png",
                          width: 102,
                          height: 136,
                          radius: BorderRadius.circular(2),
                          fit: BoxFit.cover,
                        )
                      : CustomImageView(
                          url: newSpaceEntity.image,
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
                        Text(
                          newSpaceEntity.name,
                          style: fontTitle05Bold(),
                        ),
                        Text(
                          newSpaceEntity.mainBenefitDescription,
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
                              "${newSpaceEntity.hidingCount}명 숨어있어요",
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
          top: 0,
          left: 0,
          child: Transform.rotate(
            angle: -25 * math.pi / 180,
            child: CustomImageView(
              svgPath: "assets/images/badge_new.svg",
              width: 96,
              height: 56,
              radius: BorderRadius.circular(2),
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }
}
