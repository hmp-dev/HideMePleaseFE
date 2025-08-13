import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/onboarding/models/character_profile.dart';
import 'package:mobile/features/onboarding/presentation/widgets/character_layer_widget.dart';

/// Widget that displays user profile avatar
/// Supports both layered rendering (from profilePartsString) and URL-based images
class ProfileAvatarWidget extends StatelessWidget {
  final String? profilePartsString;
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final String placeholderPath;
  final BoxFit fit;

  const ProfileAvatarWidget({
    super.key,
    this.profilePartsString,
    this.imageUrl,
    this.size = 54,
    this.borderRadius = 50,
    this.placeholderPath = "assets/images/launcher-icon.png",
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Priority 1: Use layered rendering if profilePartsString is available
    if (profilePartsString != null && profilePartsString!.isNotEmpty) {
      try {
        final characterData = jsonDecode(profilePartsString!);
        final character = CharacterProfile.fromJson(characterData);
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: size,
            height: size,
            child: CharacterLayerWidget(
              character: character,
              size: size,
              fit: fit,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error parsing profilePartsString: $e');
        // Fall through to URL-based rendering
      }
    }

    // Priority 2: Use image URL if available
    return CustomImageView(
      url: imageUrl,
      fit: fit,
      width: size,
      height: size,
      radius: BorderRadius.circular(borderRadius),
      placeHolder: placeholderPath,
    );
  }
}

/// Circular version of ProfileAvatarWidget with border
class CircularProfileAvatarWidget extends StatelessWidget {
  final String? profilePartsString;
  final String? imageUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow>? shadows;
  final String placeholderPath;

  const CircularProfileAvatarWidget({
    super.key,
    this.profilePartsString,
    this.imageUrl,
    this.size = 200,
    this.borderWidth = 4,
    this.borderColor = Colors.white,
    this.shadows,
    this.placeholderPath = "assets/images/launcher-icon.png",
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    // Try to use layered rendering first
    if (profilePartsString != null && profilePartsString!.isNotEmpty) {
      try {
        final characterData = jsonDecode(profilePartsString!);
        final character = CharacterProfile.fromJson(characterData);
        
        avatarContent = CharacterLayerWidget(
          character: character,
          size: size,
          fit: BoxFit.cover,
        );
      } catch (e) {
        debugPrint('Error parsing profilePartsString: $e');
        // Fall back to image URL
        avatarContent = CustomImageView(
          url: imageUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeHolder: placeholderPath,
        );
      }
    } else {
      // Use image URL
      avatarContent = CustomImageView(
        url: imageUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeHolder: placeholderPath,
      );
    }

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
        child: avatarContent,
      ),
    );
  }
}