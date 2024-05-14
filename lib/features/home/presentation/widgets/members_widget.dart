import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/home_member_item_widget.dart';

class MemberWidget extends StatefulWidget {
  const MemberWidget({super.key});

  @override
  State<MemberWidget> createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(20),
        Row(
          children: [
            Text("포인트 랭킹", style: fontTitle06Medium()),

            // ListView.builder(
            //   shrinkWrap: true,
            //   itemCount: 5,
            //   itemBuilder: (context, index) {
            //     return

            //     HomeMemberItemWidget(
            //       nftPointsEntity: const NftPointsEntity(
            //         id: "0",
            //         name: "name",
            //         imageUrl: "",
            //         tokenAddress: "",
            //         totalPoints: 3,
            //       ),
            //       isLastItem: false,
            //       onTap: () {
            //         //
            //       },
            //     );
            //   },
            // ),
          ],
        ),
        const VerticalSpace(20),
        HomeMemberItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
            tokenAddress: "",
            totalPoints: 3,
          ),
          isLastItem: false,
          onTap: () {
            //
          },
        ),
        HomeMemberItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
            tokenAddress: "",
            totalPoints: 3,
          ),
          isLastItem: false,
          onTap: () {
            //
          },
        ),
        HomeMemberItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
            tokenAddress: "",
            totalPoints: 3,
          ),
          isLastItem: false,
          onTap: () {
            //
          },
        ),
        HomeMemberItemWidget(
          nftPointsEntity: const NftPointsEntity(
            id: "0",
            name: "스컬프렌드",
            imageUrl: "",
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
