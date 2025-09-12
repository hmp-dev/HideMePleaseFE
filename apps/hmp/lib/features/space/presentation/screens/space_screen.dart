import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/space/domain/entities/recommendation_space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/views/space_view.dart';
import 'package:mobile/features/space/presentation/widgets/space_guide_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents the Space screen widget.
///
/// This widget is responsible for displaying the Space screen in the app.
/// It uses the [StatefulWidget] lifecycle and creates a [_SpaceScreenState]
/// to manage the state of the screen.
class SpaceScreen extends StatefulWidget {
  /// Creates a [SpaceScreen] widget.
  ///
  /// This constructor takes no parameters and returns an instance of
  /// [SpaceScreen].
  const SpaceScreen({super.key});

  @override
  // Create and return the mutable state for this widget at a given location in
  // the tree.
  //
  // Subclasses should override this method to return a newly created
  // instance of their associated [State] subclass.
  //
  // The framework will call this method multiple times over the lifetime of
  // a [StatefulWidget], so it must be able to create a fresh new instance
  // each time it is called.
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  bool _showGuide = false;
  bool _guideCheckComplete = false;

  @override
  void initState() {
    super.initState();
    getIt<SpaceCubit>().onFetchAllSpaceViewData();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    print('🔍 _checkFirstTimeUser called');
    final prefs = await SharedPreferences.getInstance();
    // 디버그를 위해 가이드를 리셋 (나중에 제거 가능)
    await prefs.remove('hasSeenSpaceGuide');
    
    final hasSeenGuide = prefs.getBool('hasSeenSpaceGuide') ?? false;
    print('🎯 Space Guide Check - hasSeenGuide: $hasSeenGuide');
    
    // 강제로 가이드 표시
    print('📱 Force showing Space Guide Overlay');
    if (mounted) {
      setState(() {
        _showGuide = true;
        _guideCheckComplete = true;
      });
      print('✅ State updated - _showGuide: $_showGuide, _guideCheckComplete: $_guideCheckComplete');
    }
  }

  void _onGuideComplete() {
    setState(() {
      _showGuide = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building SpaceScreen - _showGuide: $_showGuide, _guideCheckComplete: $_guideCheckComplete');
    
    return Stack(
      children: [
        // Main content
        BlocBuilder<EnableLocationCubit, EnableLocationState>(
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
                    recommendedSpace: state.recommendationSpaceList.isNotEmpty
                        ? state.recommendationSpaceList[0]
                        : const RecommendationSpaceEntity.empty(),
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
    ),
    // Show guide overlay on top of everything
    if (_guideCheckComplete && _showGuide)
      Positioned.fill(
        child: SpaceGuideOverlay(
          onComplete: _onGuideComplete,
        ),
      ),
  ],
);
  }
}
