import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceSelectItem extends StatelessWidget {
  const SpaceSelectItem({
    super.key,
    required this.spaceEntity,
    required this.onTap,
  });

  final NearBySpaceEntity spaceEntity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        spaceEntity.image == ""
                            ? CustomImageView(
                                imagePath:
                                    "assets/images/place_holder_card.png",
                                width: 102,
                                height: 102,
                                radius: BorderRadius.circular(2),
                                fit: BoxFit.cover,
                              )
                            : getImageWidget(spaceEntity.image),
                        const SizedBox(width: 15),
                        SizedBox(
                          height: 102,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      spaceEntity.name,
                                      style: fontTitle05Bold(),
                                    ),
                                    spaceEntity.distance < 11
                                        ? Container(
                                            padding: const EdgeInsets.only(
                                                left: 3, right: 3),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: fore2),
                                            child: Text(
                                              LocaleKeys.currentLocation.tr(),
                                              style: fontBody2XsBold(),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    //
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  spaceEntity.address,
                                  overflow: TextOverflow.ellipsis,
                                  style: fontCompactSm(),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Text(""),
                                    Text(
                                      "${spaceEntity.distance} m",
                                      style: fontTitle05Bold(),
                                    ),
                                    //
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(
            color: fore5,
          )
        ],
      ),
    );
  }

  Widget getImageWidget(String imagePath) {
    return isSvg(imagePath)
        ? SvgPicture.network(
            imagePath,
            height: 102,
            width: 102,
          )
        : CustomImageView(
            url: spaceEntity.image,
            width: 102,
            height: 102,
            radius: BorderRadius.circular(2),
            fit: BoxFit.cover,
          );
  }

  bool isSvg(String url) {
    return url.toLowerCase().endsWith('.svg');
  }
}
