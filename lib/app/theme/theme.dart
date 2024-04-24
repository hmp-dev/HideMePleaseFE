import 'package:flutter/material.dart';

const bg1 = Color(0xFF0C0C0E);
const bg2 = Color(0xCC0C0C0E);
const bg3 = Color(0x800C0C0E);
const bg4 = Color(0x330C0C0E);
const bg5 = Color(0x1A0C0C0E);

const bg = Color(0xff0E0D0D);
const white = Color(0xFFFFFFFF);
const extraLightGray = Color(0xFFE4E3E3);
const lightGray = Color(0xFFF4F4F4);
const lighterGray = Color(0xFFDAD9D9);
const brownishGray = Color(0xFF787777);
const pureBlack = Color(0xFF000000);
const darkGray = Color(0xFF1A1919);
const lightGrayStroke = Color(0xFFBFBEBE);
const cececeColor = Color(0xFFCECECE);

const whiteWithOpacityOne = Color(0x80FFFFFF);
const fore2White70percent = Color(0x70ffffff);
const lightBlue = Color(0xFF00A3FF);
const blackLight = Color(0xFF191c1c);
const pink = Color(0xffFF016A);
const mint = Color(0xff61FFF5);
const purple = Color(0xff652BE1);
const blue = Color(0xff2B53E1);
const red = Color(0xffEA0000);
const forestGreen = Color(0xFF669954);
const goldenYellow = Color(0xFFE7B400);
const royalPurple = Color(0xFF8B79D3);
const slateBlueGray = Color(0xFF90A0AE);
// const green = Color(0xff);
const stroke_00 = Color(0xff212121);
const stroke_01 = Color(0xff323232);
const stroke_02 = Color(0xff3A3A3A);
const stroke_03 = Color(0xffB0B0B0);
const stroke_04 = Color(0xffDADADA);
const linear_p = Color(0xffFF006B);
// const linear_g= Color(0xff);
const linear_b = Color(0xff2F2F2F);
// const linear2 = Color(0xff);
// const linear_m

const black100 = Color(0xff454545);
const black200 = Color(0xff454545);
const black300 = Color(0xff1A1A1A);
const black500 = Color(0xff2D2D2D);
const black700 = Color(0xff202020);
const black800 = Color(0xff1A1A1A);
const black900 = Color(0xff131313);

const gray900 = Color(0xff666666);
const gray800 = Color(0xff929292);
const gray700 = Color(0xffADADAD);
const gray600 = Color(0xff8A8A8A);
const gray100 = Color(0xffFCFCFC);
const gray200 = Color(0xffF5F5F5);
const gray300 = Color(0xffe9e9e9);
const gray500 = Color(0xffD9D9D9);

TextStyle fontL(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w300,
      color: color ?? gray100,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontR(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontRUnderLined(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
      decoration: TextDecoration.underline,
      decorationColor: white,
    );

// TextStyle(
//                                         fontSize: 14,
//                                         fontFamily: 'Pretendard',
//                                         fontWeight: FontWeight.w400,
//                                         color: white,
//                                         letterSpacing: -0.1,
//                                         decoration: TextDecoration.underline,
//                                         decorationColor: white)
TextStyle fontM(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontSB(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontB(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontEB(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w800,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontH(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w900,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontTH(
  double size, {
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w100,
      color: color ?? white,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontStroke(double size, {Color? color, Color? outlineColor}) =>
    TextStyle(
      fontSize: size,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w800,
      // color: color ?? gray100,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = outlineColor ?? white,
      letterSpacing: -0.1,
    );

TextStyle fontTitle({
  Color? color,
  double? letterSpacing = -0.1,
  double? lineHeight,
}) =>
    TextStyle(
      fontSize: 24,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      color: color ?? gray100,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

TextStyle fontBoldEmpty({
  Color? color = gray100,
  double? letterSpacing = -0.1,
  double? lineHeight = 1.5,
}) =>
    TextStyle(
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      color: color ?? gray100,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFF0C0C0E),
    primaryColor: lightBlue,
    colorScheme:
        ColorScheme.fromSeed(seedColor: lightBlue, brightness: Brightness.dark),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        iconTheme: const IconThemeData(color: Colors.black)),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
    ),
  );
}
