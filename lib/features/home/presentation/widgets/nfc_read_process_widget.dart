import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_container.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/circle_dot_widget.dart';
import 'package:mobile/features/home/presentation/widgets/dashed_divider.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';

class NfcReadProcessWidget extends StatefulWidget {
  const NfcReadProcessWidget({
    super.key,
    required this.spaceId,
    required this.benefitId,
    required this.tokenAddress,
  });

  final String spaceId;
  final String benefitId;
  final String tokenAddress;

  @override
  State<NfcReadProcessWidget> createState() => _NfcReadProcessWidgetState();
}

class _NfcReadProcessWidgetState extends State<NfcReadProcessWidget> {
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
        if (_secondsLeft == 20) {
          getIt<SpaceCubit>().onGetBackdoorToken(spaceId: "");
        }
        if (_secondsLeft == 0) {
          setState(() {
            timer.cancel();
          });
          Navigator.of(context).pop();
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
          getIt<SpaceCubit>().onPostRedeemBenefit(
            benefitId: widget.benefitId,
            tokenAddress: widget.tokenAddress,
            nfcToken: state.nfcToken,
          );
        }

        if (state.submitStatus == RequestStatus.success &&
            state.benefitRedeemStatus) {
          Navigator.of(context).pop();
        }
      },
      child: SizedBox(
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
                          child: Lottie.asset("assets/lottie/onboarding2.json",
                              fit: BoxFit.contain, alignment: Alignment.center),
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
              bottom: 50,
              left: -4.5,
              child: CircleDotWidget(
                side: BorderSideVal.left,
              ),
            ),
            const Positioned(
              bottom: 50,
              right: -4.5,
              child: CircleDotWidget(
                side: BorderSideVal.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
