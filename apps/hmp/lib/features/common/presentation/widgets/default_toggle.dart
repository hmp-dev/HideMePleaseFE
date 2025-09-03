import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

enum CustomToggleType { spotMale, spotFemale, other }

class CustomToggle extends StatefulWidget {
  final bool initialValue;
  final String? emoji;
  final Function(bool) onTap;
  final double height;
  final double width;
  final double circleSize;
  final CustomToggleType type;
  final Color? toggleColor;

  const CustomToggle({
    super.key,
    required this.initialValue,
    this.emoji,
    required this.onTap,
    this.height = 34,
    this.width = 64,
    this.circleSize = 28,
    this.type = CustomToggleType.other,
    this.toggleColor,
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle> {
  final Duration ANIMATION_DURATION = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(!widget.initialValue);
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            AnimatedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              width: widget.width,
              height: widget.height,
              duration: ANIMATION_DURATION,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFF132E41)),
                color: widget.initialValue ? const Color(0x3323B0FF) : const Color(0x1A000000),
              ),
              child: const Row(
                children: [
                  // Expanded(
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       'ON',
                  //       textAlign: TextAlign.center,
                  //       style: fontCompactSm(),
                  //     ),
                  //   ),
                  // ),
                  // Expanded(
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       'OFF',
                  //       textAlign: TextAlign.center,
                  //       style: fontCompactSm(),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Row(
              children: [
                AnimatedContainer(
                  padding: const EdgeInsets.all(3),
                  width: widget.width,
                  height: widget.height,
                  duration: ANIMATION_DURATION,
                  alignment: widget.initialValue
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: ANIMATION_DURATION,
                    width: widget.circleSize,
                    height: widget.circleSize,
                    decoration: BoxDecoration(
                      color: widget.initialValue ? const Color(0xFF23B0FF) : const Color(0x4D000000),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
