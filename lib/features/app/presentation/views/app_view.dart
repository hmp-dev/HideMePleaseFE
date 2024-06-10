import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/services/notification_service.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart';
import 'package:mobile/features/app/presentation/widgets/bottom_bar.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/community/presentation/screens/community_screen.dart';
import 'package:mobile/features/events/presentation/screens/events_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/my/presentation/screens/my_screen.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_screen.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final double _opacity = 1.0;

  // final PreloadPageController _pageController =
  //     PreloadPageController(initialPage: 2);

  @override
  void initState() {
    super.initState();
    _setUpNotification();
  }

  _setUpNotification() async {
    NotificationServices.instance.initialize().then((_) async {
      final fcmToken = await NotificationServices.instance.getDeviceToken();
      if (fcmToken != null) {
        Log.debug("fcmToken: $fcmToken");
        getIt<ProfileCubit>()
            .onUpdateUserProfile(UpdateProfileRequestDto(fcmToken: fcmToken));
      }
    });
  }

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
              BlocConsumer<PageCubit, PageState>(
                bloc: getIt<PageCubit>(),
                listener: (context, state) {},
                builder: (context, state) {
                  "state is changed $state".log();
                  return Column(
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
                            } else if (index == MenuType.settings.menuIndex) {
                              return const MyScreen();
                            }
                            return Container();
                          },
                          itemCount: MenuType.values.length,
                          controller: state.pageController,
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
                              if (type == MenuType.settings) {
                                // fetch SettingBannerInfo and AppVersionInfo
                                getIt<SettingsCubit>().onGetSettingBannerInfo();
                                // Navigate to Settings Screen
                                SettingsScreen.push(context);
                              } else if (type == MenuType.space) {
                                // init Cubit function to get all space view data
                                getIt<SpaceCubit>().onFetchAllSpaceViewData();
                                _onChangeMenu(type);
                              } else {
                                _onChangeMenu(type);
                              }
                            },
                            selectedType: state.menuType,
                            opacity: _opacity,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onChangeMenu(MenuType menuType) {
    //state.pageController.jumpToPage(menuType.menuIndex);
    getIt<PageCubit>().changePage(menuType.menuIndex, menuType);
  }
}
