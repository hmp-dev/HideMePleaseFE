// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/widgets.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';

class SBUFileIconComponent extends SBUStatelessComponent {
  final double size;
  final Color backgroundColor;
  final double iconSize;
  final IconData iconData;
  final Color iconColor;

  const SBUFileIconComponent({
    required this.size,
    required this.backgroundColor,
    required this.iconSize,
    required this.iconData,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.all((size - iconSize) / 2),
        child: SBUIconComponent(
          iconSize: iconSize,
          iconData: iconData,
          iconColor: iconColor,
        ),
      ),
    );
  }
}
