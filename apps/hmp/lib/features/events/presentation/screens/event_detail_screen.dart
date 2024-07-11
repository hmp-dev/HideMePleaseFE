import 'package:flutter/material.dart';
import 'package:mobile/features/events/presentation/views/event_detail_view.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EventDetailScreen(),
      ),
    );
  }

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return EventDetailView(
      onRefresh: () async {},
    );
  }
}
