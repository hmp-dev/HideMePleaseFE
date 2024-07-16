// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/widgets.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';

class SBUIconComponent extends SBUStatefulComponent {
  final double iconSize;
  final IconData iconData;
  final Color iconColor;

  const SBUIconComponent({
    required this.iconSize,
    required this.iconData,
    required this.iconColor,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUIconComponentState();
}

class SBUIconComponentState extends State<SBUIconComponent> {
  @override
  Widget build(BuildContext context) {
    final iconSize = widget.iconSize;
    final iconData = widget.iconData;
    final iconColor = widget.iconColor;

    return Icon(
      iconData,
      size: iconSize,
      color: iconColor,
    );
  }
}
