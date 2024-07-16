// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/painting.dart';
import 'package:sendbird_uikit/src/public/resource/sbu_colors.dart';
import 'package:sendbird_uikit/src/public/resource/sbu_theme_provider.dart';

enum SBUTextType {
  heading1,
  heading2,
  subtitle1,
  subtitle2,
  body1,
  body2,
  body3,
  button,
  caption1,
  caption2,
  caption3,
  caption4,
}

enum SBUTextColorType {
  primary, // [light] primaryMain, [dark] primaryLight
  secondary, // [light] secondaryMain, [dark] secondaryLight
  error, // [light] errorMain, [dark] errorLight
  text01, // [light] lightThemeTextHighEmphasis, [dark] darkThemeTextHighEmphasis
  text02, // [light] lightThemeTextMidEmphasis, [dark] darkThemeTextMidEmphasis
  text03, // [light] lightThemeTextLowEmphasis, [dark] darkThemeTextLowEmphasis
  text04, // [light] lightThemeTextDisabled, [dark] darkThemeTextDisabled
  badge, // [light] darkThemeTextHighEmphasis, [dark] lightThemeTextHighEmphasis
  message, // [light] darkThemeTextHighEmphasis, [dark] lightThemeTextHighEmphasis
  toast, // [light] darkThemeTextHighEmphasis, [dark] lightThemeTextHighEmphasis
  messageEdited, // [light] darkThemeTextMidEmphasis, [dark] lightThemeTextMidEmphasis
  messageDate, // [light] darkThemeTextHighEmphasis, [dark] darkThemeTextMidEmphasis
  information, // [light] lightThemeTextHighEmphasis, [dark] lightThemeTextHighEmphasis
  disabled, // [light] lightThemeTextDisabled, [dark] darkThemeTextDisabled
}

class SBUTextStyles {
  static String fontFamily = 'Roboto';

  static TextStyle getTextStyle({
    required SBUTheme theme,
    required SBUTextType textType,
    required SBUTextColorType textColorType,
  }) {
    final color = _getTextColor(
      theme: theme,
      textColorType: textColorType,
    );

    switch (textType) {
      case SBUTextType.heading1:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 1.111,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.heading2:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 1.25,
          letterSpacing: -0.2,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.subtitle1:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1.375,
          letterSpacing: -0.2,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.subtitle2:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.5,
          letterSpacing: -0.2,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.body1:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.25,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.body2:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.142,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.body3:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.428,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.button:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 1.142,
          letterSpacing: 0.4,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.caption1:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.caption2:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.caption3:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1.090,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
      case SBUTextType.caption4:
        return TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 11,
          height: 1.090,
          color: color,
          decorationThickness: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );
    }
  }

  static Color _getTextColor({
    required SBUTheme theme,
    required SBUTextColorType textColorType,
  }) {
    switch (textColorType) {
      case SBUTextColorType.primary:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.primaryMain;
          case SBUTheme.dark:
            return SBUColors.primaryLight;
        }
      case SBUTextColorType.secondary:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.secondaryMain;
          case SBUTheme.dark:
            return SBUColors.secondaryLight;
        }
      case SBUTextColorType.error:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.errorMain;
          case SBUTheme.dark:
            return SBUColors.errorLight;
        }
      case SBUTextColorType.text01:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.lightThemeTextHighEmphasis;
          case SBUTheme.dark:
            return SBUColors.darkThemeTextHighEmphasis;
        }
      case SBUTextColorType.text02:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.lightThemeTextMidEmphasis;
          case SBUTheme.dark:
            return SBUColors.darkThemeTextMidEmphasis;
        }
      case SBUTextColorType.text03:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.lightThemeTextLowEmphasis;
          case SBUTheme.dark:
            return SBUColors.darkThemeTextLowEmphasis;
        }
      case SBUTextColorType.text04:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.lightThemeTextDisabled;
          case SBUTheme.dark:
            return SBUColors.darkThemeTextDisabled;
        }
      case SBUTextColorType.badge:
      case SBUTextColorType.message:
      case SBUTextColorType.toast:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.darkThemeTextHighEmphasis;
          case SBUTheme.dark:
            return SBUColors.lightThemeTextHighEmphasis;
        }
      case SBUTextColorType.messageEdited:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.darkThemeTextMidEmphasis;
          case SBUTheme.dark:
            return SBUColors.lightThemeTextMidEmphasis;
        }
      case SBUTextColorType.messageDate:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.darkThemeTextHighEmphasis;
          case SBUTheme.dark:
            return SBUColors.darkThemeTextMidEmphasis;
        }
      case SBUTextColorType.information:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.lightThemeTextHighEmphasis;
          case SBUTheme.dark:
            return SBUColors.lightThemeTextHighEmphasis;
        }
      case SBUTextColorType.disabled:
        switch (theme) {
          case SBUTheme.light:
            return SBUColors.lightThemeTextDisabled;
          case SBUTheme.dark:
            return SBUColors.darkThemeTextDisabled;
        }
    }
  }
}
