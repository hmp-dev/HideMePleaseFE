import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/env/app_env.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/core/util/observer_utils.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// [MyApp] is the root widget of the application.
///
/// It initializes the app state and sets the initial route.
/// The [isShowOnBoarding] parameter is used to determine whether to show the
/// onboarding screens at startup.
class MyApp extends StatefulWidget {
  // Initialize the key of the widget
  const MyApp({super.key, this.isShowOnBoarding});

  // Define the initial route to be shown when the app starts
  final int? isShowOnBoarding;

  // Override the createState method to create the state of the widget
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static FirebaseAnalyticsObserver firebaseAnalyticsObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  @override
  void initState() {
    ('FLAVOR: ${AppEnv.flavor}').log();
    super.initState();
  }

  @override

  /// [build] method is the main building block of a widget.
  /// It describes the part of the user interface represented by this widget.
  ///
  /// This method returns a [Widget] that displays the main page of the application.
  /// It uses various widgets such as [RepositoryProvider], [SolanaWalletProvider],
  /// [SendbirdUIKit], [MaterialApp], and others to build the UI.
  ///
  /// The [MaterialApp] widget is the root of the app's widget tree.
  /// It provides many features to the app, such as:
  /// - A [debugShowCheckedModeBanner] to show a banner when in debug mode.
  /// - A [navigatorKey] to manage the navigation of the app.
  /// - A [localizationsDelegates] to handle localization.
  /// - A [supportedLocales] to handle supported locales.
  /// - A [locale] to set the locale of the app.
  /// - A [title] to set the title of the app.
  /// - A [theme] to set the theme of the app.
  /// - An [onGenerateRoute] to generate routes for the app.
  /// - An [initialRoute] to set the initial route of the app.
  /// - An [navigatorObservers] to observe the navigation of the app.
  /// - A [builder] to build the app with additional features.
  Widget build(BuildContext context) {
    // Return the main page of the application
    return RepositoryProvider.value(
      // Provide the navigator key to the widget tree
      value: navigatorKey,
      child: MaterialApp(
        // Disable the debug banner
        debugShowCheckedModeBanner: false,
        // Set the navigator key for navigation
        navigatorKey: StackedService.navigatorKey,
        // Set the delegates for localization
        localizationsDelegates: context.localizationDelegates,
        // Set the supported locales
        supportedLocales: context.supportedLocales,
        // Set the locale of the app
        locale: context.locale,
        // Set the title of the app
        title: '하이드미플리즈', // Hyde Me Please
        // Set the theme of the app
        theme: theme(),
        // Generate routes for the app
        onGenerateRoute: generateRoute,
        // Set the initial route of the app
        initialRoute: Routes.splashScreen,
        // Observe the navigation of the app
        navigatorObservers: [
          firebaseAnalyticsObserver,
          // Observe the route changes
          ObserverUtils.routeObserver,
          // Observe the route changes using TalkerRouteObserver
          TalkerRouteObserver(getIt<Talker>()),
        ],
        // Build the app with additional features
        builder: EasyLoading.init(
          builder: FToastBuilder(),
        ),
      ),
    );
  }
}
