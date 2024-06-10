import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class HMPCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;
  final double height;

  const HMPCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor = backgroundGr1,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: Text(
              text,
              style: fontCompactMd(),
            ),
          ),
        ),
      ),
    );
  }
}
