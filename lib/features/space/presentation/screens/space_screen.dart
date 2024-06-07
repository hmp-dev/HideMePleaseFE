import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:mobile/features/space/presentation/widgets/category_icon_widget.dart';
import 'package:mobile/features/space/presentation/widgets/new_space_item.dart';
import 'package:mobile/features/space/presentation/widgets/space_list_item.dart';
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopTitleBar(),
              buildTopUsedNftsRowWidget(state),
              buildNewSpaceList(state),
              buildRecommendedSpaceWidget(state, context),
              buildTypeWiseSpaceList(state),
            ],
          );
        },
      ),
    );
  }

  Widget buildRecommendedSpaceWidget(SpaceState state, BuildContext context) {
    return GestureDetector(
      onTap: () {
        getIt<SpaceCubit>().onGetSpaceDetail(
            spaceId: state.recommendationSpaceList[0].spaceId);
        SpaceDetailScreen.push(context);
      },
      child: Column(
        children: [
          state.recommendationSpaceList.isEmpty
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    CustomImageView(
                      imagePath: "assets/images/recommendation-bg.gif",
                      width: MediaQuery.of(context).size.width,
                      height: 160,
                      radius: BorderRadius.circular(2),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 160,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.recommendationSpaceList[0].spaceName,
                              style: fontBodyLgMedium(),
                            ),
                            Text(
                              "${state.recommendationSpaceList[0].users}${LocaleKeys.peopleRecievedPoints.tr()}",
                              style: fontBodyLgMedium(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Column buildTypeWiseSpaceList(SpaceState state) {
    return Column(
      children: [
        state.isSubmitLoading
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
                          icon: "assets/icons/ic_space_category_entire.svg",
                          title: LocaleKeys.entire.tr(),
                          isSelected:
                              state.spaceCategory == SpaceCategory.ENTIRE,
                          onTap: () {
                            getIt<SpaceCubit>().onGetSpaceListByCategory(
                              category: SpaceCategory.ENTIRE,
                            );
                          },
                        ),
                        CategoryIconWidget(
                          icon: "assets/icons/ic_space_category_pub.svg",
                          title: LocaleKeys.pub.tr(),
                          isSelected: state.spaceCategory == SpaceCategory.PUB,
                          onTap: () {
                            getIt<SpaceCubit>().onGetSpaceListByCategory(
                              category: SpaceCategory.PUB,
                            );
                          },
                        ),
                        CategoryIconWidget(
                          icon: "assets/icons/ic_space_category_cafe.svg",
                          title: LocaleKeys.cafe.tr(),
                          isSelected: state.spaceCategory == SpaceCategory.CAFE,
                          onTap: () {
                            getIt<SpaceCubit>().onGetSpaceListByCategory(
                              category: SpaceCategory.CAFE,
                            );
                          },
                        ),
                        CategoryIconWidget(
                          icon: "assets/icons/ic_space_category_pub.svg",
                          title: LocaleKeys.coworking.tr(),
                          isSelected:
                              state.spaceCategory == SpaceCategory.COWORKING,
                          onTap: () {
                            getIt<SpaceCubit>().onGetSpaceListByCategory(
                              category: SpaceCategory.COWORKING,
                            );
                          },
                        ),
                        CategoryIconWidget(
                          icon: "assets/icons/ic_space_category_music.svg",
                          title: LocaleKeys.music.tr(),
                          isSelected:
                              state.spaceCategory == SpaceCategory.MUSIC,
                          onTap: () {
                            getIt<SpaceCubit>().onGetSpaceListByCategory(
                              category: SpaceCategory.MUSIC,
                            );
                          },
                        ),
                        CategoryIconWidget(
                          icon: "assets/icons/ic_space_category_meal.svg",
                          title: LocaleKeys.meal.tr(),
                          isSelected: state.spaceCategory == SpaceCategory.MEAL,
                          onTap: () {
                            getIt<SpaceCubit>().onGetSpaceListByCategory(
                              category: SpaceCategory.MEAL,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  state.spaceList.isEmpty
                      ? const SizedBox(height: 50)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.spaceList.length,
                          itemBuilder: (context, index) {
                            return SpaceListItem(
                              spaceEntity: state.spaceList[index],
                            );
                          },
                        ),
                ],
              ),
      ],
    );
  }

  Column buildNewSpaceList(SpaceState state) {
    return Column(
      children: [
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
      ],
    );
  }

  Padding buildTopUsedNftsRowWidget(SpaceState state) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20,
        bottom: 30,
      ),
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  Container buildTopTitleBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
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
    );
  }
}
