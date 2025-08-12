import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/character_generator.dart';
import '../../models/character_profile.dart';
import 'character_layer_widget.dart';

class OnboardingPageThird extends StatefulWidget {
  final Function(String) onProfileSelected;
  final Function(CharacterProfile)? onCharacterSelected;
  
  const OnboardingPageThird({
    super.key,
    required this.onProfileSelected,
    this.onCharacterSelected,
  });

  @override
  State<OnboardingPageThird> createState() => _OnboardingPageThirdState();
}

class _OnboardingPageThirdState extends State<OnboardingPageThird> {
  late int currentProfileIndex;
  
  // Generate random characters
  late final List<CharacterProfile> characters;

  @override
  void initState() {
    super.initState();
    // Generate 10 random characters
    characters = CharacterGenerator.generateRandomCharacters(10);
    // Initialize with random character
    currentProfileIndex = math.Random().nextInt(characters.length);
    
    // Set initial profile after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final character = characters[currentProfileIndex];
      widget.onProfileSelected(character.id);
      widget.onCharacterSelected?.call(character);
    });
  }

  void _changeProfile() {
    setState(() {
      currentProfileIndex = (currentProfileIndex + 1) % characters.length;
    });
    final character = characters[currentProfileIndex];
    widget.onProfileSelected(character.id);
    widget.onCharacterSelected?.call(character);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF87CEEB),
      child: Column(
        children: [
          const SizedBox(height: 5),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  '이제,',
                  style: TextStyle(
                    fontFamily: 'LINESeedKR',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '너의 하이더를 고를 차례야.',
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
          const SizedBox(height: 10),
          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              '하이더는 이 세계에서 너를 표현해줄 존재지.\n어딘가에 숨어 있거나, 누군가랑 연결될 수도 있어.',
              style: TextStyle(
                fontFamily: 'LINESeedKR',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.4,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          // Character image container
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                    maxHeight: 320,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CharacterLayerWidget(
                      character: characters[currentProfileIndex],
                      size: 320,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Profile counter button
          GestureDetector(
            onTap: _changeProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '다른 걸로 할래 (${currentProfileIndex + 1}/10)',
                    style: const TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Warning text
          const Text(
            '신중해야 해!\n이전의 캐릭터로는 다시 돌아갈 수 없어...',
            style: TextStyle(
              fontFamily: 'LINESeedKR',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}