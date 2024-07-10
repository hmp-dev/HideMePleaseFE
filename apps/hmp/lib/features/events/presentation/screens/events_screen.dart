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
    return EventsView(
      onRefresh: () async {},
    );
  }
}
