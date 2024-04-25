import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class SelectedRadio extends StatelessWidget {
  const SelectedRadio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      decoration: const BoxDecoration(
        color: hmpBlue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          height: 10,
          width: 10,
          decoration: const BoxDecoration(
            color: white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
