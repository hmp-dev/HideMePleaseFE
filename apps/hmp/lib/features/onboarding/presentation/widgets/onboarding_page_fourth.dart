import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app/theme/theme.dart';
import '../../models/character_profile.dart';
import 'character_layer_widget.dart';

class OnboardingPageFourth extends StatefulWidget {
  final String selectedProfile;
  final CharacterProfile? selectedCharacter;
  final Function(String) onNicknameChanged;
  
  const OnboardingPageFourth({
    super.key,
    required this.selectedProfile,
    this.selectedCharacter,
    required this.onNicknameChanged,
  });

  @override
  State<OnboardingPageFourth> createState() => _OnboardingPageFourthState();
}

class _OnboardingPageFourthState extends State<OnboardingPageFourth> {
  final TextEditingController _nicknameController = TextEditingController();
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onNicknameChanged);
  }
  
  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    super.dispose();
  }
  
  void _onNicknameChanged() {
    final nickname = _nicknameController.text;
    
    // Validate nickname
    String? newErrorMessage;
    if (nickname.isEmpty) {
      newErrorMessage = null;
    } else if (nickname.length < 2) {
      newErrorMessage = '닉네임은 최소 2자 이상이어야 합니다';
    } else if (nickname.length > 15) {
      newErrorMessage = '닉네임은 최대 15자까지 가능합니다';
    } else if (!RegExp(r'^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_]+$', unicode: true).hasMatch(nickname)) {
      newErrorMessage = '닉네임은 영문, 숫자, 한글만 사용 가능합니다';
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
    return Container(
      color: const Color(0xFF87CEEB), // Sky blue background
      child: Column(
          children: [
            const SizedBox(height: 10),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    '마지막으로,',
                    style: TextStyle(
                      fontFamily: 'LINESeedKR',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '하이더에게 이름을 지어줘.',
                    style: TextStyle(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                '이름이 없으면 이 친구들... 말을 안 들어...\n절대히 이상하고 막에 도는 걸로 하나 지어봐!',
                style: TextStyle(
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
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: widget.selectedCharacter != null
                            ? CharacterLayerWidget(
                                character: widget.selectedCharacter!,
                                size: 280,
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
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
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
                        textAlign: TextAlign.center,
                        style: fontBodyMd(color: Colors.black),
                        maxLength: 15,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: InputDecoration(
                          hintText: '닉네임 입력하기',
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
                    const Text(
                      '닉네임은 영어, 숫자, 한글만 가능해. (최대 15자)\n한 번 설정하면 바꿀 수 없어!',
                      style: TextStyle(
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