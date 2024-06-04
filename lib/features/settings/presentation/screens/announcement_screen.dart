import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/presentation/screens/announcement_detail_screen.dart';
import 'package:mobile/features/settings/presentation/widgets/announcement_feature_tile.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnnouncementScreen(),
      ),
    );
  }

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  bool isNotificationEnabled = false;
  bool isLocationInfoEnabled = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.announcement.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: announcements.length,
                itemBuilder: (context, index) => AnnouncementFeatureTile(
                  title: announcements[index].title,
                  subTitle: announcements[index].date,
                  onTap: () {
                    AnnouncementDetailScreen.push(
                        context, announcements[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
