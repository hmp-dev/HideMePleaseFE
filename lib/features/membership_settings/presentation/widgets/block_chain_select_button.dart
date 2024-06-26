import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

class BlockChainSelectButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final String? imagePath;

  const BlockChainSelectButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 33,
          decoration: BoxDecoration(
            color: isSelected ? bk1 : fore5,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: isSelected ? white : fore5),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (imagePath != null) ? 10.0 : 30, vertical: 10),
            child: Center(
              child: Row(
                children: [
                  imagePath != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: CustomImageView(
                            imagePath: !imagePath!.endsWith('.svg')
                                ? imagePath!
                                : null,
                            svgPath:
                                imagePath!.endsWith('.svg') ? imagePath! : null,
                            width: 24,
                            height: 24,
                          ),
                        )
                      : const SizedBox(width: 0),
                  Text(title,
                      style: fontCompactMdMedium(
                        color: isSelected ? white : fore3,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
