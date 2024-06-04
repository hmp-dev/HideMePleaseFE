// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
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
  final FlutterAppAuth appAuth = const FlutterAppAuth();

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
      body: SafeArea(
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
                "${userProfile.nickName},\n${LocaleKeys.areYouSureYouWantToWithdraw.tr()}",
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
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                        showCompletedWithdrawAlertDialog(
                          context: context,
                          title: LocaleKeys.withdrawalCompleted.tr(),
                          content: LocaleKeys.agreeTermDialogMessage.tr(),
                          onConfirm: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
