import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class PageDotIndicator extends StatelessWidget {
  final int length;
  final int selectedIndex;

  const PageDotIndicator({
    super.key,
    required this.length,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == selectedIndex ? hmpBlue : Colors.grey,
          ),
        );
      }),
    );
  }
}
