// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';

class SBUScrollBarComponent extends SBUStatefulComponent {
  final ScrollController controller;
  final ListView child;

  const SBUScrollBarComponent({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUScrollBarComponentState();
}

class SBUScrollBarComponentState extends State<SBUScrollBarComponent> {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: widget.controller,
      child: widget.child,
    );
  }
}
