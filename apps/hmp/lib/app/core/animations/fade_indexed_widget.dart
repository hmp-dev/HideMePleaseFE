import 'package:flutter/material.dart';

class FadeIndexedWidget extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedWidget({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(
      milliseconds: 500,
    ),
  });

  @override
  State<FadeIndexedWidget> createState() => _FadeIndexedWidgetState();
}

class _FadeIndexedWidgetState extends State<FadeIndexedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Widget _currentWidget;

  @override
  void didUpdateWidget(FadeIndexedWidget oldWidget) {
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
      setState(() {
        _currentWidget = widget.children[widget.index];
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _currentWidget = widget.children[widget.index];
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: _currentWidget,
    );
  }
}
