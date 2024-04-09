import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale:
          AppEnv.flavor.isProd && kReleaseMode ? const Locale('ko') : null,
      useOnlyLangCode: true,
      child: DevicePreview(
        enabled: false,
        builder: (_) => const MyApp(),
      ),
    ),
  );

  FlutterNativeSplash.remove();
}

Future initApp() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // DI
  await configureDependencies();

  await Future.wait([
    // Firebase
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),

    // Localization
    EasyLocalization.ensureInitialized(),

    // Chat
    //TalkPlusAPI.init(appEnv.talkplusApiKey),

    // App
    // getIt<AppCubit>().onStart(),
  ]);

  Log.configureLogger();

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
    ..indicatorWidget = const SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(color: Colors.white),
    )
    ..boxShadow = <BoxShadow>[]
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid;
}
