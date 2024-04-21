import 'package:flutter/material.dart';

export 'w3m_theme_widget.dart';
export 'w3m_theme_data.dart';
export 'w3m_colors.dart';
export 'w3m_radiuses.dart';

TextStyle font_MW3M(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? Colors.white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontB_MW3M(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      color: color ?? Colors.white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontR__MW3M(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? Colors.white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );
