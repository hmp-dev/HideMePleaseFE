import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class InfoTextToolTipWidget extends StatelessWidget {
  const InfoTextToolTipWidget({
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
        height: 96,
        width: 231,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(0xFF4E4E55),
            border: Border.all(color: fore5),
            borderRadius: BorderRadius.circular(4)),
        child: Text(
          title,
          style: fontBodySm(),
        ),
      ),
    );
  }
}
