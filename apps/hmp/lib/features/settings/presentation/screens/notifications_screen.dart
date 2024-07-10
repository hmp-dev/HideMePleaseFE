import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/settings/presentation/views/notifications_view.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    getIt<NotificationsCubit>().onStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: getIt<NotificationsCubit>(),
      builder: (context, state) {
        return NotificationsView(
          onRefresh: () => getIt<NotificationsCubit>().onStart(),
          notifications: state.notifications,
        );
      },
    );
  }
}
