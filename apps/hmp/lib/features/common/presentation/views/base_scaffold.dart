// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_dialog.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_loading.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:flutter/services.dart';

/// The base scaffold widget for all screens.
///
/// This widget provides a standardized structure for all screens in the app.
/// It includes a title, a back button, a loading indicator, and a bottom navigation bar.
/// The [body] parameter is the main content of the screen.
class BaseScaffold extends StatefulWidget {
  // Title of the screen
  final String? title;

  // Custom title widget (used instead of title if provided)
  final Widget? titleWidget;

  // Function to be called when the back button is pressed
  final Function? onBack;

  // Suffix widget to be placed at the end of the title
  final Widget? suffix;

  // Whether the title should be centered or not
  final bool isCenterTitle;

  // The main content of the screen
  final Widget body;

  // Background color of the screen
  final Color? backgroundColor;

  // Whether the loading indicator should be displayed or not
  final bool onLoading;

  // Whether the screen is the first page or not
  final bool isFirstPage;

  // Whether the safe area should be applied or not
  final bool safeArea;

  // Path to the back icon
  final String backIconPath;

  // Bottom navigation bar of the screen
  final Widget? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    this.safeArea = true,
    this.backgroundColor,
    this.isCenterTitle = false,
    this.title,
    this.titleWidget,
    this.onBack,
    this.suffix,
    required this.body,
    this.onLoading = false,
    this.isFirstPage = false,
    this.backIconPath = "assets/icons/img_icon_arrow.svg",
    this.bottomNavigationBar,
  });

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  final double APPBAR_HEIGHT = 46.0;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? body(context)
        : WillPopScope(
            onWillPop: () async {
              if (widget.onBack != null) {
                widget.onBack!();
              }

              if (widget.isFirstPage) {
                var result = await DefaultDialog.show(context,
                    title: LocaleKeys.access_wepin_wallet.tr(), //"앱 종료",
                    description: LocaleKeys.doYouWantToExitTheApp
                        .tr(), // "앱을 종료하시겠습니까?",
                    onSuccess: () {});
                return result ?? false;
              } else {
                return !widget.isFirstPage;
              }
            },
            child: body(context),
          );
  }

  Widget body(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Scaffold(
          backgroundColor: widget.backgroundColor ?? const Color(0xFFEAF8FF),
          bottomNavigationBar: widget.bottomNavigationBar,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: widget.safeArea
                        ? MediaQuery.of(context).padding.top
                        : 0,
                    color: widget.backgroundColor ?? const Color(0xFFEAF8FF),
                  ),
                  _appBar(),
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ),
        ),
        if (widget.onLoading) const DefaultLoading(),
      ],
    );
  }

  _appBar() {
    bool enableBack = widget.onBack != null;
    bool enableTitle = widget.title != null || widget.titleWidget != null;
    bool enableSuffix = widget.suffix != null;

    if (enableBack || enableSuffix || enableTitle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: widget.backgroundColor ?? const Color(0xFFEAF8FF),
        height: APPBAR_HEIGHT,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (enableBack || enableSuffix)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (enableBack)
                      ? GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            widget.onBack!();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            color: Colors.transparent,
                            alignment: Alignment.centerLeft,
                            child: DefaultImage(
                              path: widget.backIconPath,
                              width: 32,
                              height: 32,
                              color: const Color(0xFF000000),
                            ),
                          ),
                        )
                      : Container(),
                  if (widget.suffix != null)
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.suffix!,
                    ),
                ],
              ),
            if (enableTitle)
              Container(
                alignment: widget.isCenterTitle ? Alignment.center : null,
                padding: EdgeInsets.only(left: widget.isCenterTitle ? 0 : 50),
                child: widget.titleWidget ?? Text(
                  widget.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fontTitle05Medium(),
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
