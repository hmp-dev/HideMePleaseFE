import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import '../../models/character_profile.dart';
import 'character_layer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class OnboardingPageFourth extends StatefulWidget {
  final String selectedProfile;
  final CharacterProfile? selectedCharacter;
  final Function(String) onNicknameChanged;
  final UserProfileEntity? userProfile;

  const OnboardingPageFourth({
    super.key,
    required this.selectedProfile,
    this.selectedCharacter,
    required this.onNicknameChanged,
    this.userProfile,
  });

  @override
  State<OnboardingPageFourth> createState() => _OnboardingPageFourthState();
}

class _OnboardingPageFourthState extends State<OnboardingPageFourth> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? errorMessage;
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onNicknameChanged);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }
  
  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  Widget _buildProfileImage(bool isKeyboardVisible) {
    final size = isKeyboardVisible ? 200.0 : 280.0;

    // 기존 프로필 이미지가 있는 경우 (finalProfileImageUrl 사용)
    if (widget.userProfile != null &&
        widget.userProfile!.finalProfileImageUrl != null &&
        widget.userProfile!.finalProfileImageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.userProfile!.finalProfileImageUrl!, size);
    }

    // pfpImageUrl이 있는 경우
    if (widget.userProfile != null &&
        widget.userProfile!.pfpImageUrl != null &&
        widget.userProfile!.pfpImageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.userProfile!.pfpImageUrl!, size);
    }

    // 새로 선택한 캐릭터가 있는 경우
    if (widget.selectedCharacter != null) {
      return CharacterLayerWidget(
        character: widget.selectedCharacter!,
        size: size,
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
              size: 100,
              color: Colors.white,
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
        size: 100,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl, double size) {
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
          print('Error loading profile image in nickname page: $error');
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              size: 100,
              color: Colors.red,
            ),
          );
        },
      );
    }

    // 일반 URL은 일반 Image.network 사용
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading profile image: $error');
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.error,
            size: 100,
            color: Colors.red,
          ),
        );
      },
    );
  }

  void _onNicknameChanged() {
    final nickname = _nicknameController.text;

    // Validate nickname
    String? newErrorMessage;
    if (nickname.isEmpty) {
      newErrorMessage = null;
    } else if (nickname.length < 2) {
      newErrorMessage = LocaleKeys.onboarding_fourth_error_min.tr();
    } else if (nickname.length > 15) {
      newErrorMessage = LocaleKeys.onboarding_fourth_error_max.tr();
    } else if (!RegExp(r'^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_]+$', unicode: true).hasMatch(nickname)) {
      newErrorMessage = LocaleKeys.onboarding_fourth_error_invalid.tr();
    } else {
      newErrorMessage = null;
    }
    
    // Only call setState if errorMessage actually changed
    if (newErrorMessage != errorMessage) {
      setState(() {
        errorMessage = newErrorMessage;
      });
    }
    
    // Pass valid nickname to parent after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newErrorMessage == null) {
        widget.onNicknameChanged(nickname);
      } else {
        widget.onNicknameChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    return Container(
      color: const Color(0xFF87CEEB), // Sky blue background
      child: Column(
          children: [
            SizedBox(height: isKeyboardVisible ? 5 : 10),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    LocaleKeys.onboarding_fourth_title1.tr(),
                    style: const TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    LocaleKeys.onboarding_fourth_title2.tr(),
                    style: const TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 26,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                LocaleKeys.onboarding_fourth_desc.tr(),
                style: const TextStyle(
                  fontFamily: 'LINESeedKR',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Character and nickname input
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Character display with background
                      Container(
                        width: isKeyboardVisible ? 200 : 280,
                        height: isKeyboardVisible ? 200 : 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _buildProfileImage(isKeyboardVisible),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Nickname input field
                    Container(
                      width: 260,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
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
                      child: TextField(
                        controller: _nicknameController,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        style: fontBodyMd(color: Colors.black),
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: InputDecoration(
                          hintText: _isFocused || _nicknameController.text.isNotEmpty 
                              ? '' 
                              : LocaleKeys.enter_nickname.tr(),
                          hintStyle: fontBodyMd(color: Colors.black54),
                          border: InputBorder.none,
                          counterText: '', // Hide the counter
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: fontCompactSm(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Helper text
                    Text(
                      LocaleKeys.onboarding_fourth_helper.tr(),
                      style: const TextStyle(
                        fontFamily: 'LINESeedKR',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}