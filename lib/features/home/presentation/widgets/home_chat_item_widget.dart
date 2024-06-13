import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/info_text_tool_tip_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';

class HomeChatItemWidget extends StatelessWidget {
  const HomeChatItemWidget({
    super.key,
    required this.nftPointsEntity,
    required this.isLastItem,
    this.onTap,
  });

  final NftPointsEntity nftPointsEntity;
  final bool isLastItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  nftPointsEntity.imageUrl == ""
                      ? CustomImageView(
                          imagePath: "assets/images/place_holder_card.png",
                          width: 36,
                          height: 36,
                          radius: BorderRadius.circular(50),
                          fit: BoxFit.cover,
                        )
                      : CustomImageView(
                          url: nftPointsEntity.imageUrl,
                          width: 36,
                          height: 36,
                          radius: BorderRadius.circular(2),
                          fit: BoxFit.cover,
                        ),
                ],
              ),
              const HorizontalSpace(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nftPointsEntity.name,
                      style: fontBodyXsBold(color: fore2)),
                  const VerticalSpace(5),
                  InfoTextToolTipWidget(
                    title:
                        "이러다 해골들끼리만 모여서 밥먹겠어요 ㅋㅋ 그래도 좋습니다!! 다들 부담없이 임해주세요 :)",
                    onTap: () {},
                  )
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    "5분전",
                    style: fontCompact2Xs(color: fore3),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 2, right: 2),
                    height: 3,
                    width: 3,
                    decoration: const BoxDecoration(
                      color: fore3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    "읽지않음",
                    style: fontCompact2Xs(color: fore1),
                  ),
                ],
              ),
            ],
          ),
          isLastItem
              ? const SizedBox(height: 20)
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: fore5),
                )
        ],
      ),
    );
  }
}
