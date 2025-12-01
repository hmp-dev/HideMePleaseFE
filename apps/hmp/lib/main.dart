import 'package:bloc/bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/helpers/shared_preferences_keys.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/localisation/ko_timeago_messages.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/firebase_options.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:geolocator/geolocator.dart';

/// init Screen bool
/// check if it is first time App is launched by user

int? isShowOnBoarding;

String? _userSavedLanguageCode;

// Background task callback - must be top-level or static
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Flutter engine for background isolate
    // This is required for plugins like SharedPreferences to work in background
    WidgetsFlutterBinding.ensureInitialized();

    print('💓 Background task executing: $task');

    try {
      // Initialize dependencies for background context
      await configureDependencies();

      // Get stored check-in data
      final prefs = await SharedPreferences.getInstance();
      final spaceId = prefs.getString('currentCheckedInSpaceId');

      if (spaceId == null) {
        print('📍 No active check-in in background task');
        return Future.value(true);
      }

      // Check location permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('❌ Location permission not granted for background task');
        return Future.value(false);
      }

      // Get current position with timeout
      Position currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );
      } catch (e) {
        print('⚠️ Failed to get position with high accuracy, trying with low accuracy');
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 15),
        );
      }

      // Send heartbeat with retry logic
      final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
      int retryCount = 0;
      const maxRetries = 3;
      bool heartbeatSent = false;

      while (retryCount < maxRetries && !heartbeatSent) {
        try {
          await spaceRemoteDataSource.sendCheckInHeartbeat(
            spaceId: spaceId,
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude,
          );
          heartbeatSent = true;
          print('✅ Background heartbeat sent successfully');
        } catch (e) {
          retryCount++;
          print('⚠️ Heartbeat attempt $retryCount failed: $e');
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 2 * retryCount));
          }
        }
      }

      if (!heartbeatSent) {
        print('❌ Failed to send heartbeat after $maxRetries attempts');
      }

      // Check distance from check-in location
      final checkInLat = prefs.getDouble('checkInLatitude');
      final checkInLng = prefs.getDouble('checkInLongitude');

      if (checkInLat != null && checkInLng != null) {
        final distance = Geolocator.distanceBetween(
          checkInLat,
          checkInLng,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        print('📏 Distance from check-in: ${distance.toStringAsFixed(2)}m');

        // Auto check-out if too far
        if (distance > 50.0) {
          print('🚨 User moved beyond 50m in background, triggering auto check-out');

          try {
            // Perform auto check-out directly
            await spaceRemoteDataSource.checkOut(spaceId: spaceId);

            // Clear all check-in data after successful check-out
            await prefs.remove('currentCheckedInSpaceId');
            await prefs.remove('checkInLatitude');
            await prefs.remove('checkInLongitude');

            // Cancel the OneTime task chaining since we're checked out
            await Workmanager().cancelByTag('heartbeat');
            await Workmanager().cancelByUniqueName('check-in-heartbeat');

            print('✅ Auto check-out completed from background task');
          } catch (e) {
            print('❌ Failed to auto check-out from background: $e');
            // Mark for check-out on app restart if background check-out fails
            await prefs.setBool('shouldAutoCheckOut', true);
            await prefs.setString('pendingCheckOutSpaceId', spaceId);

            // Don't schedule next heartbeat if check-out failed
            // User should manually resolve on app restart
            return Future.value(true);
          }
        } else {
          // Still within range - schedule next backup heartbeat
          print('📅 User within range, scheduling next backup heartbeat in 3 minutes');
          await Workmanager().registerOneOffTask(
            'check-in-heartbeat',
            'checkInHeartbeat',
            initialDelay: const Duration(minutes: 3),
            constraints: Constraints(
              networkType: NetworkType.connected,
            ),
            tag: 'heartbeat',
          );
          print('✅ Next backup heartbeat scheduled (within range check)');
        }
      }
    } catch (e) {
      print('❌ Background task error: $e');

      // Even on error, try to schedule next heartbeat if check-in data still exists
      final prefs = await SharedPreferences.getInstance();
      final spaceId = prefs.getString('currentCheckedInSpaceId');

      if (spaceId != null) {
        print('📅 Error occurred but check-in active, scheduling next backup heartbeat in 3 minutes');
        try {
          await Workmanager().registerOneOffTask(
            'check-in-heartbeat',
            'checkInHeartbeat',
            initialDelay: const Duration(minutes: 3),
            constraints: Constraints(
              networkType: NetworkType.connected,
            ),
            tag: 'heartbeat',
          );
          print('✅ Next backup heartbeat scheduled despite error');
        } catch (scheduleError) {
          print('❌ Failed to schedule next heartbeat: $scheduleError');
        }
      }
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure the Google Maps Android implementation is using the correct renderer.
  // This is needed to avoid texture flickering issues on some devices.
  // This should be called before any other Google Maps related code.
  // See: https://github.com/flutter/flutter/issues/105124
  // And: https://github.com/flutter/flutter/issues/102646
  final GoogleMapsFlutterPlatform platform = GoogleMapsFlutterPlatform.instance;
  if (platform is GoogleMapsFlutterAndroid) {
    platform.useAndroidViewSurface = true;
  }

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Setting an Int value for initScreen
  /// To show the Intro Screens at Start
  isShowOnBoarding = await getInitialScreen();

  timeago.setLocaleMessages('ko', KoTimeAgoMessages());

  // Detect device language using PlatformDispatcher
  final Locale deviceLocale = PlatformDispatcher.instance.locale;
  _userSavedLanguageCode =
      await SharedPreferencesKeys().getStringData(key: 'language_type');

  "user saved locale $_userSavedLanguageCode".log();
  "user Device locale $deviceLocale".log();

  await initApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: AppEnv.flavor.isProd && kReleaseMode
          ? _userSavedLanguageCode != null
              ? Locale(_userSavedLanguageCode!)
              : deviceLocale
          : _userSavedLanguageCode != null
              ? Locale(_userSavedLanguageCode!)
              : deviceLocale,
      useOnlyLangCode: true,
      child: DevicePreview(
        enabled: false,
        builder: (_) => MyApp(
          isShowOnBoarding: isShowOnBoarding,
        ),
      ),
    ),
  );

  FlutterNativeSplash.remove();
}

