import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class BlockChainSelectButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const BlockChainSelectButton({
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
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D3D3E) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border:
                isSelected ? null : Border.all(color: const Color(0xFF3D3D3E)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: Center(
              child: Text(
                title,
                style: fontSB(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
