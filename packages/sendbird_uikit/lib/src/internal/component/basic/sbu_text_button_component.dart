// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';

class SBUTextButtonComponent extends SBUStatefulComponent {
  final double? width;
  final double height;
  final Color? backgroundColor;
  final SBUTextComponent text;
  final void Function()? onButtonClicked;
  final EdgeInsetsGeometry? padding;
  final bool isAlignmentStart;
  final bool hasBorder;
  final Color? borderColor;

  const SBUTextButtonComponent({
    this.width,
    required this.height,
    this.backgroundColor,
    required this.text,
    this.onButtonClicked,
    this.padding,
    this.isAlignmentStart = false,
    this.hasBorder = false,
    this.borderColor,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUTextButtonComponentState();
}

class SBUTextButtonComponentState extends State<SBUTextButtonComponent> {
  @override
  Widget build(BuildContext context) {
    final width = widget.width;
    final height = widget.height;
    final backgroundColor = widget.backgroundColor;
    final text = widget.text;
    final onButtonClicked = widget.onButtonClicked;
    final padding = widget.padding;
    final isAlignmentStart = widget.isAlignmentStart;
    final hasBorder = widget.hasBorder;
    final borderColor = widget.borderColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: hasBorder && borderColor != null
            ? Border.all(width: 1, color: borderColor)
            : null,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: padding,
          alignment: isAlignmentStart
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.center,
        ),
        onPressed: onButtonClicked,
        child: text,
      ),
    );
  }
}
