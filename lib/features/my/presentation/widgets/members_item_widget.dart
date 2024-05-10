import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class MembersItemWidget extends StatelessWidget {
  const MembersItemWidget({
    super.key,
    required this.imagePath,
    required this.isLastItem,
    required this.communityPoints,
    required this.communityRanking,
    required this.usersCount,
    required this.name,
  });

  final String imagePath;
  final String name;
  final String communityPoints;
  final String communityRanking;
  final int usersCount;
  final bool isLastItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              buildImageWidget(),
              const HorizontalSpace(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: fontTitle04Bold()),
                  const VerticalSpace(5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "커뮤니티 포인트",
                          style: fontCompactSm(color: fore2),
                        ),
                        Text(
                          communityPoints,
                          style: fontCompactLgBold(),
                        ),
                      ],
                    ),
                  ),
                  const VerticalSpace(5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "커뮤니티 랭킹",
                          style: fontCompactSm(color: fore2),
                        ),
                        Text(
                          communityRanking,
                          style: fontCompactLgBold(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          isLastItem
              ? const SizedBox(height: 20)
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: fore5),
                )
        ],
      ),
    );
  }

  Stack buildImageWidget() {
    return Stack(
      children: [
        imagePath == ""
            ? CustomImageView(
                imagePath: "assets/images/place_holder_card.png",
                width: 90,
                height: 120,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
              )
            : CustomImageView(
                url: imagePath,
                width: 90,
                height: 120,
                radius: BorderRadius.circular(2),
                fit: BoxFit.cover,
              ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 4),
          child: DefaultImage(
            path: "assets/chain-logos/ethereum_chain.svg",
            width: 14,
            height: 14,
          ),
        ),
        Positioned(
          bottom: 10,
          left: 5,
          child: Container(
            decoration: BoxDecoration(
              color: black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "120명",
                style: fontCompactXs(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
