import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class ThickDivider extends StatelessWidget {
  const ThickDivider({
    super.key,
    this.paddingTop = 20,
    this.paddingBottom = 20,
  });

  final double paddingTop;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
      child: const Divider(
        color: bgNega5,
        height: 8,
        thickness: 8,
      ),
    );
  }
}