/// Initializes the app by setting preferred screen orientations,
/// configuring dependencies, initializing Firebase and localization,
/// configuring Firebase Crashlytics, configuring the logger,
/// and setting the Bloc observer.
Future initApp() async {
  // Set preferred screen orientations for the app
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure the necessary dependencies for the app
  await configureDependencies();

  // Initialize Workmanager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode, // Shows notifications in debug mode
  );
  print('✅ Workmanager initialized');

  // Initialize Firebase and localization
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    EasyLocalization.ensureInitialized(),
  ]);

  // Initialize Firebase Crashlytics and configure error reporting
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Custom FlutterError handler to prevent non-critical crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionString = details.exception.toString();

    // UI Overflow 에러는 크래시 없이 로깅만 (치명적이지 않음)
    if (exceptionString.contains('overflowed') ||
        exceptionString.contains('RenderFlex')) {
      debugPrint('⚠️  UI Overflow detected (non-fatal): ${details.exception}');
      debugPrint('   Stack: ${details.stack}');
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // 이미지 로딩 에러도 크래시 없이 처리
    if (exceptionString.contains('Invalid image data') ||
        exceptionString.contains('Failed to load network image') ||
        exceptionString.contains('HttpException') ||
        exceptionString.contains('Unable to load asset')) {
      debugPrint('⚠️  Image loading error (non-fatal): ${details.exception}');
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // ListView/GridView 관련 assertion 에러 (Sliver 위젯)
    if (exceptionString.contains('RenderSliverMultiBoxAdaptor') ||
        exceptionString.contains('_debugVerifyChildOrder') ||
        exceptionString.contains('indexOf(child) > index')) {
      debugPrint('⚠️  Sliver child ordering issue (non-fatal): ${details.exception}');
      debugPrint('   This is usually caused by ListView/GridView key management');
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // Focus 관련 assertion 에러 (InheritedElement)
    if (exceptionString.contains('_dependents.isEmpty') ||
        exceptionString.contains('InheritedElement') ||
        exceptionString.contains('FocusInheritedScope')) {
      debugPrint('⚠️  Focus widget lifecycle issue (non-fatal): ${details.exception}');
      debugPrint('   This is usually caused by improper widget disposal');
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // 일반적인 Flutter assertion 에러들 (개발 모드에서만 발생)
    if (exceptionString.contains('Failed assertion:') &&
        (exceptionString.contains('is not true') ||
         exceptionString.contains('is not false'))) {
      debugPrint('⚠️  Flutter assertion failed (non-fatal): ${details.exception}');
      debugPrint('   Library: ${details.library}');
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // Null check operator 에러 포괄 처리
    if (exceptionString.contains('Null check operator used on a null value')) {
      debugPrint('⚠️  Null check error (non-fatal): ${details.exception}');

      // 발생 위치 파악을 위한 상세 로깅
      if (exceptionString.contains('RenderViewport')) {
        debugPrint('   Location: RenderViewport (스크롤 뷰 렌더링)');
      } else if (exceptionString.contains('RenderSliver')) {
        debugPrint('   Location: RenderSliver (리스트 아이템 렌더링)');
      } else if (exceptionString.contains('paint()')) {
        debugPrint('   Location: paint() (위젯 그리기)');
      } else if (exceptionString.contains('performLayout()')) {
        debugPrint('   Location: performLayout() (레이아웃 계산)');
      }

      debugPrint('   Context: ${details.context}');
      debugPrint('   Library: ${details.library}');

      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // RenderErrorBox 에러 (ErrorWidget가 잘못된 타입으로 렌더링됨)
    if (exceptionString.contains('RenderErrorBox') ||
        exceptionString.contains('expected a child of type')) {
      debugPrint('⚠️  Widget type mismatch (non-fatal): ${details.exception}');
      debugPrint('   This usually happens when an error widget is incorrectly placed');
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: details.exception,
          stack: details.stack,
          library: details.library,
          context: details.context,
          informationCollector: details.informationCollector,
          silent: true,
        ),
      );
      return;
    }

    // 그 외 치명적인 에러는 Crashlytics에 기록하고 크래시
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  // Configure the logger for the app
  Log.configureLogger();

  // Configure the loading indicator for the app
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 60
    ..textColor = Colors.black
    ..radius = 20
    ..backgroundColor = Colors.transparent
    ..maskColor = Colors.white
    ..indicatorColor = Colors.black54
    ..userInteractions = false
    ..dismissOnTap = false
    ..indicatorWidget = Container(
      child: Lottie.asset(
        'assets/lottie/loader.json',
      ),
    )
    ..boxShadow = <BoxShadow>[]
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid;

  // Get the Talker instance from the dependency injection container
  final talker = getIt<Talker>();

  // Configure the Bloc observer for the app (disabled for debugging)
  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      enabled: false, // BLoC 로그 비활성화
      printEventFullData: false,
      printStateFullData: false,
      printChanges: false,
      printClosings: false,
      printCreations: false,
      printEvents: false,
      printTransitions: false,
    ),
  );
}
