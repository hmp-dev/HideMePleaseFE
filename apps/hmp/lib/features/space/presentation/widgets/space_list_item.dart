import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/svg_aware_image_widget.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';

class SpaceListItem extends StatelessWidget {
  const SpaceListItem({
    super.key,
    required this.spaceEntity,
  });

  final SpaceEntity spaceEntity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getIt<SpaceCubit>().onGetSpaceDetailBySpaceId(spaceId: spaceEntity.id);
        SpaceDetailScreen.push(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20, top: 14, left: 20),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 150,
                child: Column(
                  children: [
                    Row(
                      children: [
                        spaceEntity.image == ""
                            ? CustomImageView(
                                imagePath:
                                    "assets/images/place_holder_card.png",
                                width: 102,
                                height: 136,
                                radius: BorderRadius.circular(2),
                                fit: BoxFit.cover,
                              )
                            : SvgAwareImageWidget(
                                imageUrl: spaceEntity.image,
                                imageWidth: 102,
                                imageHeight: 136,
                                imageBorderRadius: 2,
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  spaceEntity.name,
                                  style: fontTitle05Bold(),
                                ),
                              ),

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  spaceEntity.benefitDescription,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: fontCompactSm(),
                                ),
                              ),
                              const Spacer(),
                              if (spaceEntity.hidingCount > 0)
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
                top: 0,
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            child: Divider(
              color: fore5,
            ),
          )
        ],
      ),
    );
  }
}
