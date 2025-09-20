import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/character_profile.dart';
import 'character_layer_widget.dart';

class OnboardingPageFifth extends StatefulWidget {
  final String selectedProfile;
  final CharacterProfile? selectedCharacter;
  final String nickname;
  final UserProfileEntity? userProfile;

  const OnboardingPageFifth({
    super.key,
    required this.selectedProfile,
    this.selectedCharacter,
    required this.nickname,
    this.userProfile,
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

  Widget _buildProfileImage() {
    // 기존 프로필이 있는 경우 (finalProfileImageUrl 사용)
    if (widget.userProfile != null &&
        widget.userProfile!.finalProfileImageUrl != null &&
        widget.userProfile!.finalProfileImageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.userProfile!.finalProfileImageUrl!);
    }

    // pfpImageUrl이 있는 경우
    if (widget.userProfile != null &&
        widget.userProfile!.pfpImageUrl != null &&
        widget.userProfile!.pfpImageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.userProfile!.pfpImageUrl!);
    }

    // 새로 선택한 캐릭터가 있는 경우
    if (widget.selectedCharacter != null) {
      return CharacterLayerWidget(
        character: widget.selectedCharacter!,
        size: 320,
        fit: BoxFit.cover,
      );
    }

    // 선택된 프로필 asset 이미지
    if (widget.selectedProfile.isNotEmpty) {
      return Image.asset(
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
      );
    }

    // 기본 placeholder
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 150,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    // dev-api.hidemeplease.xyz URL에 대한 특별 처리
    if (imageUrl.contains('dev-api.hidemeplease.xyz')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        headers: const {
          'Accept': 'image/*',
          'User-Agent': 'HideMePlease/1.0',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading profile image: $error');
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              size: 150,
              color: Colors.red,
            ),
          );
        },
      );
    }

    // 일반 URL은 CachedNetworkImage 사용
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      httpHeaders: const {
        'Accept': 'image/*',
        'User-Agent': 'HideMePlease/1.0',
      },
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        print('Error loading profile image: $error');
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.error,
            size: 150,
            color: Colors.red,
          ),
        );
      },
    );
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
                      LocaleKeys.onboarding_completed_welcome.tr(namedArgs: {'nickname': widget.nickname}),
                      style: const TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      LocaleKeys.onboarding_completed_ready.tr(),
                      style: const TextStyle(
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
                            child: _buildProfileImage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Bottom text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.onboarding_completed_find_places.tr(),
                      style: const TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      LocaleKeys.onboarding_completed_special_benefits.tr(),
                      style: const TextStyle(
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