// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

class SBUPlaceholderComponent extends SBUStatelessComponent {
  final bool isLightTheme;
  final IconData iconData;
  final String text;
  final String? retryText;
  final void Function()? onRetryButtonClicked;

  const SBUPlaceholderComponent({
    required this.isLightTheme,
    required this.iconData,
    required this.text,
    this.retryText,
    this.onRetryButtonClicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final retryWidget = retryText != null
        ? Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetryButtonClicked,
                child: Container(
                  width: 84,
                  height: 32,
                  padding: const EdgeInsets.only(
                      left: 8, top: 4, right: 8, bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SBUIconComponent(
                        iconSize: 24,
                        iconData: SBUIcons.refresh,
                        iconColor: isLightTheme
                            ? SBUColors.primaryMain
                            : SBUColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      SBUTextComponent(
                        text: retryText!,
                        textType: SBUTextType.body3,
                        textColorType: SBUTextColorType.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SBUIconComponent(
            iconSize: 64,
            iconData: iconData,
            iconColor: isLightTheme
                ? SBUColors.lightThemeTextLowEmphasis
                : SBUColors.darkThemeTextLowEmphasis,
          ),
          const SizedBox(height: 16),
          SBUTextComponent(
            text: text,
            textType: SBUTextType.body3,
            textColorType: SBUTextColorType.text03,
          ),
          retryWidget ?? Container(),
        ],
      ),
    );
  }
}
