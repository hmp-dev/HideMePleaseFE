import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/rounder_button_small.dart';

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
            )
          ],
        ),
      ),
    );
  }
}
