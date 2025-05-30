import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

// ignore: must_be_immutable
class NftCommunityCardWidget extends StatelessWidget {
  const NftCommunityCardWidget(
      {super.key, required this.title, required this.imagePath});

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width * 0.40,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DefaultImage(
            path: imagePath,
            width: screenSize.width * 0.40,
            height: 250,
            boxFit: BoxFit.fitHeight,
          ),
          Container(
            width: screenSize.width * 0.40,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.5, 0),
                end: const Alignment(0.5, 1),
                colors: [
                  black900.withOpacity(0),
                  black900.withOpacity(0.6),
                ],
              ),
            ),
          ),
          SizedBox(
            width: screenSize.width * 0.40,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fontB(18, lineHeight: 1.4),
                  ),
                  RoundedButtonSmallWithOpacity(title: "120명", onTap: () {}),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RectangleButtonSmall(title: "12위", onTap: () {}),
                      Text(
                        "3초 전",
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
        width: 46,
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
