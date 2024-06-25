import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SunriseWidget extends StatefulWidget {
  const SunriseWidget({
    super.key,
    required this.onSubmitRedeem,
    required this.isButtonEnabled,
  });

  final VoidCallback onSubmitRedeem;
  final bool isButtonEnabled;

  @override
  State<SunriseWidget> createState() => _SunriseWidgetState();
}

class _SunriseWidgetState extends State<SunriseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _fillFull = false;

  Timer? _timer;
  bool _isPressed = false;
  bool _longPressSuccess = false;
  static const int requiredPressDuration = 1300; // in milliseconds

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _animation = Tween<double>(begin: 0, end: 54).animate(_controller)
      ..addListener(() {
        if (_animation.value >= 54) {
          setState(() {
            _fillFull = true;
          });
        }
        setState(() {});
      });
  }

  // Press timer

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: requiredPressDuration), () {
      if (_isPressed) {
        if (mounted) {
          setState(() {
            _longPressSuccess = true;
          });
        }
      }
    });
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
      _timer = null;
    }
    setState(() {
      _isPressed = false;
      _longPressSuccess = false;
    });
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _fillFull = false;
    _controller.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      widget.onSubmitRedeem();
      setState(() {
        _fillFull = true;
      });

      _controller.reset();
    });

    setState(() {
      _isPressed = true;
    });
    _startTimer();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!_longPressSuccess) {
      _controller.reverse();
    }
    _cancelTimer();
  }

  @override
  void dispose() {
    //_cancelTimer();
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.isButtonEnabled ? _onLongPressStart : (_) {},
      onLongPressEnd: widget.isButtonEnabled ? _onLongPressEnd : (_) {},
      child: Stack(
        children: [
          Container(
            height: 54,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              color: widget.isButtonEnabled ? backgroundGr1 : black300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                LocaleKeys.longPressToUseBenefits.tr(),
                style: fontCompactMd(
                  color: widget.isButtonEnabled ? white : black500,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipPath(
                clipper: _fillFull
                    ? CenterExpandClipper(
                        MediaQuery.of(context).size.width - 40)
                    : CurveClipper(_animation.value),
                child: Container(
                  height: 54,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: fore3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  final double height;

  CurveClipper(this.height);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - height * 2, size.width, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CurveClipper oldClipper) {
    return oldClipper.height != height;
  }
}

class FullClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CenterExpandClipper extends CustomClipper<Path> {
  final double expansion;

  CenterExpandClipper(this.expansion);

  @override
  Path getClip(Size size) {
    var path = Path();
    double centerX = size.width / 2;
    path.moveTo(centerX - expansion, size.height);
    path.lineTo(centerX + expansion, size.height);
    path.lineTo(centerX + expansion, 0);
    path.lineTo(centerX - expansion, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CenterExpandClipper oldClipper) {
    return oldClipper.expansion != expansion;
  }
}
