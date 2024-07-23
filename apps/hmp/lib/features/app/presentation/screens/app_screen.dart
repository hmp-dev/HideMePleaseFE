import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/views/app_view.dart';
import 'package:mobile/features/common/presentation/widgets/open_talker_logs_button.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
      },
      child: const Scaffold(
        backgroundColor: scaffoldBg,
        body: kDebugMode
            ? Stack(
                children: [
                  AppView(),
                  Positioned(
                    right: 30,
                    top: 100,
                    child: OpenTalkerLogsButton(),
                  ),
                ],
              )
            : Stack(
                children: [
                  AppView(),
                  // Positioned(
                  //   right: 30,
                  //   top: 100,
                  //   child: OpenTalkerLogsButton(),
                  // ),
                ],
              ),
      ),
    );
  }
}
