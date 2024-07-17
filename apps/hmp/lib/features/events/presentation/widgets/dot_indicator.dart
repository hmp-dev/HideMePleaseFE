import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class DotIndicator extends StatelessWidget {
  final int listSize;
  final int activeIndex;

  const DotIndicator(
      {super.key, required this.listSize, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 10,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: listSize,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 10),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == activeIndex ? hmpBlue : fore3,
              ),
            );
          },
        ),
      ),
    );
  }
}
