import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class Fore3TextButton extends StatelessWidget {
  const Fore3TextButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: fontCompactSmMedium(color: fore3),
        ),
      ),
    );
  }
}
