import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class DefaultCheckButton extends StatefulWidget {
  final bool isSelected;
  final double? size;
  final double? borderRadius;

  const DefaultCheckButton({
    super.key,
    required this.isSelected,
    this.borderRadius = 0,
    this.size,
  });

  @override
  State<DefaultCheckButton> createState() => _DefaultCheckButtonState();
}

class _DefaultCheckButtonState extends State<DefaultCheckButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Container(
        width: widget.size ?? 24,
        height: widget.size ?? 24,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
          border: Border.all(color: gray500),
        ),
        child: widget.isSelected
            ? DefaultImage(
                path: "assets/icons/ic_check.svg",
                width: 32,
                height: 32,
              )
            : const SizedBox(),
      ),
    );
  }
}
