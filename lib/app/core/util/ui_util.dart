import 'dart:io';

import 'package:flutter/cupertino.dart';

class UiUtil {
  static double bottomPadding(BuildContext context) {
    var bottom = MediaQuery.of(context).padding.bottom;
    return bottom < 15 ? 10 : bottom - 5;
  }

  static double heightRatio(BuildContext context) {
    return MediaQuery.of(context).size.height / 844;
  }

  static double widthRatio(BuildContext context) {
    return MediaQuery.of(context).size.width / 390;
  }

  static double get horizontal {
    return 16.0;
  }

  static Widget screenByPlatform(
    BuildContext context, {
    required Widget mobile,
    required Widget windows,
    Widget? pad,
  }) {
    if (Platform.isWindows) {
      return windows;
    }

    if (MediaQuery.of(context).size.shortestSide > 600) {
      return pad ?? windows;
    }

    return mobile;
  }
}
