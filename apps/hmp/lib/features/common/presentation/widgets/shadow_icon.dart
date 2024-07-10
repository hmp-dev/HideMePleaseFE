import 'dart:ui';

import 'package:flutter/material.dart';

class ShadowIcon extends StatelessWidget {
  const ShadowIcon({
    super.key,
    required this.icon,
  });
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 2.0,
          left: 2.0,
          child: icon,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: icon,
        ),
      ],
    );
  }
}
