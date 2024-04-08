import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class DefaultLoading extends StatefulWidget {
  final Color? backgroundColor;
  final Color? loadingColor;
  final double size;
  final String? text;

  const DefaultLoading({
    super.key,
    this.backgroundColor,
    this.loadingColor,
    this.size = 2,
    this.text,
  });

  @override
  State<DefaultLoading> createState() => _DefaultLoadingState();
}

class _DefaultLoadingState extends State<DefaultLoading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black.withOpacity(0.1),
          strokeWidth: widget.size,
          valueColor:
              AlwaysStoppedAnimation<Color>(widget.loadingColor ?? pink),
        ),
      ),
    );
  }
}
