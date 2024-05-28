import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/widgets/bottom_bar.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/community/presentation/screens/community_screen.dart';
import 'package:mobile/features/events/presentation/screens/events_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/my/presentation/screens/my_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_screen.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final double _opacity = 1.0;
  MenuType menuType = MenuType.home;
  final PreloadPageController _pageController =
      PreloadPageController(initialPage: 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C0C0E), Color(0xCC0C0C0E)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Expanded(
                    child: PreloadPageView.builder(
                      onPageChanged: (value) {},
                      itemBuilder: (context, index) {
                        if (index == MenuType.space.menuIndex) {
                          return const SpaceScreen();
                        } else if (index == MenuType.events.menuIndex) {
                          return const EventsScreen();
                        } else if (index == MenuType.home.menuIndex) {
                          return const HomeScreen();
                        } else if (index == MenuType.community.menuIndex) {
                          return const CommunityScreen();
                        } else if (index == MenuType.my.menuIndex) {
                          return const MyScreen();
                        }
                        return Container();
                      },
                      itemCount: MenuType.values.length,
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      preloadPagesCount: 5,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      BottomBar(
                        onTap: (type) {
                          ('type: $type').log();
                          if (type == MenuType.my) {
                            // fetch Nft Points
                            getIt<NftCubit>().onGetNftPoints();
                            // Navigate to My Screen
                            MyScreen.push(context);
                          } else if (type == MenuType.space) {
                            // init Cubit function to get all space view data
                            getIt<SpaceCubit>().onFetchAllSpaceViewData();
                            _onChangeMenu(type);
                          } else {
                            _onChangeMenu(type);
                          }
                        },
                        selectedType: menuType,
                        opacity: _opacity,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChangeMenu(MenuType menuType) {
    this.menuType = menuType;
    _pageController.jumpToPage(menuType.menuIndex);
    setState(() {});
  }
}
