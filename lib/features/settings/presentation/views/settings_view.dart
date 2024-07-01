import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_toggle.dart';
import 'package:mobile/features/common/presentation/widgets/thick_divider.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/settings/domain/entities/settings_banner_entity.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/announcement_screen.dart';
import 'package:mobile/features/settings/presentation/screens/membership_withdrawal_screen.dart';
import 'package:mobile/features/settings/presentation/screens/terms_of_use_main_screen.dart';
import 'package:mobile/features/settings/presentation/widgets/feature_tile.dart';
import 'package:mobile/features/settings/presentation/widgets/fore3_text_button.dart';
import 'package:mobile/features/settings/presentation/widgets/version_info_tile.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.settingsBannerEntity,
  });

  final SettingsBannerEntity settingsBannerEntity;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isNotificationEnabled = false;
  bool isLocationInfoEnabled = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildTopHmpBlueBannerBox(widget.settingsBannerEntity),
                const VerticalSpace(10),
                Fore3TextButton(
                  title: LocaleKeys.userSettings.tr(),
                  onTap: () {},
                ),
                buildNotificationsSettingsToggleRow(),
                buildLocationConcent(),
              ],
            ),
          ),
          const ThickDivider(paddingTop: 5, paddingBottom: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Fore3TextButton(
                  title: LocaleKeys.etc.tr(),
                  onTap: () {},
                ),
                FeatureTile(
                  title: LocaleKeys.announcement.tr(),
                  onTap: () {
                    getIt<SettingsCubit>().onGetAnnouncements();
                    AnnouncementScreen.push(context);
                  },
                ),
                const VerticalSpace(10),
                FeatureTile(
                  title: LocaleKeys.termsOfUse.tr(),
                  onTap: () {
                    TermsOfUseMainScreen.push(context);
                  },
                ),
                const VerticalSpace(10),
                const VersionInfoTile(),
                FeatureTile(
                  isShowArrowIcon: false,
                  title: LocaleKeys.logout.tr(),
                  onTap: () {
                    getIt<AppCubit>().onLogOut();
                  },
                ),
                const VerticalSpace(10),
                FeatureTile(
                  isShowArrowIcon: false,
                  title: LocaleKeys.membershipWithdrawal.tr(),
                  onTap: () {
                    MembershipWithdrawalScreen.push(context);
                  },
                ),
                const VerticalSpace(100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationsSettingsToggleRow() {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: getIt<ProfileCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 20),
          child: Row(
            children: [
              Text(
                LocaleKeys.notificationSettings.tr(),
                style: fontCompactMd(),
              ),
              const Spacer(),
              CustomToggle(
                initialValue: state.userProfileEntity.notificationsEnabled,
                onTap: (bool value) {
                  getIt<ProfileCubit>().onUpdateUserProfile(
                      UpdateProfileRequestDto(notificationsEnabled: value));
                },
                toggleColor: Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTopHmpBlueBannerBox(SettingsBannerEntity settingsBannerEntity) {
    return GestureDetector(
      onTap: () {
        "the link is ${settingsBannerEntity.settingsBannerLink}".log();

        if (settingsBannerEntity.settingsBannerLink.isNotEmpty) {
          WebViewScreen.push(
            context: context,
            title: LocaleKeys.spacePartnershipApplicationTitle.tr(),
            url: settingsBannerEntity.settingsBannerLink,
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: hmpBlue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0, top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settingsBannerEntity.settingsBannerHeading,
                style: fontCompactSmMedium(color: fore2),
              ),
              const VerticalSpace(7),
              Text(
                settingsBannerEntity.settingsBannerDescription,
                style: fontCompactMdBold(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLocationConcent() {
    return BlocConsumer<EnableLocationCubit, EnableLocationState>(
      bloc: getIt<EnableLocationCubit>()..checkLocationPermission(),
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: GestureDetector(
            onTap: () {
              "is the location is enabled ${state.isLocationEnabled}".log();
              getIt<EnableLocationCubit>()
                  .onAskDeviceLocationWithOpenSettings();
            },
            child: Row(
              children: [
                Text(
                  LocaleKeys.locationInfoAgreement.tr(),
                  style: fontCompactMd(),
                ),
                const Spacer(),
                state.isLocationPermissionGranted
                    ? Text(
                        LocaleKeys.allowed.tr(),
                        style: fontCompactSmMedium(color: hmpBlue),
                      )
                    : Text(
                        LocaleKeys.permit.tr(),
                        style: fontCompactSmMedium(color: hmpBlue),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
