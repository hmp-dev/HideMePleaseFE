import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/events/presentation/views/event_detail_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.bannerImage});

  final String bannerImage;

  static push(BuildContext context, {required String bannerImage}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          bannerImage: bannerImage,
        ),
      ),
    );
  }

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      bottomNavigationBar: Container(
        color: Colors.black.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: HMPCustomButton(
          text: LocaleKeys.confirm.tr(),
          onPressed: () {},
        ),
      ),
      body: EventDetailView(
        onRefresh: () async {},
        bannerImage: widget.bannerImage,
      ),
    );
  }
}
