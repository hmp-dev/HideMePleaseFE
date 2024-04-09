import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/rounder_button_small.dart';
import 'package:mobile/features/community/presentation/screens/temp_data_community_cards.dart';
import 'package:mobile/features/community/presentation/widgets/nft_community_card_widget.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 75,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Chat me", style: fontB(28)),
                    DefaultImage(path: "assets/icons/ic_notification.svg"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "무료 NFT 받고\n커뮤니티에 참여해보세요",
                      style: fontM(20, lineHeight: 1.4),
                    ),
                    const SizedBox(height: 20),
                    RoundedButtonSmall(
                      title: "지갑연결하기",
                      onTap: () {},
                    ),
                  ],
                ),
                Container(
                  height: 120,
                  width: 120,
                  color: const Color(0xFF55080A),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "전체 커뮤니티",
                      style: fontM(16, lineHeight: 1.4),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "102",
                      style: fontM(16,
                          lineHeight: 1.4, color: fore2White70percent),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "포인트 순",
                      style: fontR(14,
                          lineHeight: 1.4, color: fore2White70percent),
                    ),
                    const SizedBox(width: 5),
                    DefaultImage(
                      path: "assets/icons/ic_arrow_down.svg",
                      width: 14,
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.center,
                children: List.generate(
                  communityNFTItemList.length,
                  (index) {
                    return NftCommunityCardWidget(
                      title: communityNFTItemList[index].title,
                      imagePath: communityNFTItemList[index].imagePath,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
