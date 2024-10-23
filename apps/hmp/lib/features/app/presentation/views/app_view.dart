import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/notifications/notification_service.dart';
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart';
import 'package:mobile/features/app/presentation/widgets/bottom_bar.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/community/presentation/screens/community_screen.dart';
import 'package:mobile/features/events/presentation/screens/events_screen_coming_soon.dart';
import 'package:mobile/features/events/presentation/screens/events_wepin_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_screen.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

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
    initializeServices();
  }

  initializeServices() async {
    await getIt<EnableLocationCubit>().onAskDeviceLocation();
    await NotificationServices.instance.initialize();
    final fcmToken = await NotificationServices.instance.getDeviceToken();
    if (fcmToken != null) {
      ("fcmToken: $fcmToken").log();
      getIt<ProfileCubit>()
          .onUpdateUserProfile(UpdateProfileRequestDto(fcmToken: fcmToken));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C0C0E),
            Color(0xCC0C0C0E),
          ],
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
                return BlocBuilder<EnableLocationCubit, EnableLocationState>(
                  bloc: getIt<EnableLocationCubit>(),
                  builder: (context, locState) {
                    if (locState.isSubmitLoading) return Container();

                    return Column(
                      children: [
                        Expanded(
                          child: PreloadPageView.builder(
                            onPageChanged: (value) {},
                            itemBuilder: (context, index) {
                              if (index == MenuType.space.menuIndex) {
                                return const SpaceScreen();
                              } else if (index == MenuType.events.menuIndex) {
                                return const EventsWepinScreen();
                              } else if (index == MenuType.home.menuIndex) {
                                return const HomeScreen();
                              } else if (index ==
                                  MenuType.community.menuIndex) {
                                return const CommunityScreen();
                              } else if (index == MenuType.settings.menuIndex) {
                                return Container();
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
                                  // update EventView Active Status
                                  getIt<WalletsCubit>()
                                      .onIsEventViewActive(false);
                                  // fetch SettingBannerInfo and AppVersionInfo
                                  getIt<SettingsCubit>()
                                      .onGetSettingBannerInfo();
                                  // Navigate to Settings Screen
                                  SettingsScreen.push(context);
                                } else if (type == MenuType.space) {
                                  // update EventView Active Status
                                  getIt<WalletsCubit>()
                                      .onIsEventViewActive(false);
                                  // fetch SettingBannerInfo and AppVersionInfo
                                  getIt<SpaceCubit>().onFetchAllSpaceViewData();
                                  // Navigate to Settings Screen
                                  _onChangeMenu(type);
                                } else if (type == MenuType.events) {
                                  // check if Wepin Wallet is connected
                                  // Open the Wepin Widget
                                  if (getIt<WalletsCubit>()
                                      .state
                                      .isWepinWalletConnected) {
                                    getIt<WepinCubit>()
                                        .openWepinWidget(context, true);
                                  } else {
                                    //update EventView Active Status
                                    getIt<WalletsCubit>()
                                        .onIsEventViewActive(true);
                                    //Navigate to Events Screen
                                    _onChangeMenu(type);
                                  }
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onChangeMenu(MenuType menuType) {
    //state.pageController.jumpToPage(menuType.menuIndex);
    getIt<PageCubit>().changePage(menuType.menuIndex, menuType);
  }
}
