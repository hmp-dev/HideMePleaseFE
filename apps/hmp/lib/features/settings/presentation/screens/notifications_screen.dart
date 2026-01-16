import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/notifications_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/views/notifications_view.dart';

/// `NotificationsScreen` is a stateful widget that represents the screen for managing user notifications.
/// It uses the [StatefulWidget] class to manage its state and the [State] class to handle its state.
///
/// The screen has a [push] method that allows other screens to navigate to it.
/// When this screen is pushed, it builds a [MaterialPageRoute] with a [const NotificationsScreen()] builder.
///
/// The screen has a [createState] method that creates a new instance of the [_NotificationsScreenState] class,
/// which is responsible for managing the state of this screen.
class NotificationsScreen extends StatefulWidget {
  /// Creates a new instance of the [NotificationsScreen] widget.
  const NotificationsScreen({super.key});

  /// Pushes the [NotificationsScreen] to the navigation stack.
  ///
  /// Takes a [BuildContext] as a parameter.
  /// Returns a [Future] that resolves to the result of the navigation.
  static Future<dynamic> push(BuildContext context) async {
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
    super.initState();
    print('🔔 [NotificationsScreen] initState called');
    final notificationsCubit = getIt<NotificationsCubit>();
    print('🔔 [NotificationsScreen] Got NotificationsCubit instance');

    // 알림 목록 로드 (unreadCount 업데이트 안 함)
    notificationsCubit.onStart(updateUnreadCount: false).then((_) {
      // 알림 목록 로드 후 모든 알림을 읽음 처리
      notificationsCubit.markAllAsRead();
      print('🔔 [NotificationsScreen] markAllAsRead() completed');
    });

    // 공지사항 로드 (일주일 이내 공지 위젯 표시용)
    getIt<SettingsCubit>().onGetAnnouncements();
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
