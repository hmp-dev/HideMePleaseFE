import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NFTCardWidgetParentLocal extends StatelessWidget {
  const NFTCardWidgetParentLocal({
    super.key,
    required this.imagePath,
    required this.topWidget,
    required this.bottomWidget,
  });

  final String imagePath;
  final Widget topWidget;
  final Widget bottomWidget;

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
      ],
    );
  }
}
