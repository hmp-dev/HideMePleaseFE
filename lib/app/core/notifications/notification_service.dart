import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationServices {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final ProfileRepository _userRepository;

  static final NotificationServices instance = NotificationServices._();

  NotificationServices._()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(),
        _messaging = FirebaseMessaging.instance,
        _userRepository = getIt<ProfileRepository>();

  bool _canReceiveNotification = false;

  Future<void> initialize() async {
    final hasPermission = await requestNotificationPermission();
    if (hasPermission) {
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        ('apnsToken: $apnsToken').log();

        _canReceiveNotification = apnsToken != null;
        if (_canReceiveNotification) {
          await FirebaseMessaging.instance
              .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      } else {
        _canReceiveNotification = true;
      }

      if (_canReceiveNotification) {
        // FirebaseMessaging.onBackgroundMessage(
        //     _firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessage.listen((message) {
          ("notifications title:${message.notification?.title}").log();
          ("notifications body:${message.notification?.body}").log();
          ('count:${message.notification?.android?.count}').log();
          ('data:${message.data.toString()}').log();

          if (Platform.isAndroid) {
            _initLocalNotifications(message);
            _showNotification(message);
          }
        });

        getDeviceToken().then((fcmToken) {
          if (fcmToken != null) {
            _userRepository.updateProfileData(
              updateProfileRequestDto:
                  UpdateProfileRequestDto(fcmToken: fcmToken),
            );
          }
        });

        _messaging.onTokenRefresh.listen((fcmToken) {
          _userRepository.updateProfileData(
            updateProfileRequestDto:
                UpdateProfileRequestDto(fcmToken: fcmToken),
          );
        });

        _setupInteractMessage();
      }
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        provisional: true,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      ('Error requesting notification permission: $e').log();
      return false;
    }
  }

  Future<String?> getDeviceToken() => _messaging.getToken();

  Future<void> _setupInteractMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage?.data != null) {
      _handleMessageAction(initialMessage!.data);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageAction(message.data);
    });

    _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((details) {
      if (details?.notificationResponse?.payload != null) {
        _handleMessageAction(
            jsonDecode(details!.notificationResponse!.payload!));
      }
    });
  }

  void _handleMessageAction(Map<String, dynamic> payload) {
    ('Message Action payload: $payload').log();
  }

  int _notificationCounter = 0;

  void _initLocalNotifications(RemoteMessage message) async {
    const initializationSetting = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (notificationResponse) {
      _handleMessageAction(jsonDecode(notificationResponse.payload!));
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const channel = AndroidNotificationChannel(
      'default',
      'Default',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    final androidNotificationDetails = AndroidNotificationDetails(
        channel.id, channel.name,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
        sound: channel.sound);

    const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    final notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    if (message.notification?.title != null &&
        message.notification?.body != null) {
      _flutterLocalNotificationsPlugin.show(
        _notificationCounter++,
        message.notification!.title!,
        message.notification!.body!,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    }
  }
}
