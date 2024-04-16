import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/theme/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.isShowOnBoarding});

  final int? isShowOnBoarding;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    Log.info('FLAVOR: ${AppEnv.flavor}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: '공유용',
        theme: theme(),
        //initialRoute: ,
        initialRoute:
            widget.isShowOnBoarding == 0 || widget.isShowOnBoarding == null
                ? Routes.onboardingScreen
                : Routes.startUpScreen,
        onGenerateRoute: generateRoute,
        navigatorObservers: const [
          //FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        builder: EasyLoading.init(
          builder: FToastBuilder(),
        ),
      ),
    );
  }
}
