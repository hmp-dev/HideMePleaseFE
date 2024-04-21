import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class ButtonSmall extends StatelessWidget {
  const ButtonSmall({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 115,
        decoration: const BoxDecoration(
          color: black200,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: fontM(16, lineHeight: 1.3, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
