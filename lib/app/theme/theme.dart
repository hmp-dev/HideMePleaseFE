import 'package:flutter/material.dart';
// Hexadecimal opacity values
// 100% — FF
// 95% — F2
// 90% — E6
// 85% — D9
// 80% — CC
// 75% — BF
// 70% — B3
// 65% — A6
// 60% — 99
// 55% — 8C
// 50% — 80
// 45% — 73
// 40% — 66
// 35% — 59
// 30% — 4D
// 25% — 40
// 20% — 33
// 15% — 26
// 10% — 1A
// 5% — 0D
// 0% — 00

// white 100%
const fore1 = Color(0xFFFFFFFF);
// white 70%
const fore2 = Color(0xB3FFFFFF);
// white 50%
const fore3 = Color(0x80FFFFFF);
// white 30%
const fore4 = Color(0x4DFFFFFF);
// white 5%
const fore5 = Color(0x0DFFFFFF);

// white 100%
const foreNega1 = Color(0xFF000000);
// white 70%
const foreNega2 = Color(0xB3000000);
// white 50%
const foreNega3 = Color(0x80000000);
// white 30%
const foreNega4 = Color(0x4D000000);
// white 10%
const foreNega5 = Color(0x1A000000);

// white 100%
const bg1 = Color(0xFF0C0C0E);
// white 80%
const bg2 = Color(0xCC0C0C0E);
// white 50%
const bg3 = Color(0x800C0C0E);
// white 20%
const bg4 = Color(0x330C0C0E);
// white 10%
const bg5 = Color(0x1A0C0C0E);

// white 100%
const bgNega1 = Color(0xFFFFFFFF);
// white 80%
const bgNega2 = Color(0xCCFFFFFF);
// white 50%
const bgNega3 = Color(0x80FFFFFF);
// white 20%
const bgNega4 = Color(0x33FFFFFF);
// white 5%
const bgNega5 = Color(0x0DFFFFFF);

// white 50%
const bk1 = Color(0x80000000);
// white 30%
const bk2 = Color(0x80000000);
// white 10%
const bk3 = Color(0x80000000);

// backgroundGr1
const backgroundGr1 = Color(0xFF4E4E55);

const pink = Color(0xFFFF00E5);
const red = Color(0xFFFF0001);
const yellow = Color(0xFFFFC000);
const green = Color(0xFF00B546);
const hmpBlue = Color(0xFF00A3FF);
const blue = Color(0xFF1877F4);
const purple = Color(0xFF5200FF);
const black = Color(0xFF000000);

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

const mint = Color(0xff61FFF5);

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

TextStyle fontCompactLg({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactLgMedium({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactLgBold({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactMd({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );
TextStyle fontCompactMdMedium({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactMdBold({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactSm({Color? color = fore1}) => TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );
TextStyle fontCompactSmMedium({Color? color = fore1}) => TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );
TextStyle fontCompactSmBold({Color? color = fore1}) => TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactXs({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactXsUnderline({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
      decoration: TextDecoration.underline,
      decorationColor: fore3,
    );

TextStyle fontCompactXsMedium({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompactXsBold({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompact2Xs({Color? color = fore1}) => TextStyle(
      fontSize: 10,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompact2XsMedium({Color? color = fore1}) => TextStyle(
      fontSize: 10,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );

TextStyle fontCompact2XsBold({Color? color = fore1}) => TextStyle(
      fontSize: 10,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.3,
    );
TextStyle fontBodyLg({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBodyLgMedium({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBodyLgBold({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBodyMd({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBodyMdMedium({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBodyMdBold({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBodySm({Color? color = fore1}) => TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBodySmMedium({Color? color = fore1}) => TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBodySmBold({Color? color = fore1}) => TextStyle(
      fontSize: 14,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBodyXs({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBodyXsMedium({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBodyXsBold({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontBody2Xs({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBody2Medium({Color? color = fore1}) => TextStyle(
      fontSize: 12,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );
TextStyle fontBody2Bold({Color? color = fore1}) => TextStyle(
      fontSize: 28,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.7,
    );

TextStyle fontTitle07({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle07Medium({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle07Bold({Color? color = fore1}) => TextStyle(
      fontSize: 16,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );

TextStyle fontTitle06({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle06Medium({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle06Bold({Color? color = fore1}) => TextStyle(
      fontSize: 18,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );

TextStyle fontTitle05({Color? color = fore1}) => TextStyle(
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle05Medium({Color? color = fore1}) => TextStyle(
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle05Bold({Color? color = fore1}) => TextStyle(
      fontSize: 20,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );

TextStyle fontTitle04({Color? color = fore1}) => TextStyle(
      fontSize: 22,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle04Medium({Color? color = fore1}) => TextStyle(
      fontSize: 22,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle04Bold({Color? color = fore1}) => TextStyle(
      fontSize: 22,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle03({Color? color = fore1}) => TextStyle(
      fontSize: 24,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle03Medium({Color? color = fore1}) => TextStyle(
      fontSize: 24,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle03Bold({Color? color = fore1}) => TextStyle(
      fontSize: 24,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );

TextStyle fontTitle02({Color? color = fore1}) => TextStyle(
      fontSize: 28,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle02Medium({Color? color = fore1}) => TextStyle(
      fontSize: 28,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle02Bold({Color? color = fore1}) => TextStyle(
      fontSize: 28,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );

TextStyle fontTitle01({Color? color = fore1}) => TextStyle(
      fontSize: 32,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle01Medium({Color? color = fore1}) => TextStyle(
      fontSize: 32,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
    );
TextStyle fontTitle01Bold({Color? color = fore1}) => TextStyle(
      fontSize: 32,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w600,
      color: color ?? fore1,
      letterSpacing: -0.1,
      height: 1.4,
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
