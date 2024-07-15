import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/space/domain/entities/recommendation_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/views/space_view.dart';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  @override
  void initState() {
    super.initState();
    getIt<SpaceCubit>().onFetchAllSpaceViewData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnableLocationCubit, EnableLocationState>(
      bloc: getIt<EnableLocationCubit>(),
      builder: (context, locationState) {
        return BlocBuilder<SpaceCubit, SpaceState>(
          bloc: getIt<SpaceCubit>(),
          builder: (context, state) {
            final collectionLogo = state.topUsedNfts.isNotEmpty
                ? state.topUsedNfts[0].collectionLogo
                : "";

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  if (state.submitStatus == RequestStatus.success)
                    PositionedDirectional(
                      child: collectionLogo == ""
                          ? Image.asset(
                              "assets/images/place_holder_card.png",
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            )
                          : Image.network(
                              collectionLogo,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                    ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(39, 12, 54, 0.29),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(39, 12, 54, 0.29),
                          Colors.black, // Fade out to transparent
                        ],
                      ),
                    ),
                  ),
                  SpaceView(
                    onRefresh: () =>
                        getIt<SpaceCubit>().onFetchAllSpaceViewData(),
                    onLoadMore: () => getIt<SpaceCubit>().onGetSpacesLoadMore(
                      latitude: locationState.latitude,
                      longitude: locationState.longitude,
                    ),
                    isAllSpacesLoaded: state.allSpacesLoaded,
                    topUsedNfts: state.topUsedNfts,
                    newSpaceList: state.newSpaceList,
                    recommendedSpace:
                        // state.recommendationSpaceList.isNotEmpty
                        //     ? state.recommendationSpaceList[0]
                        //     :

                        const RecommendationSpaceEntity.empty(),
                    spaceList: state.spaceList,
                    spaceCategory: state.spaceCategory,
                    isLoadingMore:
                        state.loadingMoreStatus == RequestStatus.loading,
                    onSpaceByCategoryTap: (spaceCategory) {
                      getIt<SpaceCubit>().onGetSpaceListByCategory(
                        latitude: locationState.latitude,
                        longitude: locationState.longitude,
                        category: spaceCategory,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
