import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class NotSelectedRadio extends StatelessWidget {
  const NotSelectedRadio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFE1E4E9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          height: 18,
          width: 18,
          decoration: const BoxDecoration(
            color: white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
