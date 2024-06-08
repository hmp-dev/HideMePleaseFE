import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_container.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/circle_dot_widget.dart';
import 'package:mobile/features/home/presentation/widgets/dashed_divider.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';

class NfcReadProcessView extends StatefulWidget {
  const NfcReadProcessView({
    super.key,
    required this.spaceId,
    required this.benefitId,
    required this.tokenAddress,
  });

  final String spaceId;
  final String benefitId;
  final String tokenAddress;

  static push({
    required BuildContext context,
    required String spaceId,
    required String benefitId,
    required String tokenAddress,
  }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NfcReadProcessView(
          spaceId: spaceId,
          benefitId: benefitId,
          tokenAddress: tokenAddress,
        ),
      ),
    );
  }

  @override
  State<NfcReadProcessView> createState() => _NfcReadProcessViewState();
}

class _NfcReadProcessViewState extends State<NfcReadProcessView> {
  final _snackBarService = getIt<SnackbarService>();

  late Timer _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        "Timer is running ${timer.tick}".log();
        if (_secondsLeft == 29) {
          getIt<SpaceCubit>().onGetBackdoorToken(spaceId: widget.spaceId);
        }
        if (_secondsLeft == 0) {
          setState(() {
            timer.cancel();
          });
          Navigator.pop(context);
        } else {
          setState(() {
            _secondsLeft--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpaceCubit, SpaceState>(
      bloc: getIt<SpaceCubit>(),
      listener: (context, state) {
        if (state.submitStatus == RequestStatus.success &&
            state.nfcToken.isNotEmpty) {
          final locationState = getIt<EnableLocationCubit>().state;

          if (locationState.latitude == 0.0 || locationState.longitude == 0.0) {
            getIt<SpaceCubit>().onPostRedeemBenefit(
              benefitId: widget.benefitId,
              tokenAddress: widget.tokenAddress,
              spaceId: state.nfcToken,
              latitude: 2.0, //locationState.latitude,
              longitude: 2.0, //locationState.longitude,
            );
          }
        }

        if (state.submitStatus == RequestStatus.success &&
            state.benefitRedeemStatus) {
          // cancel the Timer
          _timer.cancel();

          // call the snackbar Success Message
          _snackBarService.showSnackbar(
            message: LocaleKeys.benefitRedeemSuccessMsg.tr(),
            duration: const Duration(seconds: 2),
          );

          getIt<SpaceCubit>().onResetSubmitStatus();
        }

        if (state.submitStatus == RequestStatus.failure) {
          // cancel the Timer
          _timer.cancel();

          // call the snackbar Error Message

          "inside failure".log();
          _snackBarService.showSnackbar(
            message: LocaleKeys.benefitRedeemErrorMsg.tr(),
            duration: const Duration(seconds: 2),
          );
          // reset Submit to initial
          getIt<SpaceCubit>().onResetSubmitStatus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black, // Set the background color to black
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, top: 20),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: DefaultImage(
                      path: "assets/icons/ic_close.svg",
                      width: 32,
                      height: 32,
                      color: white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 303,
                height: 436,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 293,
                      height: 436,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GlassContainer(
                        width: 293,
                        height: 436,
                        radius: 8,
                        child: Container(
                          width: 293,
                          height: 436,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: fore4),
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Spacer(),
                                SizedBox(
                                  width: 182,
                                  height: 158,
                                  child: Lottie.asset(
                                      "assets/lottie/onboarding2.json",
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center),
                                ),
                                const Spacer(),
                                Text(
                                  "사장님과 하이파이브를 해주세요!",
                                  textAlign: TextAlign.center,
                                  style: fontTitle05Bold(),
                                ),
                                //
                                Text(
                                  "해당 공간의 혜택이 자동으로 사용돼요",
                                  textAlign: TextAlign.center,
                                  style: fontCompactMd(),
                                ),

                                const Spacer(),
                                const DashedDivider(),
                                const VerticalSpace(20),
                                Center(
                                  child: Text(
                                    "0:$_secondsLeft",
                                    style: fontTitle01Medium(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 72,
                      left: -4.5,
                      child: CircleDotWidget(
                        side: BorderSideVal.left,
                      ),
                    ),
                    const Positioned(
                      bottom: 72,
                      right: -4.5,
                      child: CircleDotWidget(
                        side: BorderSideVal.right,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
