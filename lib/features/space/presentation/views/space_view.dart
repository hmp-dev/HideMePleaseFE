import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/empty_data_widget.dart';
import 'package:mobile/features/common/presentation/widgets/load_more_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/new_space_entity.dart';
import 'package:mobile/features/space/domain/entities/recommendation_space_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/entities/top_used_nft_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:mobile/features/space/presentation/widgets/category_icon_widget.dart';
import 'package:mobile/features/space/presentation/widgets/new_space_item.dart';
import 'package:mobile/features/space/presentation/widgets/space_list_item.dart';
import 'package:mobile/features/space/presentation/widgets/space_nft_list_item.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceView extends StatefulWidget {
  const SpaceView({
    super.key,
    required this.onRefresh,
    required this.onLoadMore,
    required this.topUsedNfts,
    required this.newSpaceList,
    required this.recommendedSpace,
    required this.spaceList,
    required this.spaceCategory,
    required this.onSpaceByCategoryTap,
    required this.isLoadingMore,
    required this.isAllSpacesLoaded,
  });

  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final List<TopUsedNftEntity> topUsedNfts;
  final List<NewSpaceEntity> newSpaceList;
  final RecommendationSpaceEntity recommendedSpace;
  final List<SpaceEntity> spaceList;
  final SpaceCategory spaceCategory;
  final void Function(SpaceCategory) onSpaceByCategoryTap;
  final bool isLoadingMore;
  final bool isAllSpacesLoaded;

  @override
  State<SpaceView> createState() => _SpaceViewState();
}

class _SpaceViewState extends State<SpaceView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopTitleBar(),
              buildTopUsedNftsRowWidget(widget.topUsedNfts),
              buildNewSpaceList(widget.newSpaceList),
              buildRecommendedSpaceWidget(widget.recommendedSpace, context),
              buildTypeWiseSpaceList(widget.spaceList, widget.spaceCategory),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecommendedSpaceWidget(
      RecommendationSpaceEntity space, BuildContext context) {
    return GestureDetector(
      onTap: () {
        getIt<SpaceCubit>().onGetSpaceDetailBySpaceId(spaceId: space.spaceId);
        SpaceDetailScreen.push(context);
      },
      child: Column(
        children: [
          Stack(
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
                        space.spaceName,
                        style: fontBodyLgMedium(),
                      ),
                      Text(
                        "${space.users}${LocaleKeys.peopleRecievedPoints.tr()}",
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

  Widget buildTypeWiseSpaceList(
    List<SpaceEntity> spaceList,
    SpaceCategory spaceCategory,
  ) {
    return BlocConsumer<EnableLocationCubit, EnableLocationState>(
      bloc: getIt<EnableLocationCubit>()..onAskDeviceLocation(),
      listener: (context, locationState) {},
      builder: (context, locationState) {
        return Column(
          children: [
            Column(
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
                        isSelected: spaceCategory == SpaceCategory.ENTIRE,
                        onTap: () {
                          widget.onSpaceByCategoryTap(SpaceCategory.ENTIRE);
                        },
                      ),
                      CategoryIconWidget(
                        icon: "assets/icons/ic_space_category_pub.svg",
                        title: LocaleKeys.pub.tr(),
                        isSelected: spaceCategory == SpaceCategory.PUB,
                        onTap: () {
                          widget.onSpaceByCategoryTap(SpaceCategory.PUB);
                        },
                      ),
                      CategoryIconWidget(
                        icon: "assets/icons/ic_space_category_cafe.svg",
                        title: LocaleKeys.cafe.tr(),
                        isSelected: spaceCategory == SpaceCategory.CAFE,
                        onTap: () {
                          widget.onSpaceByCategoryTap(SpaceCategory.CAFE);
                        },
                      ),
                      CategoryIconWidget(
                        icon: "assets/icons/ic_space_category_pub.svg",
                        title: LocaleKeys.coworking.tr(),
                        isSelected: spaceCategory == SpaceCategory.COWORKING,
                        onTap: () {
                          widget.onSpaceByCategoryTap(SpaceCategory.COWORKING);
                        },
                      ),
                      CategoryIconWidget(
                        icon: "assets/icons/ic_space_category_music.svg",
                        title: LocaleKeys.music.tr(),
                        isSelected: spaceCategory == SpaceCategory.MUSIC,
                        onTap: () {
                          widget.onSpaceByCategoryTap(SpaceCategory.MUSIC);
                        },
                      ),
                      CategoryIconWidget(
                        icon: "assets/icons/ic_space_category_meal.svg",
                        title: LocaleKeys.meal.tr(),
                        isSelected: spaceCategory == SpaceCategory.MEAL,
                        onTap: () {
                          widget.onSpaceByCategoryTap(SpaceCategory.MEAL);
                        },
                      ),
                    ],
                  ),
                ),
                const VerticalSpace(30),
                spaceList.isEmpty
                    ? const EmptyDataWidget(height: 90)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: spaceList.length,
                        itemBuilder: (context, index) {
                          return SpaceListItem(
                            spaceEntity: spaceList[index],
                          );
                        },
                      ),
                widget.isLoadingMore
                    ? Lottie.asset('assets/lottie/loader.json')
                    : widget.isAllSpacesLoaded
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: LoadMoreIconButton(
                              onTap: () {
                                widget.onLoadMore();
                              },
                            ),
                          ),
                const VerticalSpace(40),
              ],
            ),
          ],
        );
      },
    );
  }

  Column buildNewSpaceList(List<NewSpaceEntity> newSpaceList) {
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
        newSpaceList.isEmpty
            ? const SizedBox.shrink()
            : SizedBox(
                height: 192,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: newSpaceList.length,
                  itemBuilder: (context, index) {
                    return NewSpaceItem(
                      newSpaceEntity: newSpaceList[index],
                    );
                  },
                ),
              ),
        const SizedBox(height: 35),
      ],
    );
  }

  Padding buildTopUsedNftsRowWidget(List<TopUsedNftEntity> topUsedNfts) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20,
        bottom: 30,
      ),
      child: Column(
        children: [
          topUsedNfts.isEmpty
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
                              topUsedNftEntity: topUsedNfts[0],
                              score: 1,
                            ),
                            SpaceTopNFTListItem(
                              topUsedNftEntity: topUsedNfts[1],
                              score: 2,
                            ),
                            SpaceTopNFTListItem(
                              topUsedNftEntity: topUsedNfts[2],
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
