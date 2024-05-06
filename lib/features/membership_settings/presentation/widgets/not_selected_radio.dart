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
        color: fore1,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: black500.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
