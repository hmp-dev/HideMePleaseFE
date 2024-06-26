import 'dart:ui';

import 'package:flutter/material.dart';

class ShadowText extends StatelessWidget {
  const ShadowText({
    super.key,
    required this.style,
    required this.data,
  });
  final String data;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            top: 2.0,
            left: 2.0,
            child: Text(
              data,
              style: style.copyWith(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Text(data, style: style),
          ),
        ],
      ),
    );
  }
}
