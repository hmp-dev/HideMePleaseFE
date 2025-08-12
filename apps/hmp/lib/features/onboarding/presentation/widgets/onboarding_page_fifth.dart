import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/character_profile.dart';
import 'character_layer_widget.dart';

class OnboardingPageFifth extends StatefulWidget {
  final String selectedProfile;
  final CharacterProfile? selectedCharacter;
  final String nickname;
  
  const OnboardingPageFifth({
    super.key,
    required this.selectedProfile,
    this.selectedCharacter,
    required this.nickname,
  });

  @override
  State<OnboardingPageFifth> createState() => _OnboardingPageFifthState();
}

class _OnboardingPageFifthState extends State<OnboardingPageFifth> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF87CEEB), // Sky blue background
      child: Stack(
        children: [
          // Confetti animation overlay
          ..._buildConfetti(),
          Column(
            children: [
              const SizedBox(height: 20),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      '반가워, ${widget.nickname}',
                      style: const TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      '모든 준비가 완료됐어!',
                      style: TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Character celebration display with rounded rectangle background
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: widget.selectedCharacter != null
                              ? CharacterLayerWidget(
                                  character: widget.selectedCharacter!,
                                  size: 320,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  widget.selectedProfile,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.face,
                                        size: 150,
                                        color: Colors.green,
                                      ),
                                    );
                                  },
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Bottom text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      '이제 우릴 숨겨줄 수 있는 곳들을 찾아가보자!',
                      style: TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '그곳에 가면 특별한 혜택이 기다리고 있어 :)',
                      style: TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final random = math.Random(42); // Fixed seed for consistent positions
    return List.generate(30, (index) {
      final left = random.nextDouble();
      final top = random.nextDouble() * 0.8; // Keep confetti in upper area
      final size = 8.0 + random.nextDouble() * 12;
      final colors = [
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.cyan,
      ];
      final color = colors[index % colors.length];
      final shape = index % 3; // 0: rectangle, 1: circle, 2: diamond

      return Positioned(
        left: MediaQuery.of(context).size.width * left,
        top: MediaQuery.of(context).size.height * top,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * 2 * math.pi,
              child: _buildConfettiShape(shape, size, color),
            );
          },
        ),
      );
    });
  }

  Widget _buildConfettiShape(int shape, double size, Color color) {
    switch (shape) {
      case 0: // Rectangle
        return Container(
          width: size,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case 1: // Circle
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        );
      case 2: // Diamond
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      default:
        return Container();
    }
  }
}