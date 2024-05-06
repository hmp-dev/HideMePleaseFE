import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class NFTCardWidgetParent extends StatelessWidget {
  const NFTCardWidgetParent({
    super.key,
    required this.imagePath,
    required this.topWidget,
    required this.bottomWidget,
    required this.badgeWidget,
    required this.index,
  });

  final String imagePath;
  final Widget topWidget;
  final Widget bottomWidget;
  final Widget badgeWidget;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Stack(
          children: [
            const VerticalSpace(20),
            Container(
              width: 326,
              height: 486,
              decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(4),
                image: imagePath != ""
                    ? DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.fill,
                      )
                    : const DecorationImage(
                        image: AssetImage("assets/images/home_card_img.png"),
                        fit: BoxFit.fill,
                      ),
                border: Border.all(
                  color: fore3,
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 322,
                  height: 482,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: black,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 318,
                    height: 478,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: fore3,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 486,
              width: 326,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topWidget,
                  const Spacer(),
                  bottomWidget,
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: badgeWidget,
        )
      ],
    );
  }
}
