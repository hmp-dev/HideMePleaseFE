import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/util/bold_generator.dart';

class DefaultButtonWithTitleText extends StatefulWidget {
  final String subtitle;
  final String title;
  final String? iconPath;
  final Color? color;
  final Color? textColor;
  final Function? onTap;
  final Color? borderColor;
  final double? borderRadius;

  const DefaultButtonWithTitleText({
    super.key,
    required this.subtitle,
    required this.title,
    this.iconPath,
    this.color,
    this.textColor,
    this.onTap,
    this.borderColor,
    this.borderRadius,
  });

  @override
  State<StatefulWidget> createState() => DefaultButtonWithTitleTextState();
}

class DefaultButtonWithTitleTextState
    extends State<DefaultButtonWithTitleText> {
  @override
  Widget build(BuildContext context) {
    var activateColor = widget.color ?? pink;
    var deactivateColor = black500;
    bool isActivate = widget.onTap != null;
    var textColor = isActivate ? widget.textColor ?? Colors.black : black100;

    return GestureDetector(
      onTap: () {
        if (isActivate) {
          FocusScope.of(context).unfocus();
          widget.onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
          color: isActivate ? activateColor : deactivateColor,
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!)
              : null,
        ),
        height: 56,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.iconPath != null)
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: DefaultImage(
                  path: widget.iconPath!,
                  width: 20,
                  height: 20,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: fontR(13, color: const Color(0xff870038)),
                ),
                BoldMsgGenerator.toRichText(
                    text: widget.title,
                    style: fontM(15, color: textColor),
                    boldStyle: fontB(15, color: textColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
