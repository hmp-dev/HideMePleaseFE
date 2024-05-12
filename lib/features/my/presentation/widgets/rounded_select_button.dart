import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class RoundedSelectButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const RoundedSelectButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Center(
              child: Text(title,
                  style: fontCompactMdMedium(
                    color: isSelected ? white : fore3,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
