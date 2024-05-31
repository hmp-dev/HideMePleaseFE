import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

class LinkedWalletButton extends StatelessWidget {
  const LinkedWalletButton({
    super.key,
    required this.titleText,
    required this.count,
    required this.onTap,
  });

  final int count;
  final String titleText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20,
        width: 101,
        decoration: const BoxDecoration(
          color: black200,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: fontCompactXsMedium(),
              ),
              Row(
                children: [
                  Text(
                    "$count",
                    textAlign: TextAlign.center,
                    style: fontCompactXsMedium(),
                  ),
                  CustomImageView(
                    svgPath: "assets/icons/ic_angle_arrow_down.svg",
                    width: 14,
                    height: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
