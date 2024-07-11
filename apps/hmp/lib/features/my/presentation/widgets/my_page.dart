// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/my/presentation/widgets/nft_medium_card_widget.dart';
import 'package:mobile/features/my/presentation/widgets/temp_data.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage>
    with AutomaticKeepAliveClientMixin<MyPage> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "총 12개",
                        style: fontTitle07Medium(),
                      ),
                      Text(
                        "04/15 18:00 기준",
                        style: fontCompactSm(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 29),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Based Gods",
                        style: fontM(18),
                      ),
                      const SizedBox(height: 13),
                      _buildOne(context),
                      const SizedBox(height: 27),
                      Text(
                        "Ready to hide",
                        style: fontM(18),
                      ),
                      const SizedBox(height: 11),
                      _buildReadyToHide(context),
                      const SizedBox(height: 25),
                      Text(
                        "Outcasts",
                        style: fontM(18),
                      ),
                      const SizedBox(height: 13),
                      _buildOutCastList(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildOne(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.only(right: 108),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            width: 4,
          );
        },
        itemCount: nftItemsBasedGod.length,
        itemBuilder: (context, index) {
          return NftMediumCardWidget(
            title: nftItemsBasedGod[index].title,
            imagePath: nftItemsBasedGod[index].imagePath,
          );
        },
      ),
    );
  }

  Widget _buildReadyToHide(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.only(right: 108),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            width: 4,
          );
        },
        itemCount: nftItemsReadyToHide.length,
        itemBuilder: (context, index) {
          return NftMediumCardWidget(
            title: nftItemsReadyToHide[index].title,
            imagePath: nftItemsReadyToHide[index].imagePath,
          );
        },
      ),
    );
  }

  Widget _buildOutCastList(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.only(right: 108),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(
            width: 4,
          );
        },
        itemCount: nftItemsOutCast.length,
        itemBuilder: (context, index) {
          return NftMediumCardWidget(
            title: nftItemsOutCast[index].title,
            imagePath: nftItemsOutCast[index].imagePath,
          );
        },
      ),
    );
  }

  /// Section Widget
}
