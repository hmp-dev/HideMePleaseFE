// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';

class SBUIconButtonComponent extends SBUStatefulComponent {
  final double iconButtonSize;
  final SBUIconComponent icon;
  final void Function()? onButtonClicked;

  const SBUIconButtonComponent({
    required this.iconButtonSize,
    required this.icon,
    this.onButtonClicked,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUIconButtonComponentState();
}

class SBUIconButtonComponentState extends State<SBUIconButtonComponent> {
  @override
  Widget build(BuildContext context) {
    final iconButtonSize = widget.iconButtonSize;
    final icon = widget.icon;
    final onButtonClicked = widget.onButtonClicked;

    return IconButton(
      icon: icon,
      onPressed: onButtonClicked,
      padding: EdgeInsets.all((iconButtonSize - icon.iconSize) / 2),
      constraints: const BoxConstraints(),
    );
  }
}
