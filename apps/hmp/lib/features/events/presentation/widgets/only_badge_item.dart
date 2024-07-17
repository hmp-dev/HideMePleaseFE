import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class OnlyBadgeItem extends StatelessWidget {
  const OnlyBadgeItem({
    super.key,
    required this.imgPath,
  });

  final String imgPath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(right: 5, top: 5, left: 5),
          width: MediaQuery.of(context).size.width * 0.92,
          height: 96,
          decoration: BoxDecoration(
            color: fore5,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: fore5,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Stack(
                children: [
                  CustomImageView(
                    imagePath: imgPath,
                    width: 48,
                    height: 64,
                    radius: BorderRadius.circular(2),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 3.0,
                    top: 3.0,
                    child: DefaultImage(
                      path: "assets/chain-logos/ethereum_chain.svg",
                      height: 14,
                      width: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Text(
                      "DADAZ",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontTitle05Bold(),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Text(
                      "홀더들만 참여할 수 있어요",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontCompactLg(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: CustomImageView(
            imagePath: "assets/images/only_badge.png",
          ),
        )
      ],
    );
  }
}
