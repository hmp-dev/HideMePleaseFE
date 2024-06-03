// // ignore_for_file: must_be_immutable

// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class CustomImageView extends StatelessWidget {
//   ///[url] is required parameter for fetching network image
//   String? url;

//   ///[imagePath] is required parameter for showing png,jpg,etc image
//   String? imagePath;

//   ///[svgPath] is required parameter for showing svg image
//   String? svgPath;

//   ///[file] is required parameter for fetching image file
//   File? file;

//   double? height;
//   double? width;
//   Color? color;
//   BoxFit? fit;
//   final String placeHolder;
//   Alignment? alignment;
//   VoidCallback? onTap;
//   EdgeInsetsGeometry? margin;
//   BorderRadius? radius;
//   BoxBorder? border;

//   ///a [CustomImageView] it can be used for showing any type of images
//   /// it will shows the placeholder image if image is not found on network image
//   CustomImageView({
//     super.key,
//     this.url,
//     this.imagePath,
//     this.svgPath,
//     this.file,
//     this.height,
//     this.width,
//     this.color,
//     this.fit,
//     this.alignment,
//     this.onTap,
//     this.radius,
//     this.margin,
//     this.border,
//     this.placeHolder = 'assets/images/image_not_found.png',
//   });

//   @override
//   Widget build(BuildContext context) {
//     return alignment != null
//         ? Align(
//             alignment: alignment!,
//             child: _buildWidget(),
//           )
//         : _buildWidget();
//   }

//   Widget _buildWidget() {
//     return Padding(
//       padding: margin ?? EdgeInsets.zero,
//       child: InkWell(
//         onTap: onTap,
//         child: _buildCircleImage(),
//       ),
//     );
//   }

//   ///build the image with border radius
//   _buildCircleImage() {
//     if (radius != null) {
//       return ClipRRect(
//         borderRadius: radius ?? BorderRadius.circular(0),
//         child: _buildImageWithBorder(),
//       );
//     } else {
//       return _buildImageWithBorder();
//     }
//   }

//   ///build the image with border and border radius style
//   _buildImageWithBorder() {
//     if (border != null) {
//       return Container(
//         decoration: BoxDecoration(
//           border: border,
//           borderRadius: radius,
//         ),
//         child: _buildImageView(),
//       );
//     } else {
//       return _buildImageView();
//     }
//   }

//   Widget _buildImageView() {
//     if (svgPath != null && svgPath!.isNotEmpty) {
//       return SizedBox(
//         height: height,
//         width: width,
//         child: SvgPicture.asset(
//           svgPath!,
//           height: height,
//           width: width,
//           fit: fit ?? BoxFit.contain,
//           color: color,
//         ),
//       );
//     } else if (file != null && file!.path.isNotEmpty) {
//       return Image.file(
//         file!,
//         height: height,
//         width: width,
//         fit: fit ?? BoxFit.cover,
//         color: color,
//       );
//     } else if (url != null && url!.isNotEmpty) {
//       return CachedNetworkImage(
//         height: height,
//         width: width,
//         fit: fit,
//         imageUrl: url!,
//         color: color,
//         placeholder: (context, url) => const Center(
//           child: SizedBox(
//             height: 24.0,
//             width: 24.0,
//             child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
//           ),
//         ),
//         errorWidget: (context, url, error) => Image.asset(
//           placeHolder,
//           height: height,
//           width: width,
//           fit: fit ?? BoxFit.cover,
//         ),
//       );
//     } else if (imagePath != null && imagePath!.isNotEmpty) {
//       return Image.asset(
//         imagePath!,
//         height: height,
//         width: width,
//         fit: fit ?? BoxFit.cover,
//         color: color,
//       );
//     }
//     return const SizedBox();
//   }
// }

// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomImageView extends StatelessWidget {
  /// [url] is a required parameter for fetching a network image
  String? url;

  /// [imagePath] is a required parameter for showing png, jpg, etc. image
  String? imagePath;

  /// [svgPath] is a required parameter for showing SVG image
  String? svgPath;

  /// [file] is a required parameter for fetching image file
  File? file;

  double? height;
  double? width;
  Color? color;
  BoxFit? fit;
  final String placeHolder;
  Alignment? alignment;
  VoidCallback? onTap;
  EdgeInsetsGeometry? margin;
  BorderRadius? radius;
  BoxBorder? border;

  /// A [CustomImageView] can be used for showing any type of images.
  /// It will show the placeholder image if the image is not found on the network.
  CustomImageView({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder = 'assets/images/image_not_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildWidget(),
          )
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: _buildCircleImage(),
      ),
    );
  }

  /// Build the image with border radius
  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.circular(0),
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  /// Build the image with border and border radius style
  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    if (url != null && url!.isNotEmpty) {
      if (url!.toLowerCase().endsWith('.svg')) {
        return _buildSvgImageFromNetwork(url!);
      } else {
        return _buildNetworkImage(url!);
      }
    } else if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: SvgPicture.asset(
          svgPath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          color: color,
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.asset(
        imagePath!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
      );
    }
    return Image.asset(
      placeHolder,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
    );
  }

  Widget _buildSvgImageFromNetwork(String url) {
    return SizedBox(
      height: height,
      width: width,
      child: SvgPicture.network(
        url,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        placeholderBuilder: (BuildContext context) => const Center(
          child: SizedBox(
            height: 24.0,
            width: 24.0,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      height: height,
      width: width,
      fit: fit,
      imageUrl: url,
      color: color,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          height: 24.0,
          width: 24.0,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        placeHolder,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}
