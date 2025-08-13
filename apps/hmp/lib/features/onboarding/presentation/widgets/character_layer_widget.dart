import 'package:flutter/material.dart';
import '../../models/character_profile.dart';

/// Widget that renders character using layered NFT parts
class CharacterLayerWidget extends StatelessWidget {
  final CharacterProfile character;
  final double size;
  final BoxFit fit;

  const CharacterLayerWidget({
    super.key,
    required this.character,
    this.size = 200,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Background
          _buildLayer(character.background),

          // Layer 2: Body
          _buildLayer(character.body),

          // Layer 3: Clothes
          _buildLayer(character.clothes),

          // Layer 4: Hair
          _buildLayer(character.hair),

          // Layer 5: Ear Accessory (optional)
          if (character.earAccessory != null)
            _buildLayer(character.earAccessory!),

          // Layer 6: Eyes
          _buildLayer(character.eyes),

          // Layer 7: Nose
          _buildLayer(character.nose),
        ],
      ),
    );
  }

  Widget _buildLayer(String assetPath) {
    // Skip empty paths
    if (assetPath.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Positioned.fill(
      child: Image.asset(
        assetPath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Return transparent container if image fails to load
          debugPrint('Failed to load image: $assetPath');
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Circular version of the character layer widget
class CircularCharacterLayerWidget extends StatelessWidget {
  final CharacterProfile character;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow>? shadows;

  const CircularCharacterLayerWidget({
    super.key,
    required this.character,
    this.size = 200,
    this.borderWidth = 4,
    this.borderColor = Colors.white,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: ClipOval(
        child: CharacterLayerWidget(
          character: character,
          size: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}