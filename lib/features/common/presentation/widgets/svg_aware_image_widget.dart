import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

class SvgAwareImageWidget extends StatelessWidget {
  const SvgAwareImageWidget({
    super.key,
    required this.imageUrl,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageBorderRadius,
  });

  final String imageUrl;
  final double imageHeight;
  final double imageWidth;
  final double imageBorderRadius;

  @override
  Widget build(BuildContext context) {
    // Check if the image URL ends with '.svg'.
    bool isSvg = imageUrl.toLowerCase().endsWith('.svg');

    // Return the appropriate widget based on whether the image is an SVG or not.
    return isSvg
        ? ClipRRect(
            borderRadius: BorderRadius.circular(imageBorderRadius),
            child: SvgPicture.network(
              imageUrl,
              height: imageHeight,
              width: imageWidth,
              fit: BoxFit.cover,
            ),
          )
        : CustomImageView(
            url: imageUrl,
            width: imageWidth,
            height: imageHeight,
            radius: BorderRadius.circular(imageBorderRadius),
            fit: BoxFit.cover,
          );
  }
}
