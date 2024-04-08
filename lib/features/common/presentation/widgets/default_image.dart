import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? boxFit;
  final Alignment? alignment;

  DefaultImage({
    super.key,
    required this.path,
    this.width = 24,
    this.height = 24,
    this.color,
    this.boxFit,
    this.alignment,
  }) : assert(path.contains(".svg") || path.contains(".png"));

  @override
  Widget build(BuildContext context) {
    return path.contains(".svg")
        ? Container(
            color: Colors.white.withOpacity(0),
            child: SvgPicture.asset(
              path,
              fit: boxFit ?? BoxFit.contain,
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
              width: width,
              height: height,
            ),
          )
        : Container(
            color: Colors.transparent,
            width: width,
            height: height,
            alignment: alignment,
            child: Image.asset(
              path,
              fit: boxFit ?? BoxFit.contain,
              color: color,
            ),
          );
  }
}
