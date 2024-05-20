import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// ** 사용법
///  DefaultSnackBar.showToastMsg(context, message: "메세지를 입력해주세요.");

class DefaultSnackBar {
  DefaultSnackBar._();
  static final DefaultSnackBar _instance = DefaultSnackBar._();
  static DefaultSnackBar get instance => _instance;

  late FToast _fToast;
  void init(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);
  }

  void showToastMsg(
    BuildContext context, {
    required String message,
  }) {
    BuildContext? navigatorContext =
        context.read<GlobalKey<NavigatorState>>().currentContext;
    if (navigatorContext != null) {
      Log.info('Success: navigatorContext is NOT null');
      init(navigatorContext);
    } else {
      Log.info('Info: navigatorContext is null');
      init(context);
    }

    _fToast.showToast(
      child: _snackBar(context, message),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  //
  void showDismissibleSnackBarWithButton(
    BuildContext context,
    String message, {
    required bool isShowButton,
    String? buttonTitle,
    VoidCallback? onButtonTap,
  }) {
    init(context.read<GlobalKey<NavigatorState>>().currentContext!);

    _fToast.showToast(
      child: GestureDetector(
        onTap: () {
          _fToast.removeCustomToast();
        },
        child: _snackBarWithButton(
          message,
          isShowButton: isShowButton,
          buttonTitle: buttonTitle,
          onButtonTap: () {
            _fToast.removeCustomToast();
            onButtonTap?.call();
          },
        ),
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
    );
  }

  void showCenterToastMsg(
    BuildContext context, {
    required String message,
  }) {
    init(context.read<GlobalKey<NavigatorState>>().currentContext!);

    _fToast.showToast(
      child: _snackBar(context, message, textAlign: TextAlign.center),
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 3),
    );
  }

  void showToastMsgWithIcon(
    BuildContext context, {
    required String message,
    required String icon,
  }) {
    init(context.read<GlobalKey<NavigatorState>>().currentContext!);

    _fToast.showToast(
      child: _snackBar(
        context,
        message,
        duration: 3000,
        prefixIcon: icon,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
    );
  }

  Widget _snackBar(
    BuildContext context,
    String title, {
    int? duration,
    String? prefixIcon,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: black100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: DefaultImage(
                path: prefixIcon,
                color: Colors.white,
              ),
            ),
          Expanded(
            child: Text(
              title,
              textAlign: textAlign,
              style: fontR(14).copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          GestureDetector(
            onTap: () {
              _fToast.removeCustomToast();
            },
            child: DefaultImage(
              path: "assets/icons/ic_cancel.svg",
              color: gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _snackBarWithButton(
    String message, {
    required bool isShowButton,
    String? buttonTitle,
    VoidCallback? onButtonTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: black500,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DefaultImage(
              path: "assets/icons/ic_star.svg",
              color: pink,
            ),
          ),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.left,
              style: fontR(14).copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (isShowButton)
            GestureDetector(
              onTap: () {
                onButtonTap?.call();
              },
              child: Container(
                width: 68,
                height: 29,
                decoration: BoxDecoration(
                  color: black700,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    buttonTitle ?? "",
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension SnackBarExtension on BuildContext {
  void showSnackBar(String message) =>
      DefaultSnackBar.instance.showToastMsg(this, message: message);

  //showCenterToastMsg
  void showCenterSnackBar(String message) =>
      DefaultSnackBar.instance.showCenterToastMsg(this, message: message);

  void showErrorSnackBar([String? message]) {
    String callerInfo = StackTrace.current.toString().split('\n')[1];
    String location = callerInfo.substring(
        callerInfo.indexOf('package:'), callerInfo.length - 1);

    Log.debug(
        'showErrorSnackBar->$location\n${message ?? LocaleKeys.somethingError.tr()}');

    DefaultSnackBar.instance
        .showToastMsg(this, message: message ?? LocaleKeys.somethingError.tr());
  }

  void showDismissibleSnackBarWithButton({
    required String message,
    required bool isShowButton,
    String? buttonTitle,
    VoidCallback? onButtonTap,
  }) =>
      DefaultSnackBar.instance.showDismissibleSnackBarWithButton(
        this,
        message,
        isShowButton: isShowButton,
        buttonTitle: buttonTitle,
        onButtonTap: onButtonTap,
      );
}
