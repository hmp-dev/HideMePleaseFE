import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/space/domain/entities/new_space_entity.dart';
import 'dart:math' as math;

import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class NewSpaceItem extends StatelessWidget {
  const NewSpaceItem({
    super.key,
    required this.newSpaceEntity,
  });

  final NewSpaceEntity newSpaceEntity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getIt<SpaceCubit>()
            .onGetSpaceDetailBySpaceId(spaceId: newSpaceEntity.id);
        SpaceDetailScreen.push(context);
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 10, top: 20, left: 20),
            width: MediaQuery.of(context).size.width * 0.92,
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
                          //[4.1] Space
// 2.2 {{N}} people in hiding
// Default: {{N}} people are hiding
// N people: Counting users who are currently visiting the space and have their location disclosure set to ‘public’.
// If there are 0 or less people, the tag is not exposed.
                          if (newSpaceEntity.hidingCount > 0)
                            Row(
                              children: [
                                DefaultImage(
                                  path: "assets/icons/eyes-icon.svg",
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${newSpaceEntity.hidingCount}${LocaleKeys.peopleAreHiding.tr()}",
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
                child: Lottie.asset(
                  'assets/lottie/new.json',
                )),
          )
        ],
      ),
    );
  }
}
