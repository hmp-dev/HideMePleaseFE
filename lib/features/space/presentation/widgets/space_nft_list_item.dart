import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class SpaceNFTListItem extends StatelessWidget {
  const SpaceNFTListItem({
    super.key,
    required this.image,
    required this.score,
    required this.title,
    required this.points,
  });

  final String image;
  final String score;
  final String title;
  final String points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: DefaultImage(
                  path: image,
                  width: score == '1' ? 90 : 84,
                  height: score == '1' ? 120 : 112,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    DefaultImage(
                      path: "assets/images/ranking_badge.svg",
                      width: score == '1' ? 36 : 32,
                      height: score == '1' ? 36 : 32,
                    ),
                    Center(child: Text(score, style: fontB(14))),
                  ],
                ),
              )
            ],
          ),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: fontR(14),
          ),
          Text(
            points,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: fontR(14),
          ),
        ],
      ),
    );
  }
}
