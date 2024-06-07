import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class RoundedButtonWithBorder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;

  const RoundedButtonWithBorder({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor = bg1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54, // Fill available width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: fore4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: fontCompactMdMedium(),
        ),
      ),
    );
  }
}
