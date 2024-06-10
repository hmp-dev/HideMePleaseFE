import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
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
      body: BlocConsumer<SettingsCubit, SettingsState>(
        bloc: getIt<SettingsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.announcements.length,
                      itemBuilder: (context, index) => AnnouncementFeatureTile(
                        title: state.announcements[index].title,
                        createdAt: state.announcements[index].createdAt,
                        onTap: () {
                          AnnouncementDetailScreen.push(
                              context, state.announcements[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
