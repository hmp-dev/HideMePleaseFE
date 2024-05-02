import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class HMPCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const HMPCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundGr1,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: fontCompactMd(),
        ),
      ),
    );
  }
}
