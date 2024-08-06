import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/notifications_cubit.dart';
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
