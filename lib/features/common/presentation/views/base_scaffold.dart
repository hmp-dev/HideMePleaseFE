// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_dialog.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_loading.dart';

class BaseScaffold extends StatefulWidget {
  final String? title;
  final Function? onBack;
  final Widget? suffix;
  final bool isCenterTitle;
  final Widget body;
  final Color? backgroundColor;
  final bool onLoading;
  final bool isFirstPage;
  final bool safeArea;
  final String backIconPath;
  final Widget? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    this.safeArea = true,
    this.backgroundColor,
    this.isCenterTitle = false,
    this.title,
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
                    title: "앱 종료",
                    description: "앱을 종료하시겠습니까?",
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
          backgroundColor: widget.backgroundColor ?? bg,
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
                    color: widget.backgroundColor ?? bg,
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
    bool enableTitle = widget.title != null;
    bool enableSuffix = widget.suffix != null;

    if (enableBack || enableSuffix || enableTitle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: widget.backgroundColor ?? bg,
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
                              color: white,
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
                child: Text(
                  widget.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fontM(20),
                ),
              ),
          ],
        ),
      );
    }
    return Container();
  }
}
