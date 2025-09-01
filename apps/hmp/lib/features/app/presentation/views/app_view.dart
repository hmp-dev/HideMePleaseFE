// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/services/live_activity_service.dart';
import 'package:mobile/app/core/notifications/notification_service.dart';
import 'package:mobile/features/map/presentation/map_screen.dart';
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart';
import 'package:mobile/features/map/presentation/widgets/check_in_bottom_bar.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
//import 'package:mobile/features/community/presentation/screens/community_screen.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/my_profile_screen.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_screen.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_employ_dialog.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:mobile/app/core/services/nfc_service.dart';
import 'package:mobile/app/core/services/simple_nfc_test.dart';
import 'package:mobile/app/core/services/safe_nfc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_fail_dialog.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_success_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/error/error.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final double _opacity = 1.0;

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

                    return Stack(
                      children: [
                        PreloadPageView.builder(
                          onPageChanged: (value) {},
                          itemBuilder: (context, index) {
                            print('🏗️ Building page for index: $index');
                            
                            if (index == MenuType.space.menuIndex) {
                              print('🗺️ Returning MapScreen for index $index');
                              return MapScreen(
                                onShowBottomBar: () => getIt<PageCubit>().showBottomBar(),
                                onHideBottomBar: () => getIt<PageCubit>().hideBottomBar(),
                              );
                            } else if (index == MenuType.events.menuIndex) {
                              print('🎪 Returning HomeScreen (Events) for index $index');
                              return const HomeScreen(); // EventsWepinScreen();
                            } else if (index == MenuType.home.menuIndex) {
                              print('🏠 Returning HomeScreen for index $index');
                              return const HomeScreen();
                            } else if (index == MenuType.myProfile.menuIndex) {
                              print('👤 Returning MyProfileScreen for index $index');
                              return const MyProfileScreen();
                            }
                            print('❓ Returning default Container for index $index');
                            return Container();
                          },
                          itemCount: MenuType.values.length,
                          controller: state.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          preloadPagesCount: 5,
                        ),
                        if (state.showBottomBar)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: CheckInBottomBar(
                          isMapActive: state.menuType == MenuType.space,
                          isMyActive: state.menuType == MenuType.myProfile,
                          onMapTap: () {
                            ('🗺️ MAP button tapped').log();
                            _onChangeMenu(MenuType.space);
                            getIt<SpaceCubit>().onFetchAllSpaceViewData();
                          },
                          onMyTap: () {
                            ('👤 My button tapped').log();
                            _onChangeMenu(MenuType.myProfile);
                          },
                          onCheckInTap: _handleCheckIn,
                        ),
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
    ('🔄 Changing to menu: $menuType (index: ${menuType.menuIndex})').log();
    getIt<PageCubit>().changePage(menuType.menuIndex, menuType);
    ('✅ Page change completed').log();
  }

  void _showNfcScanDialog(BuildContext context, {required Function onCancel}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => onCancel(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready to Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  LocaleKeys.nfc_tag_nearby.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF007AFF),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.smartphone,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => onCancel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCheckIn() async {
    final spaceCubit = getIt<SpaceCubit>();
    final selectedSpace = spaceCubit.state.selectedSpace;

    if (selectedSpace == null) {
      ('⚠️ Check-in attempt without a selected space.').log();
      showDialog(
        context: context,
        builder: (context) => const CheckinFailDialog(),
      );
      return;
    }

    ('✅ Check-in button tapped for ${selectedSpace.name} - Simulating NFC scan...').log();
    Timer? debugTimer;

    final dialogCompleter = Completer<void>();

    _showNfcScanDialog(context, onCancel: () {
      ('🟧 NFC Scan Canceled by user.').log();
      debugTimer?.cancel();
      if (!dialogCompleter.isCompleted) {
        Navigator.of(context).pop();
        dialogCompleter.complete();
      }
    });

    debugTimer = Timer(const Duration(seconds: 5), () {
      ('✅ NFC simulation successful after 5 seconds.').log();

      if (!dialogCompleter.isCompleted && mounted) {
        Navigator.of(context).pop();
        dialogCompleter.complete();

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            final spaceToUse = selectedSpace;
            final benefitDescription = spaceToUse.benefitDescription.isNotEmpty
                ? spaceToUse.benefitDescription
                : '등록된 혜택이 없습니다.';

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CheckinEmployDialog(
                  benefitDescription: benefitDescription,
                  spaceName: spaceToUse.name,
                  onConfirm: () async {
                    try {
                      final position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      ('📍 Current location for check-in: ${position.latitude}, ${position.longitude}')
                          .log();

                      print('📡 Calling check-in API with parameters:');
                      print('   spaceId: ${spaceToUse.id}');
                      print('   latitude: ${position.latitude}');
                      print('   longitude: ${position.longitude}');

                      await spaceCubit.onCheckInWithNfc(
                        spaceId: spaceToUse.id,
                        latitude: position.latitude,
                        longitude: position.longitude,
                      );

                      if (mounted) {
                        Navigator.of(context).pop();
                        await showDialog(
                          context: context,
                          builder: (context) => CheckinSuccessDialog(
                            spaceName: spaceToUse.name,
                            benefitDescription: benefitDescription,
                          ),
                        );
                        spaceCubit.onFetchAllSpaceViewData();
                      }
                    } catch (e) {
                      ('❌ Check-in error: $e').log();
                      ('❌ Error type: ${e.runtimeType}').log();
                                  
                      String errorMessage = LocaleKeys.benefitRedeemErrorMsg.tr();
                      
                      if (e is HMPError) {
                        ('❌ HMPError details - message: ${e.message}, error: ${e.error}').log();
                        
                        if (e.error?.contains('SPACE_OUT_OF_RANGE') == true) {
                          errorMessage = LocaleKeys.space_out_of_range.tr();
                        } else if (e.error?.contains('ALREADY_CHECKED_IN') == true) {
                          errorMessage = LocaleKeys.already_checked_in.tr();
                        } else if (e.error?.contains('INVALID_SPACE') == true) {
                          errorMessage = LocaleKeys.invalid_space.tr();
                        }
                        else if (e.message.contains('SPACE_OUT_OF_RANGE')) {
                          errorMessage = LocaleKeys.space_out_of_range.tr();
                        } else if (e.message.contains('ALREADY_CHECKED_IN')) {
                          errorMessage = LocaleKeys.already_checked_in.tr();
                        } else if (e.message.contains('INVALID_SPACE')) {
                          errorMessage = LocaleKeys.invalid_space.tr();
                        }
                      } 
                      else if (e.toString().contains('SPACE_OUT_OF_RANGE')) {
                        errorMessage = LocaleKeys.space_out_of_range.tr();
                      } else if (e.toString().contains('ALREADY_CHECKED_IN')) {
                        errorMessage = LocaleKeys.already_checked_in.tr();
                      } else if (e.toString().contains('INVALID_SPACE')) {
                        errorMessage = LocaleKeys.invalid_space.tr();
                      }
                      
                      ('📋 Final error message: $errorMessage').log();
                      
                      if (mounted) {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => const CheckinFailDialog(),
                        );
                      }
                    }
                  },
                );
              },
            );
          }
        });
      }
    });
  }
}