import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  ("notifications title:${message.notification?.title}").log();
  ("notifications body:${message.notification?.body}").log();
  ('count:${message.notification?.android?.count}').log();
  ('data:${message.data.toString()}').log();
  await Firebase.initializeApp();
}

enum NotificationType { none, spot, chat, match, matchingComplete }

class NotificationServices {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final ProfileRepository _profileRepository;

  static final NotificationServices instance = NotificationServices._();

  NotificationServices._()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(),
        _messaging = FirebaseMessaging.instance,
        _profileRepository = getIt<ProfileRepository>();

  bool _canReceiveNotification = false;
  bool _isChatPageActive = false;

  void Function(NotificationType type, String payloadId)? onNotificationTap;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;

  static final List<NotificationActionPayload> _processedNotificationPayloads =
      [];
  
  // 중복 푸시 필터링을 위한 캐시
  static final Set<String> _recentMessageIds = {};
  static final Map<String, DateTime> _messageTimestamps = {};
  static const Duration _duplicateWindowDuration = Duration(seconds: 30);

  Future<void> initialize({
    void Function(NotificationType type, String payloadId)? onNotificationTap,
  }) async {
    this.onNotificationTap = onNotificationTap;

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
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        _initLocalNotifications();

        _onMessageSubscription?.cancel();
        _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
          // 메시지 ID 생성 (FCM messageId 또는 데이터 기반 해시)
          final messageId = message.messageId ?? 
              '${message.notification?.title}_${message.notification?.body}_${message.data['type']}_${message.data['id']}';
          
          // 중복 메시지 체크
          if (_isDuplicateMessage(messageId)) {
            ('🔄 중복 푸시 감지 및 무시: $messageId').log();
            ('   - Title: ${message.notification?.title}').log();
            ('   - Type: ${message.data['type']}').log();
            return; // 중복 메시지는 처리하지 않음
          }
          
          // 메시지 ID 캐시에 추가
          _cacheMessageId(messageId);
          
          ("📱 새로운 푸시 수신: $messageId").log();
          ("notifications title:${message.notification?.title}").log();
          ("notifications body:${message.notification?.body}").log();
          ('count:${message.notification?.android?.count}').log();
          ('data:${message.data.toString()}').log();

          // 체크인 관련 푸시는 이미 시스템 푸시로 표시되므로 로컬 알림 표시하지 않음
          bool isCheckInNotification = message.data['type'] == 'CHECK_IN' || 
                                       message.data['type'] == 'CHECK_IN_SUCCESS' ||
                                       message.data['type'] == 'MATCHING_COMPLETE' ||
                                       (message.notification?.title?.contains('체크인') ?? false) ||
                                       (message.notification?.body?.contains('체크인') ?? false) ||
                                       (message.notification?.title?.contains('매칭') ?? false) ||
                                       (message.notification?.body?.contains('매칭') ?? false) ||
                                       (message.notification?.title?.contains('체크아웃') ?? false) ||
                                       (message.notification?.body?.contains('체크아웃') ?? false);

          if (!isCheckInNotification && 
              (!_isChatPageActive ||
              (_isChatPageActive &&
                  message.data['type'] != 'MESSAGE_RECEIVED'))) {
            _showNotification(message);
          } else if (isCheckInNotification) {
            ('🔕 체크인 알림은 로컬 알림으로 표시하지 않음 (중복 방지)').log();
          }
        });

        getDeviceToken().then((fcmToken) {
          if (fcmToken != null) {
            _profileRepository.updateProfileData(
              updateProfileRequestDto:
                  UpdateProfileRequestDto(fcmToken: fcmToken),
            );
          }
        });

        _messaging.onTokenRefresh.listen((fcmToken) {
          _profileRepository.updateProfileData(
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
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      ('Error requesting notification permission: $e').log();
      return false;
    }
  }

  void setChatActive() {
    _isChatPageActive = true;
  }

  void setChatInactive() {
    _isChatPageActive = false;
  }

  Future<String?> getDeviceToken() async {
    final fcmToken = await _messaging.getToken();
    ("fcmToken: $fcmToken").log();
    return fcmToken;
  }

  Future<void> _setupInteractMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage?.notification != null && initialMessage?.data != null) {
      ('NOTI::initialMessage ${initialMessage?.data}').log();
      handleMessageAction(
          NotificationActionPayload.fromJson(initialMessage!.data).copyWith(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      ));
    }

    _onMessageOpenedSubscription?.cancel();
    _onMessageOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      ('NOTI::onMessageOpenedApp $message').log();

      handleMessageAction(
          NotificationActionPayload.fromJson(message.data).copyWith(
        title: message.notification?.title,
        body: message.notification?.body,
      ));
    });
  }

  static void handleMessageAction(NotificationActionPayload payload) {
    if (!_processedNotificationPayloads.contains(payload)) {
      ('NOTI::Message Action payload: $payload').log();
      _processedNotificationPayloads.add(payload);

      if (payload.type == 'MESSAGE_RECEIVED' && payload.isSpot!) {
        instance.onNotificationTap?.call(NotificationType.spot, payload.id!);
      } else if (payload.type == 'MESSAGE_RECEIVED') {
        instance.onNotificationTap?.call(NotificationType.chat, payload.id!);
      } else if (payload.type == 'MATCHING_COMPLETE') {
        ('🎯 Matching complete notification received').log();
        instance.onNotificationTap?.call(NotificationType.matchingComplete, payload.id ?? '');
      }
    }
  }

  int _notificationCounter = 0;

  void _initLocalNotifications() async {
    const initializationSetting = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/launcher_icon'),
      iOS: DarwinInitializationSettings(),
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting);
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
      channel.id,
      channel.name,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      sound: channel.sound,
      icon: '@drawable/launcher_icon',
      largeIcon:
          const DrawableResourceAndroidBitmap('@drawable/ic_launcher_color'),
    );

    const darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    if (message.notification?.title != null &&
        message.notification?.body != null) {
      _flutterLocalNotificationsPlugin.show(
        _notificationCounter++,
        message.notification!.title!,
        message.notification!.body!,
        notificationDetails,
        payload: jsonEncode({
          'title': message.notification?.title,
          'body': message.notification?.body,
          ...message.data,
        }),
      );
    }
  }
  
  // 중복 메시지 체크 헬퍼 메서드들
  bool _isDuplicateMessage(String messageId) {
    // 이미 처리한 메시지인지 확인
    if (_recentMessageIds.contains(messageId)) {
      return true;
    }
    
    // 오래된 메시지 ID 정리
    _cleanupOldMessageIds();
    
    return false;
  }
  
  void _cacheMessageId(String messageId) {
    _recentMessageIds.add(messageId);
    _messageTimestamps[messageId] = DateTime.now();
  }
  
  void _cleanupOldMessageIds() {
    final now = DateTime.now();
    final expiredIds = <String>[];
    
    _messageTimestamps.forEach((id, timestamp) {
      if (now.difference(timestamp) > _duplicateWindowDuration) {
        expiredIds.add(id);
      }
    });
    
    // 오래된 ID들 제거
    for (final id in expiredIds) {
      _recentMessageIds.remove(id);
      _messageTimestamps.remove(id);
    }
  }
}

class NotificationActionPayload extends Equatable {
  final String? type;
  final String? id;
  final bool? isSpot;
  final String? title;
  final String? body;

  const NotificationActionPayload({
    this.type,
    this.id,
    this.isSpot,
    this.title,
    this.body,
  });

  @override
  List<Object?> get props => [type, id, isSpot, title, body];

  factory NotificationActionPayload.fromJson(Map<String, dynamic> map) {
    return NotificationActionPayload(
      type: map['type'],
      id: map['id'],
      isSpot: map['isSpot'] == 'true',
      title: map['title'],
      body: map['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'isSpot': isSpot.toString(),
      'title': title,
      'body': body,
    };
  }

  NotificationActionPayload copyWith({
    String? type,
    String? id,
    bool? isSpot,
    String? title,
    String? body,
  }) {
    return NotificationActionPayload(
      type: type ?? this.type,
      id: id ?? this.id,
      isSpot: isSpot ?? this.isSpot,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }
}
