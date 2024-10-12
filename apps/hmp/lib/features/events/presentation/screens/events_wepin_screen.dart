import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wepin/wepin_wallet_connect_list_tile.dart';
import 'package:mobile/features/wepin/wepin_wallet_details_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class EventsWepinScreen extends StatefulWidget {
  const EventsWepinScreen({super.key});

  @override
  State<EventsWepinScreen> createState() => _EventsWepinScreenState();
}

class _EventsWepinScreenState extends State<EventsWepinScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletsCubit, WalletsState>(
      bloc: getIt<WalletsCubit>(),
      builder: (context, state) {
        return state.isWepinWalletConnected && state.isEventViewActive
            ? const WepinWalletDetailsView()
            : Center(
                child: EventsComingSoonChildView(
                  onBoardingSlideData: EventsViewData(
                      titleTextA: LocaleKeys.connect_your_wepin_wallet.tr(),
                      titleTextB: "커지는 혜택", // Growing benefits"
                      descText: "무료NFT증정과 함께\n다양한 혜택을 받아보세요!",
                      animationPath: "assets/lottie/onboarding4.json"),
                ),
              );
      },
    );
  }
}

class EventsComingSoonChildView extends StatelessWidget {
  final EventsViewData onBoardingSlideData;

  const EventsComingSoonChildView(
      {super.key, required this.onBoardingSlideData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Spacer(),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: SizedBox(
              width: 182,
              height: 158,
              child: Lottie.asset(onBoardingSlideData.animationPath,
                  fit: BoxFit.contain, alignment: Alignment.center),
            ),
          ),
        ),
        const VerticalSpace(10),
        Text(
          onBoardingSlideData.titleTextA,
          textAlign: TextAlign.center,
          style: fontTitle03Bold(),
        ),
        const VerticalSpace(10),
        Text(
          onBoardingSlideData.titleTextB,
          textAlign: TextAlign.center,
          style: fontTitle03Bold(color: hmpBlue),
        ),
        const VerticalSpace(10),
        Text(
          onBoardingSlideData.descText,
          textAlign: TextAlign.center,
          style: fontCompactMd(color: fore2),
        ),
        const Spacer(),
        const WepinWalletConnectLisTile(
          isShowCustomButton: true,
        ),
        const VerticalSpace(30),
      ],
    );
  }
}

class EventsViewData {
  final String titleTextA;
  final String titleTextB;
  final String descText;
  final String animationPath;

  EventsViewData({
    required this.titleTextA,
    required this.titleTextB,
    required this.descText,
    required this.animationPath,
  });
}
