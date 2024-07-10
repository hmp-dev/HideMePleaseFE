import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/svg_aware_image_widget.dart';
// import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NFTCardWidgetParentLocal extends StatelessWidget {
  const NFTCardWidgetParentLocal({
    super.key,
    required this.imagePath,
    required this.topWidget,
    required this.bottomWidget,
    required this.badgeWidget,
  });

  final String imagePath;
  final Widget topWidget;
  final Widget bottomWidget;
  final Widget badgeWidget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 510,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    imagePath == ""
                        ? CustomImageView(
                            imagePath: "assets/images/place_holder_card.png",
                            width: 326,
                            height: 486,
                            border: Border.all(
                              color: fore4,
                              width: 1,
                            ),
                          )
                        : CustomImageView(
                            svgPath: imagePath,
                            width: 326,
                            height: 486,
                            border: Border.all(color: fore4, width: 1),
                            fit: BoxFit.fitHeight,
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
                              imagePath == ""
                                  ? CustomImageView(
                                      imagePath:
                                          "assets/images/home_card_img.png",
                                      width: 326,
                                      height: 486,
                                      border: Border.all(
                                        color: fore4,
                                        width: 1,
                                      ),
                                    )
                                  : CustomImageView(
                                      svgPath: imagePath,
                                      width: 326,
                                      height: 486,
                                      border:
                                          Border.all(color: fore4, width: 1),
                                      fit: BoxFit.fitHeight,
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
                                child: SvgAwareImageWidget(
                                  imageUrl: imagePath,
                                  imageWidth: 316,
                                  imageHeight: 476,
                                  imageBorderRadius: 2,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    topWidget,
                    const Spacer(),
                    bottomWidget,
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: badgeWidget,
          )
        ],
      ),
    );
  }
}
