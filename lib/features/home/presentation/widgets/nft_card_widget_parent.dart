import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NFTCardWidgetParent extends StatelessWidget {
  const NFTCardWidgetParent(
      {super.key, required this.imagePath, required this.child});

  final String imagePath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DefaultImage(
                path: imagePath,
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
                        DefaultImage(
                          path: imagePath,
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
                          child: DefaultImage(
                            path: imagePath,
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
        child,
      ],
    );
  }
}
