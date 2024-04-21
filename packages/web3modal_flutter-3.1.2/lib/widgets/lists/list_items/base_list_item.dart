import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class BaseListItem extends StatelessWidget {
  const BaseListItem({
    super.key,
    this.trailing,
    this.onTap,
    this.padding,
    required this.child,
  });
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return Container(
      padding: EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF434343)),
      ),
      child: FilledButton(
        onPressed: onTap,
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(
            const Size(1000.0, kListItemHeight),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            themeColors.grayGlass002,
          ),
          overlayColor: MaterialStateProperty.all<Color>(
            themeColors.grayGlass005,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiuses.radiusXS),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(0.0),
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}
