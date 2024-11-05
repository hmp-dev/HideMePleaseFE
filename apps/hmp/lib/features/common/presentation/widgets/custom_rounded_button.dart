import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class CustomRoundedButton extends StatelessWidget {
  const CustomRoundedButton({
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
        width: context.locale == const Locale('en') ? 190 : 190,
        decoration: const BoxDecoration(
          color: black,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: fontCompactMdMedium(),
            ),
          ),
        ),
      ),
    );
  }
}
