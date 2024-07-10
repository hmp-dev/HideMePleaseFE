import 'package:flutter/material.dart';

class GlassmorphicButton extends StatelessWidget {
  final double width;
  final double height;
  final double blur;

  final VoidCallback onPressed;
  final Widget child;

  const GlassmorphicButton({
    super.key,
    this.width = 150,
    this.height = 50,
    this.blur = 20,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: blur,
              blurRadius: blur,
              offset: Offset(0, blur), // changes position of shadow
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.5),
            ],
          ),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(2),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
