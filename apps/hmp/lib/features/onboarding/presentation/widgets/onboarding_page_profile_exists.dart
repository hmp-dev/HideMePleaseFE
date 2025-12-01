import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 온보딩 화면 - 프로필이 이미 존재하는 경우
class OnboardingPageProfileExists extends StatelessWidget {
  final UserProfileEntity? userProfile;

  const OnboardingPageProfileExists({
    super.key,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Title
        Text(
          LocaleKeys.onboarding_already_have_1.tr(),
          style: const TextStyle(
            fontFamily: 'LINESeedKR',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          LocaleKeys.onboarding_already_have_2.tr(),
          style: const TextStyle(
            fontFamily: 'LINESeedKR',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          LocaleKeys.onboarding_already_have_desc_1.tr(),
          style: const TextStyle(
            fontFamily: 'LINESeedKR',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            height: 1.4,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          LocaleKeys.onboarding_already_have_desc_2.tr(),
          style: const TextStyle(
            fontFamily: 'LINESeedKR',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            height: 1.4,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // Character image display
        Expanded(
          child: Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display actual profile image or character
                  _buildProfileImage(),
                  const SizedBox(height: 10),
                  Text(
                    LocaleKeys.onboarding_my_hider.tr(),
                    style: const TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 프로필 이미지 또는 캐릭터를 표시하는 위젯
  Widget _buildProfileImage() {
    // finalProfileImageUrl이 있으면 우선적으로 표시
    if (userProfile?.finalProfileImageUrl != null &&
        userProfile!.finalProfileImageUrl!.isNotEmpty) {
      return _buildNetworkImage(userProfile!.finalProfileImageUrl!);
    }

    // pfpImageUrl이 있으면 표시
    if (userProfile?.pfpImageUrl != null &&
        userProfile!.pfpImageUrl!.isNotEmpty) {
      return _buildNetworkImage(userProfile!.pfpImageUrl!);
    }

    // profilePartsString이 있으면 캐릭터 파츠 표시 (향후 구현)
    if (userProfile?.profilePartsString != null &&
        userProfile!.profilePartsString!.isNotEmpty) {
      return _buildCharacterFromParts(userProfile!.profilePartsString!);
    }

    // 기본 placeholder
    return _buildPlaceholder();
  }

  /// 네트워크 이미지를 표시하는 위젯
  Widget _buildNetworkImage(String imageUrl) {
    // URL validation - only log once
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: imageUrl.contains('dev-api.hidemeplease.xyz')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                headers: const {
                  'Accept': 'image/*',
                  'User-Agent': 'HideMePlease/1.0',
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Silent error handling - no repeated logging
                  return _buildPlaceholder();
                },
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                // Add cache key with timestamp to avoid stale cache
                cacheKey: '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}',
                httpHeaders: const {
                  'Accept': 'image/*',
                  'User-Agent': 'HideMePlease/1.0',
                },
                placeholder: (context, url) {
                  return Container(
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  // Silent error handling - no repeated logging
                  return _buildPlaceholder();
                },
              ),
      ),
    );
  }

  /// 캐릭터 파츠로부터 이미지를 생성하는 위젯 (향후 구현)
  Widget _buildCharacterFromParts(String profilePartsString) {
    // Use userId to fetch server-generated image
    // Server generates image from profilePartsString on-demand
    final userId = userProfile?.id;

    if (userId != null && userId.isNotEmpty) {
      // Build image URL using userId
      // Server endpoint: /v1/public/nft/user/{userId}/image
      final imageUrl = 'https://dev-api.hidemeplease.xyz/v1/public/nft/user/$userId/image';

      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 2,
              ),
              color: Colors.green.withValues(alpha: 0.1),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.face,
                  size: 80,
                  color: Colors.green,
                ),
                SizedBox(height: 8),
                Text(
                  '캐릭터 파츠',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Fallback: Show placeholder if userId is not available
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 2,
        ),
        color: Colors.green.withValues(alpha: 0.1),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face,
            size: 80,
            color: Colors.green,
          ),
          SizedBox(height: 8),
          Text(
            '캐릭터 파츠',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// 기본 placeholder를 표시하는 위젯
  Widget _buildPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 80,
            color: Colors.black26,
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}