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

/// init Screen bool
/// check if it is first time App is launched by user

int? isShowOnBoarding;

String? _userSavedLanguageCode;
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize Firebase and localization
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    EasyLocalization.ensureInitialized(),
  ]);

  // Initialize Firebase Crashlytics and configure error reporting
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

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
