import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_container.dart';
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
    return BlocConsumer<SpaceCubit, SpaceState>(
      bloc: getIt<SpaceCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              FractionallySizedBox(
                heightFactor: 0.45555,
                widthFactor: 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(39, 12, 54, 0.29),
                    image: DecorationImage(
                      image: AssetImage("assets/images/space_screen_bg.png"),
                      fit: BoxFit.fill,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(39, 12, 54, 0.29),
                        Colors.black, // Fade out to transparent
                      ],
                    ),
                  ),
                  child: const GlassContainer(
                    borderRadius: BorderRadius.zero,
                    blur: 20,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTopTitleBar(),
                    buildTopUsedNftsRowWidget(state),
                    buildNewSpaceList(state),
                    buildRecommendedSpaceWidget(state, context),
                    buildTypeWiseSpaceList(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        state.recommendationSpaceList.isEmpty
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
                  const SizedBox(height: 140),
                ],
              ),
      ],
    );
  }

  Column buildNewSpaceList(SpaceState state) {
    // [4.1] Space
    // 2 Introduction to new space
    // Introducing a new space partnered with the HMP app
    // Exposure to the area for one week after onboarding
    // If there is no new space, the area is not exposed
    // 2-1 Title provided in ‘New’ section (Figma Design does not show the title but the New graphic badge only)
    // 2-2 Space name, benefit information
    // Provide space name
    // Benefit notation:
    // If there is a collection you are supporting: The benefit of the collection you are supporting is displayed as a representative, and other benefits are indicated with {{n}} other benefits.
    // If there is no collection being supported: The benefits of the NFT collection that can be purchased quickly are displayed as a representative, and other benefits are indicated as {{n}} other benefits.
    return Column(
      children: [
        state.newSpaceList.isEmpty
            ? const SizedBox.shrink()
            : SizedBox(
                height: 192,
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
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SpaceTopNFTListItem(
                              topUsedNftEntity: state.topUsedNfts[0],
                              score: 1,
                            ),
                            SpaceTopNFTListItem(
                              topUsedNftEntity: state.topUsedNfts[1],
                              score: 2,
                            ),
                            SpaceTopNFTListItem(
                              topUsedNftEntity: state.topUsedNfts[2],
                              score: 3,
                            ),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            // Your main content goes here
            Center(
              child: Text('Main Content'),
            ),
          ],
        ),
      ),
    );
  }
}
