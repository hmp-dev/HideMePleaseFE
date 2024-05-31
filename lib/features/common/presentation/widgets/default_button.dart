import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/util/bold_generator.dart';

class DefaultButton extends StatefulWidget {
  final String title;
  final String? iconPath;
  final Color? color;
  final Color? textColor;
  final Function? onTap;
  final Color? borderColor;
  final double? borderRadius;
  final bool loading;
  final double? height;

  const DefaultButton({
    super.key,
    required this.title,
    this.iconPath,
    this.color,
    this.textColor,
    this.onTap,
    this.borderColor,
    this.borderRadius,
    this.loading = false,
    this.height = 56,
  });

  @override
  State<StatefulWidget> createState() => DefaultButtonState();
}

class DefaultButtonState extends State<DefaultButton> {
  @override
  Widget build(BuildContext context) {
    var activateColor = widget.color ?? pink;
    var deactivateColor = black500;
    bool isActivate = widget.onTap != null && !widget.loading;
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
        height: widget.height,
        alignment: Alignment.center,
        child: widget.loading
            ? Center(
                child: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(textColor),
                  ),
                ),
              )
            : Row(
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
                  BoldMsgGenerator.toRichText(
                    text: "*${widget.title}",
                    style: fontM(16, color: textColor),
                    boldStyle: fontB(16, color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
