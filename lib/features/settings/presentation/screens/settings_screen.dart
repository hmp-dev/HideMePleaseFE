import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_toggle.dart';
import 'package:mobile/features/common/presentation/widgets/thick_divider.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/announcement_screen.dart';
import 'package:mobile/features/settings/presentation/screens/membership_withdrawal_screen.dart';
import 'package:mobile/features/settings/presentation/screens/terms_of_use_main_screen.dart';
import 'package:mobile/features/settings/presentation/widgets/feature_tile.dart';
import 'package:mobile/features/settings/presentation/widgets/fore3_text_button.dart';
import 'package:mobile/features/settings/presentation/widgets/version_info_tile.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationEnabled = false;
  bool isLocationInfoEnabled = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.settings.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: MultiBlocListener(
        listeners: [
          BlocListener<AppCubit, AppState>(
            bloc: getIt<AppCubit>(),
            listener: (context, state) {
              if (!state.isLoggedIn) {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.startUpScreen, (route) => false);
              }
            },
          ),
          BlocListener<SettingsCubit, SettingsState>(
            bloc: getIt<SettingsCubit>(),
            listener: (context, state) {
              "the state is changed $state".log();
              if (state.isSuccess && state.cmsLinkEntity.link.isNotEmpty) {
                WebViewScreen.push(
                  context: context,
                  title: LocaleKeys.spacePartnershipApplicationTitle.tr(),
                  url: state.cmsLinkEntity.link,
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildTopHmpBlueBox(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotificationsSettingsToggleRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Row(
        children: [
          Text(
            LocaleKeys.notificationSettings.tr(),
            style: fontCompactSm(),
          ),
          const Spacer(),
          CustomToggle(
            initialValue: isNotificationEnabled,
            onTap: (bool value) {
              setState(() {
                isNotificationEnabled = value;
              });
            },
            toggleColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget buildTopHmpBlueBox() {
    return GestureDetector(
      onTap: () {
        getIt<SettingsCubit>().onGetCMSlink();
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
                LocaleKeys.communityNeedsSpace.tr(),
                style: fontCompactSmMedium(color: fore2),
              ),
              const VerticalSpace(7),
              Text(
                LocaleKeys.spacePartnershipApplication.tr(),
                style: fontCompactMdBold(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLocationConcent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isLocationInfoEnabled = !isLocationInfoEnabled;
          });
        },
        child: Row(
          children: [
            Text(
              LocaleKeys.locationInfoAgreement.tr(),
              style: fontCompactSm(),
            ),
            const Spacer(),
            isLocationInfoEnabled
                ? Text(
                    LocaleKeys.permit.tr(),
                    style: fontCompactSmMedium(color: hmpBlue),
                  )
                : Text(
                    LocaleKeys.deny.tr(),
                    style: fontCompactSmMedium(color: hmpBlue),
                  ),
          ],
        ),
      ),
    );
  }
}
