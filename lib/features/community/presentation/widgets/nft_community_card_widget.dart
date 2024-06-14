import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NftCommunityCardWidget extends StatelessWidget {
  const NftCommunityCardWidget(
      {super.key,
      required this.onTap,
      required this.title,
      required this.imagePath,
      required this.networkLogo,
      required this.timeAgo,
      required this.rank,
      required this.people});

  final VoidCallback onTap;
  final String title;
  final String imagePath;
  final String networkLogo;
  final String timeAgo;
  final String rank;
  final String people;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width * 0.40,
      height: 250,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (imagePath.isEmpty)
              CustomImageView(
                radius: BorderRadius.circular(4.0),
                width: 60,
                height: 60,
                fit: BoxFit.fitHeight,
                svgPath: "assets/images/hmp_eyes_up.svg",
              )
            else
              CustomImageView(
                radius: BorderRadius.circular(4.0),
                url: imagePath,
                width: screenSize.width * 0.40,
                height: 250,
                fit: BoxFit.fitHeight,
              ),
            Container(
              width: screenSize.width * 0.40,
              height: 250,
              decoration: BoxDecoration(
                color: bg3.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            SizedBox(
              width: screenSize.width * 0.40,
              height: 250,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomImageView(
                      svgPath: networkLogo,
                      height: 24.0,
                      width: 24.0,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontB(18, lineHeight: 1.4),
                    ),
                    const SizedBox(height: 8.0),
                    RoundedButtonSmallWithOpacity(
                        title: people, // "120명"
                        onTap: () {}),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RectangleButtonSmall(title: rank, onTap: () {}),
                        Text(
                          timeAgo, // "3초 전",
                          style: fontR(12, color: whiteWithOpacityOne),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundedButtonSmallWithOpacity extends StatelessWidget {
  const RoundedButtonSmallWithOpacity({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 20,
        width: 46,
        child: Stack(
          children: [
            Opacity(
              opacity: 0.5,
              child: Container(
                height: 20,
                width: 46,
                decoration: const BoxDecoration(
                  color: black900,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: fontR(12, lineHeight: 1.3),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RectangleButtonSmall extends StatelessWidget {
  const RectangleButtonSmall({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 20,
        child: Stack(
          children: [
            Container(
              height: 20,
              width: 49,
              decoration: const BoxDecoration(
                color: black900,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: DefaultImage(
                      path: "assets/icons/ic_triangle_arrow_up.svg",
                      width: 12,
                      height: 12,
                      color: pink,
                      boxFit: BoxFit.fitHeight,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: fontR(12, lineHeight: 1.3),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
