import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';

class EventsWidget extends StatefulWidget {
  const EventsWidget({super.key});

  @override
  State<EventsWidget> createState() => _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("참여 이벤트", style: fontTitle06Medium()),
            const HorizontalSpace(10),
            Text("4", style: fontTitle07()),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
