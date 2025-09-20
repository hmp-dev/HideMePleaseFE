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
    // Priority 1: Use image URL if available (finalProfileImageUrl or pfpImageUrl)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      debugPrint('🎨 ProfileAvatarWidget - Using image URL: $imageUrl');
      debugPrint('🎨 ProfileAvatarWidget - Size: $size x $size');
      return CustomImageView(
        url: imageUrl,
        fit: fit,
        width: size,
        height: size,
        radius: BorderRadius.circular(borderRadius),
        placeHolder: placeholderPath,
      );
    }

    // Priority 2: Use layered rendering if profilePartsString is available
    if (profilePartsString != null && profilePartsString!.isNotEmpty) {
      try {
        debugPrint('🎨 ProfileAvatarWidget - Using profilePartsString');
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
        // Fall through to placeholder
      }
    }

    // Priority 3: Use placeholder
    debugPrint('🎨 ProfileAvatarWidget - Using placeholder');
    return CustomImageView(
      url: null,
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

    // Priority 1: Use image URL if available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      debugPrint('🎨 CircularProfileAvatarWidget - Using image URL: $imageUrl');
      avatarContent = CustomImageView(
        url: imageUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeHolder: placeholderPath,
      );
    }
    // Priority 2: Try to use layered rendering if profilePartsString is available
    else if (profilePartsString != null && profilePartsString!.isNotEmpty) {
      try {
        debugPrint('🎨 CircularProfileAvatarWidget - Using profilePartsString');
        final characterData = jsonDecode(profilePartsString!);
        final character = CharacterProfile.fromJson(characterData);

        avatarContent = CharacterLayerWidget(
          character: character,
          size: size,
          fit: BoxFit.cover,
        );
      } catch (e) {
        debugPrint('Error parsing profilePartsString: $e');
        // Fall back to placeholder
        avatarContent = CustomImageView(
          url: null,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeHolder: placeholderPath,
        );
      }
    } else {
      // Use placeholder
      debugPrint('🎨 CircularProfileAvatarWidget - Using placeholder');
      avatarContent = CustomImageView(
        url: null,
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