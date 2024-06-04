import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final Announcement announcement;

  static push(BuildContext context, Announcement announcement) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    );
  }

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.announcement.title,
                        style: fontTitle05Bold(),
                      ),
                      const VerticalSpace(3),
                      Text(
                        widget.announcement.date,
                        style: fontCompactXs(color: fore3),
                      ),
                    ],
                  ),
                  const AnnouncementInfoWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementInfoWidget extends StatelessWidget {
  const AnnouncementInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '홀덤을 사랑하는 사람들을 위한 바 아지트! 맛있는 음식과 와인, 위스키를 마실 수 있으며 홀덤 러버들을 위한 테이블까지!',
            style: fontBodySm(color: fore2),
          ),
          const SizedBox(height: 16.0),
          buildUnorderedListItem('위치: 서울 서초구 강남대로 99길 25, 2층'),
          buildUnorderedListItem('영업시간: 20:00~01:00 오늘도 숨어로 오세요!'),
        ],
      ),
    );
  }
}

Widget buildUnorderedListItem(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '•',
          style: TextStyle(fontSize: 16.0, color: fore2),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: fontBodySm(color: fore2),
          ),
        ),
      ],
    ),
  );
}
