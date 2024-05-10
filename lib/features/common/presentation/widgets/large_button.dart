import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class LargeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;

  const LargeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor = black200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
