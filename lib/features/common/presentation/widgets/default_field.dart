import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class DefaultField extends StatefulWidget {
  final List<TextInputFormatter> inputFormatters;
  final Color? color;
  final TextStyle? textStyle;
  final bool isBorderType;
  final double? horizontalPadding;
  final TextInputType keyboardType;
  final String? initialValue;
  final String? hintText;
  final Widget? prefix;
  final Function(String text)? onChange;
  final bool showCancelButton;
  final bool? autoFocus;
  final int? maxLine;
  final String? guideMsg;
  final bool? isError;
  final double borderRadius;
  final TextEditingController? controller;
  final VoidCallback? onEditingComplete;

  const DefaultField({
    super.key,
    this.textStyle,
    this.inputFormatters = const [],
    this.color,
    this.isBorderType = false,
    this.horizontalPadding,
    this.keyboardType = TextInputType.text,
    this.initialValue = "",
    this.prefix,
    this.hintText,
    this.onChange,
    this.showCancelButton = true,
    this.autoFocus,
    this.maxLine,
    this.isError = false,
    this.guideMsg,
    this.borderRadius = 4,
    this.controller,
    this.onEditingComplete,
  });

  @override
  State<StatefulWidget> createState() => _DefaultFieldState();
}

class _DefaultFieldState extends State<DefaultField> {
  late TextEditingController _controller;
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
    _controller =
        (widget.controller ?? TextEditingController(text: widget.initialValue))
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  bool onFocus = false;

  void _onFocusChange() {
    onFocus = focusNode.hasFocus;
    setState(() {});
  }

  @override
  void dispose() {
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  var text = "";

  @override
  Widget build(BuildContext context) {
    var border = widget.isBorderType
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              width: 1,
              color: fore5,
              style: BorderStyle.solid,
            ),
          )
        : UnderlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.transparent,
              style: BorderStyle.solid,
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if (widget.prefix != null) widget.prefix!,
          Expanded(
            child: TextFormField(
              keyboardType: widget.keyboardType,
              autofocus: widget.autoFocus ?? false,
              focusNode: focusNode,
              maxLines: widget.maxLine,
              controller: _controller,
              style: widget.textStyle ?? fontCompactMd(color: fore3),
              cursorColor: hmpBlue,
              onChanged: (text) {
                this.text = text;

                if (widget.onChange != null) {
                  widget.onChange!(text);
                }

                setState(() {});
              },
              inputFormatters: widget.inputFormatters,
              onEditingComplete: widget.onEditingComplete,
              decoration: InputDecoration(
                filled: true,
                fillColor: bgNega5,
                counterText: "",
                hintText: widget.hintText ?? "",
                hintStyle:
                    (widget.textStyle ?? fontR(20)).copyWith(color: gray900),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 15, horizontal: widget.isBorderType ? 16 : 0),
                disabledBorder: border,
                enabledBorder: border,
                focusedBorder: widget.isBorderType
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          width: 1,
                          color: stroke_02,
                          style: BorderStyle.solid,
                        ),
                      )
                    : UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.transparent,
                          style: BorderStyle.solid,
                        ),
                      ),
              ),
            ),
          ),
        ]),
        if (!widget.isBorderType)
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: stroke_01,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: onFocus ? 1 * MediaQuery.of(context).size.width : 0,
              decoration: BoxDecoration(
                color: widget.color ?? pink,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        if ((widget.guideMsg ?? "").isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (widget.isError != null)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: widget.isError!
                      ? DefaultImage(
                          path: "assets/icons/ic_cancel.svg",
                          width: 20,
                          height: 20,
                        )
                      : DefaultImage(
                          path: "assets/icons/ic_check.svg",
                          color: blue,
                          width: 20,
                          height: 20,
                        ),
                ),
              Expanded(
                child: Text(
                  widget.guideMsg!,
                  maxLines: 3,
                  style: fontR(14, color: gray700),
                ),
              ),
            ]),
          ),
      ],
    );
  }
}
