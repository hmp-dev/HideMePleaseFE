import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class EventsScreenComingSoon extends StatefulWidget {
  const EventsScreenComingSoon({super.key});

  @override
  State<EventsScreenComingSoon> createState() => _EventsScreenComingSoonState();
}

class _EventsScreenComingSoonState extends State<EventsScreenComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: EventsComingSoonChildView(
        onBoardingSlideData: EventsViewData(
            titleTextA: "이벤트 페이지는 준비중이에요!",
            titleTextB: "커지는 혜택", // Growing benefits"
            descText: "HideMePlease 멤버들과 함께\n이벤트를 참여해보아요!",
            animationPath: "assets/lottie/onboarding4.json"),
      ),
    );
  }
}

class EventsComingSoonChildView extends StatelessWidget {
  final EventsViewData onBoardingSlideData;

  const EventsComingSoonChildView({super.key, required this.onBoardingSlideData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Expanded(
          flex: 3,
          child: SizedBox(),
        ),
        Expanded(
          flex: 5,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 120,
              child: AspectRatio(
                aspectRatio: 0.5,
                child: SizedBox(
                  width: 182,
                  height: 158,
                  child: Lottie.asset(onBoardingSlideData.animationPath,
                      fit: BoxFit.contain, alignment: Alignment.center),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const VerticalSpace(10),
              Text(
                onBoardingSlideData.titleTextA,
                textAlign: TextAlign.center,
                style: fontTitle03Bold(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: SizedBox(
            width: 250,
            child: Text(
              '', //onBoardingSlideData.descText,
              textAlign: TextAlign.center,
              style: fontCompactMd(color: fore2),
            ),
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
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
