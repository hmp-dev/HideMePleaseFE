import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      backgroundColor: backgroundGr1,
      body: Center(
        child: Lottie.asset(
          "assets/lottie/check.json",
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() async {
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) {
                  //navigate back
                  Navigator.pop(context, true);
                }
              });
          },
        ),
      ),
    );
  }
}
