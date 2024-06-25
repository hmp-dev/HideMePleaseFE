import 'package:flutter/material.dart';
import 'package:mobile/features/events/presentation/views/events_view.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: EventsView(
        onBoardingSlideData: EventsViewData(
            titleTextA: "이벤트 페이지는 준비중이에요!",
            titleTextB: "커지는 혜택",
            descText: "HideMePlease 멤버들과 함께\n이벤트를 참여해보아요!",
            animationPath: "assets/lottie/onboarding4.json"),
      ),
    );
  }
}
