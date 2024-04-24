import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/util/bold_generator.dart';

class DefaultDialog extends StatefulWidget {
  final String? title;
  final Color? titleColor;
  final String? imageUrl;
  final Color? descriptionColor;
  final String? description;
  final String? cancelButtonLabel;
  final String? successButtonLabel;
  final Function? onSuccess;
  final Widget? body;
  final Color? buttonColor;
  final int cancelFlex;
  final int successFlex;

  const DefaultDialog({
    super.key,
    this.title,
    this.titleColor,
    this.imageUrl,
    this.description,
    this.descriptionColor,
    this.body,
    this.onSuccess,
    this.cancelButtonLabel,
    this.successButtonLabel,
    this.buttonColor,
    this.cancelFlex = 2,
    this.successFlex = 3,
  });

  static show(
    BuildContext context, {
    String? title,
    String? description,
    Color? titleColor,
    String? imageUrl,
    Function? onSuccess,
    Color? descriptionColor,
    Widget? body,
    String? cancelButtonLabel,
    Color? buttonColor,
    String? buttonLabel,
    int cancelFlex = 2,
    int successFlex = 3,
  }) async {
    return await showDialog(
      useSafeArea: false,
      context: context,
      builder: (_) => DefaultDialog(
        title: title,
        description: description,
        titleColor: titleColor,
        onSuccess: onSuccess,
        imageUrl: imageUrl,
        descriptionColor: descriptionColor,
        buttonColor: buttonColor,
        body: body,
        cancelButtonLabel: cancelButtonLabel,
        successButtonLabel: buttonLabel,
        cancelFlex: cancelFlex,
        successFlex: successFlex,
      ),
    );
  }

  @override
  State<DefaultDialog> createState() => _DefaultDialogState();
}

class _DefaultDialogState extends State<DefaultDialog> {
  final double BOX_WIDTH = 300.0;
  final double BUTTON_HEIGHT = 52.0;
  final double RADIUS = 10.0;
  final double VERTICAL_PADDING = 36.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  if (widget.title != null)
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title!,
                        style: fontB(16, color: widget.titleColor),
                      ),
                    ),
                  if (widget.imageUrl != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      child: DefaultImage(
                        path: widget.imageUrl!,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  if (widget.description != null)
                    Container(
                      margin: widget.imageUrl != null
                          ? const EdgeInsets.only(bottom: 24)
                          : EdgeInsets.only(
                              top: widget.title == null ? 0 : 52, bottom: 52),
                      child: BoldMsgGenerator.toRichText(
                        text: widget.description!,
                        maxLine: 10,
                        style: fontL(16).copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                        boldStyle: fontB(16).copyWith(height: 1.5),
                      ),
                    ),
                  widget.body ?? Container(),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: widget.cancelFlex,
                    child: _itemButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: widget.cancelButtonLabel ??
                          (widget.onSuccess != null
                              ? LocaleKeys.cancel.tr()
                              : LocaleKeys.confirm.tr()),
                      background: widget.onSuccess == null
                          ? pink
                          : (widget.buttonColor ?? gray900),
                      textColor: widget.onSuccess != null ? pink : Colors.white,
                    ),
                  ),
                  if (widget.onSuccess != null) const SizedBox(width: 10),
                  if (widget.onSuccess != null)
                    Expanded(
                      flex: widget.successFlex,
                      child: _itemButton(
                        onTap: () {
                          widget.onSuccess!();
                          Navigator.pop(context, true);
                        },
                        title: widget.successButtonLabel ??
                            LocaleKeys.confirm.tr(),
                        background: pink,
                        textColor: Colors.white,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _itemButton({
    required Function onTap,
    required String title,
    required Color background,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(6)),
        height: BUTTON_HEIGHT,
        child: Text(
          title,
          style: fontB(14, color: textColor),
        ),
      ),
    );
  }
}
