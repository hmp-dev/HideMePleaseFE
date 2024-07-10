import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/domain/entities/announcement_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final AnnouncementEntity announcement;

  static push(BuildContext context, AnnouncementEntity announcement) async {
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
                        getCreatedAt(widget.announcement.createdAt),
                        style: fontCompactXs(color: fore3),
                      ),
                    ],
                  ),
                  const VerticalSpace(20),
                  HtmlWidget(
                    widget.announcement.description,
                    textStyle: fontBodySm(color: fore2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
