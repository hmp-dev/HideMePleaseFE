import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/settings/domain/entities/announcement_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// Widget that displays the details of an announcement.
///
/// This widget is responsible for displaying the details of an announcement.
/// It takes an [AnnouncementEntity] as a parameter in its constructor.
/// The [AnnouncementEntity] contains the details of the announcement to be displayed.
class AnnouncementDetailScreen extends StatefulWidget {
  /// Constructor for [AnnouncementDetailScreen].
  ///
  /// Takes an [AnnouncementEntity] as a required parameter.
  const AnnouncementDetailScreen({super.key, required this.announcement});

  /// The announcement to be displayed.
  final AnnouncementEntity announcement;

  /// Pushes the [AnnouncementDetailScreen] to the navigation stack.
  ///
  /// Takes a [BuildContext] and an [AnnouncementEntity] as parameters.
  /// Returns a [Future] that resolves to the result of the navigation.
  static Future<dynamic> push(
    BuildContext context,
    AnnouncementEntity announcement,
  ) async {
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
  Future<Uint8List?> _fetchImage(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        ('Failed to load image: ${response.statusCode}').log();
      }
    } catch (e) {
      ('Error fetching image: $e').log();
    }
    return null;
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      customWidgetBuilder: (element) {
                        if (element.localName == 'img') {
                          final src = element.attributes['src'];
                          if (src != null) {
                            return FutureBuilder<Uint8List?>(
                              future: _fetchImage(src),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                } else if (snapshot.hasError) {
                                  return const SizedBox.shrink();
                                } else if (snapshot.hasData) {
                                  return Image.memory(snapshot.data!);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            );
                          }
                        }
                        return null;
                      },
                      textStyle: fontBodySm(color: fore2),
                    ),
                    if (widget.announcement.id ==
                        "bba8f741-4184-4851-9d7c-b4bf50cd9c9a")
                      CustomImageView(
                        imagePath: "assets/images/announcement-img.png",
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
