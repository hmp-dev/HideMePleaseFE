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
      width: double.infinity, // Fill available width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGray,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey), // Gray border
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey, // Text color is gray
          ),
        ),
      ),
    );
  }
}
