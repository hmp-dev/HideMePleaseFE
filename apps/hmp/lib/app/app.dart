import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
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
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:talker_flutter/talker_flutter.dart';

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
    ('FLAVOR: ${AppEnv.flavor}').log();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: navigatorKey,
      child: SolanaWalletProvider.create(
        httpCluster: Cluster.mainnet,
        identity: kSolanaAppId,
        child: SendbirdUIKit.provider(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: StackedService.navigatorKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: '하이드미플리즈', //Hyde Me Please
            theme: theme(),
            onGenerateRoute: generateRoute,
            initialRoute: Routes.splashScreen,
            navigatorObservers: [
              ObserverUtils.routeObserver,
              //FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
              TalkerRouteObserver(getIt<Talker>()),
            ],
            builder: EasyLoading.init(
              builder: FToastBuilder(),
            ),
          ),
        ),
      ),
    );
  }
}
