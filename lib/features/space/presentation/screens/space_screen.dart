import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/category_icon_widget.dart';
import 'package:mobile/features/space/presentation/widgets/new_space_item.dart';
import 'package:mobile/features/space/presentation/widgets/space_nft_list_item.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocConsumer<SpaceCubit, SpaceState>(
        bloc: getIt<SpaceCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          return Padding(
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
                        Text("Hide me", style: fontBody2Bold()),
                        const AlarmsIconButton(),
                      ],
                    ),
                  ),
                ),
                state.topUsedNfts.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.highlyVisitedCommunity.tr(),
                            style: fontTitle06Medium(),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: state.topUsedNfts.length,
                              itemBuilder: (context, index) {
                                return SpaceTopNFTListItem(
                                  topUsedNftEntity: state.topUsedNfts[index],
                                  score: index + 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 35),
                state.newSpaceList.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 190,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: state.newSpaceList.length,
                          itemBuilder: (context, index) {
                            return NewSpaceItem(
                              newSpaceEntity: state.newSpaceList[index],
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 35),
                state.spaceList.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          SizedBox(
                            height: 90,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: [
                                CategoryIconWidget(
                                  icon: "assets/icons/ic_category_all.svg",
                                  title: LocaleKeys.entire.tr(),
                                  isSelected: true,
                                ),
                                CategoryIconWidget(
                                  icon:
                                      "assets/icons/ic_category_resturants.svg",
                                  title: LocaleKeys.pub.tr(),
                                  isSelected: false,
                                ),
                                CategoryIconWidget(
                                  icon: "assets/icons/category_3.svg",
                                  title: LocaleKeys.cafe.tr(),
                                  isSelected: false,
                                ),
                                CategoryIconWidget(
                                  icon: "assets/icons/category-5.svg",
                                  title: LocaleKeys.coworking.tr(),
                                  isSelected: false,
                                ),
                                CategoryIconWidget(
                                  icon: "assets/icons/category-6.svg",
                                  title: LocaleKeys.music.tr(),
                                  isSelected: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.spaceList.length,
                            itemBuilder: (context, index) {
                              return SpacePropertyListItem(
                                spaceEntity: state.spaceList[index],
                              );
                            },
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SpacePropertyListItem extends StatelessWidget {
  const SpacePropertyListItem({
    super.key,
    required this.spaceEntity,
  });

  final SpaceEntity spaceEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(right: 20, top: 20, left: 20),
              width: MediaQuery.of(context).size.width * 0.7,
              height: 170,
              child: Column(
                children: [
                  Row(
                    children: [
                      spaceEntity.image == ""
                          ? CustomImageView(
                              imagePath: "assets/images/place_holder_card.png",
                              width: 102,
                              height: 136,
                              radius: BorderRadius.circular(2),
                              fit: BoxFit.cover,
                            )
                          : CustomImageView(
                              url: spaceEntity.image,
                              width: 102,
                              height: 136,
                              radius: BorderRadius.circular(2),
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(width: 15),
                      SizedBox(
                        height: 136,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              spaceEntity.name,
                              style: fontTitle05Bold(),
                            ),
                            const Spacer(),
                            Text(
                              spaceEntity.name,
                              style: fontCompactSm(),
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
                                  "${spaceEntity.hidingCount}명 숨어있어요",
                                  style: fontCompactSm(color: fore2),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 5),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: spaceEntity.hot
                  ? CustomImageView(
                      svgPath: "assets/images/badge_hot.svg",
                      width: 96,
                      height: 56,
                      radius: BorderRadius.circular(2),
                      fit: BoxFit.cover,
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
        const Divider(
          color: fore5,
        )
      ],
    );
  }
}
