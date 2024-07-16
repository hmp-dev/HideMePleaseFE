// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

class SBUBottomSheetMenuComponent extends SBUStatefulComponent {
  final List<IconData>? iconNames;
  final List<String> buttonNames;
  final void Function(String buttonName) onButtonClicked;
  final int? errorColorIndex;

  const SBUBottomSheetMenuComponent({
    this.iconNames,
    required this.buttonNames,
    required this.onButtonClicked,
    this.errorColorIndex,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUBottomSheetMenuComponentState();
}

class SBUBottomSheetMenuComponentState
    extends State<SBUBottomSheetMenuComponent> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();

    final iconNames = widget.iconNames;
    final buttonNames = widget.buttonNames;
    final onButtonClicked = widget.onButtonClicked;
    final errorColorIndex = widget.errorColorIndex;

    return Container(
      decoration: BoxDecoration(
        color: isLightTheme ? SBUColors.background50 : SBUColors.background500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buttonNames.mapIndexed((index, iconName) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                onButtonClicked(buttonNames[index]);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Row(
                  children: [
                    index < (iconNames?.length ?? 0)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: SBUIconComponent(
                              iconSize: 24,
                              iconData: iconNames![index],
                              iconColor: isLightTheme
                                  ? SBUColors.primaryMain
                                  : SBUColors.primaryLight,
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: SBUTextComponent(
                          text: buttonNames[index],
                          textType: SBUTextType.body3,
                          textColorType: errorColorIndex == index
                              ? SBUTextColorType.error
                              : SBUTextColorType.text01,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
