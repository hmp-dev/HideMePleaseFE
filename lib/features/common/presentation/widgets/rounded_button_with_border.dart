import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class RoundedButtonWithBorder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const RoundedButtonWithBorder({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54, // Fill available width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg1,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: fore4), // Gray border
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
