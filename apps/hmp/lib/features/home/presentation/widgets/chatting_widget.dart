import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/home_chat_item_widget.dart';

class ChattingWidget extends StatefulWidget {
  const ChattingWidget({super.key});

  @override
  State<ChattingWidget> createState() => _ChattingWidgetState();
}

class _ChattingWidgetState extends State<ChattingWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("오픈 채팅방", style: fontTitle06Medium()),
        const HorizontalSpace(10),
        Text("읽지 않은 메세지 12", style: fontCompactXs(color: fore3)),
        const VerticalSpace(40),
        HomeChatItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
            videoUrl: "",
            tokenAddress: "",
            totalPoints: 3,
          ),
          isLastItem: false,
          onTap: () {
            //
          },
        ),
        HomeChatItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
            videoUrl: "",
            tokenAddress: "",
            totalPoints: 3,
          ),
          isLastItem: false,
          onTap: () {
            //
          },
        ),
        HomeChatItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
            videoUrl: "",
            tokenAddress: "",
            totalPoints: 3,
          ),
          isLastItem: false,
          onTap: () {
            //
          },
        ),
      ],
    );
  }
}
