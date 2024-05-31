import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/space/presentation/widgets/category_icon_widget.dart';
import 'package:mobile/features/space/presentation/widgets/space_nft_list_item.dart';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
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
                    Text("Hide me", style: fontB(28)),
                    DefaultImage(path: "assets/icons/ic_notification.svg"),
                  ],
                ),
              ),
            ),
            Text("공간 방문 TOP3", style: fontM(16)),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SpaceNFTListItem(
                  image: "assets/images/nft-img-2.png",
                  score: '2',
                  points: "2,215 P",
                  title: "Rosentica: Starfall Travelers",
                ),
                SpaceNFTListItem(
                  image: "assets/images/nft-img-1.png",
                  score: '1',
                  points: "2,980 P",
                  title: "M.E.F. MINT",
                ),
                SpaceNFTListItem(
                  image: "assets/images/nft-img-3.png",
                  score: '3',
                  points: "1,895 P",
                  title: "Outcasts",
                ),
              ],
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 30),
              color: const Color(0xFF55080A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TBD",
                      style: fontB(24),
                    ),
                    Text(
                      "나의 혜택",
                      style: fontR(14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryIconWidget(
                    icon: "assets/icons/ic_category_all.svg",
                    title: "전체",
                    isSelected: true,
                  ),
                  CategoryIconWidget(
                    icon: "assets/icons/ic_category_resturants.svg",
                    title: "주점",
                    isSelected: false,
                  ),
                  CategoryIconWidget(
                    icon: "assets/icons/category_3.svg",
                    title: "카페",
                    isSelected: false,
                  ),
                  CategoryIconWidget(
                    icon: "assets/icons/category-5.svg",
                    title: "코워킹",
                    isSelected: false,
                  ),
                  CategoryIconWidget(
                    icon: "assets/icons/category-6.svg",
                    title: "음악",
                    isSelected: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const SpacePropertyListItem(),
            const SpacePropertyListItem(),
            const SpacePropertyListItem(),
            const SpacePropertyListItem(),
          ],
        ),
      ),
    );
  }
}

class SpacePropertyListItem extends StatelessWidget {
  const SpacePropertyListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              DefaultImage(
                path: "assets/images/thumbnail.png",
                width: 90,
                height: 120,
              ),
              const SizedBox(width: 15),
              SizedBox(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      "에헤야 서울",
                      style: fontB(18),
                    ),
                    const Spacer(),
                    Text(
                      "매일 한잔의 커피나 티 음료를 40% 할인",
                      style: fontR(14),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        DefaultImage(
                          path: "assets/icons/eyes-icon.svg",
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "3명 숨어있어요",
                          style: fontR(14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Divider(
            color: black200,
          )
        ],
      ),
    );
  }
}
