// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MembershipWithdrawalScreen extends StatefulWidget {
  const MembershipWithdrawalScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MembershipWithdrawalScreen(),
      ),
    );
  }

  @override
  State<MembershipWithdrawalScreen> createState() =>
      _MembershipWithdrawalScreenState();
}

class _MembershipWithdrawalScreenState
    extends State<MembershipWithdrawalScreen> {
  bool isAgreeWithTerms = false;
  int? isShowOnBoarding;

  @override
  void initState() {
    super.initState();
    checkIsShowOnBoarding();
  }

  checkIsShowOnBoarding() async {
    isShowOnBoarding = await getInitialScreen();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = getIt<ProfileCubit>().state.userProfileEntity;
    return BaseScaffold(
      title: LocaleKeys.applyForMembershipWithdrawal.tr(),
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
            listener: (context, state) async {
              if (state.submitStatus == RequestStatus.success) {
                var result = await showCompletedWithdrawAlertDialog(
                  context: context,
                  title: LocaleKeys.withdrawalCompleted.tr(),
                  onConfirm: () {
                    Navigator.pop(context);
                    getIt<AppCubit>().onLogOut();
                  },
                );

                if (result) {
                  // Handle the case where the dialog was shown and a confirmation action was taken
                  ("User confirmed the action.").log();
                  getIt<AppCubit>().onLogOut();
                } else {
                  // Handle the case where the dialog was dismissed without confirmation
                  ("Dialog was dismissed.").log();
                  getIt<AppCubit>().onLogOut();
                }
              }
            },
          ),
        ],
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CustomImageView(
                  svgPath: "assets/images/withdraw-membership.svg",
                  width: 158,
                  height: 136,
                ),
                const SizedBox(height: 12),
                Text(
                  "${userProfile.nickName}님,\n${LocaleKeys.areYouSureYouWantToWithdraw.tr()}",
                  textAlign: TextAlign.center,
                  style: fontCompactLgMedium(),
                ),
                const VerticalSpace(10),
                Text(
                  LocaleKeys.withdrawalMessage.tr(),
                  textAlign: TextAlign.center,
                  style: fontCompactSm(color: fore2),
                ),
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: [
                      HMPCustomButton(
                        text: LocaleKeys.keepMembershipBenefits.tr(),
                        bgColor: hmpBlue,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const VerticalSpace(15),
                      RoundedButtonWithBorder(
                        text: LocaleKeys.applyForWithdrawal.tr(),
                        onPressed: () {
                          Navigator.pop(context);
                          getIt<SettingsCubit>().onRequestDeleteUser();

                          // showWithdrawConfirmationAlertDialog(
                          //   context: context,
                          //   title: LocaleKeys.areYouSureYouWantToWithdraw.tr(),
                          //   onConfirm: () {
                          //     Navigator.pop(context);
                          //     getIt<SettingsCubit>().onRequestDeleteUser();
                          //   },
                          //   onCancel: () {
                          //     Navigator.pop(context);
                          //   },
                          // );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
