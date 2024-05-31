import 'package:flutter/material.dart';

class AnimatedSlideFadeIn extends StatefulWidget {
  const AnimatedSlideFadeIn({
    super.key,
    required this.child,
    required this.slideIndex,
    required this.beginOffset,
  });

  final Widget child;
  final int slideIndex;
  final Offset beginOffset;

  @override
  State<AnimatedSlideFadeIn> createState() => _AnimatedSlideFadeInState();
}

class _AnimatedSlideFadeInState extends State<AnimatedSlideFadeIn>
    with TickerProviderStateMixin {
  AnimationController? anim;

  @override
  void initState() {
    super.initState();

    anim =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void didUpdateWidget(AnimatedSlideFadeIn oldWidget) {
    if (widget.slideIndex != oldWidget.slideIndex) {
      anim!.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    anim!.forward();
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: anim!, curve: Curves.easeInOut)),
      child: SlideTransition(
        position: Tween<Offset>(
                begin: widget.beginOffset, end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(parent: anim!, curve: Curves.easeInOut)),
        child: widget.child,
      ),
    );
  }
}
