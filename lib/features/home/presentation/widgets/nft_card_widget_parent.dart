import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NFTCardWidgetParent extends StatelessWidget {
  const NFTCardWidgetParent({
    super.key,
    required this.imagePath,
    required this.topWidget,
    required this.bottomWidget,
    required this.index,
  });

  final String imagePath;
  final Widget topWidget;
  final Widget bottomWidget;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              imagePath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      width: 326,
                      height: 486,
                    )
                  : DefaultImage(
                      path: "assets/images/home_card_img.png",
                      width: 326,
                      height: 486,
                    ),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5),
                  BlendMode.dstATop,
                ),
                child: Container(
                  width: 326,
                  height: 486,
                  color: Colors.white,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 322,
                  height: 482,
                  color: bg1,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        imagePath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
                                width: 318,
                                height: 478,
                              )
                            : DefaultImage(
                                path: "assets/images/home_card_img.png",
                                width: 318,
                                height: 478,
                              ),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.5),
                            BlendMode.dstATop,
                          ),
                          child: Container(
                            width: 318,
                            height: 478,
                            color: Colors.white,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: imagePath.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imagePath,
                                  width: 316,
                                  height: 476,
                                )
                              : DefaultImage(
                                  path: "assets/images/home_card_img.png",
                                  width: 316,
                                  height: 476,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 486,
          width: 326,
          child: Column(
            children: [
              topWidget,
              const Spacer(),
              bottomWidget,
            ],
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: index == 0
              ? CustomImageView(
                  imagePath: "assets/images/free-graphic-text.png",
                )
              : const SizedBox.shrink(),
        )
      ],
    );
  }
}
