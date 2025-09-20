import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 튜토리얼을 수동으로 트리거하기 위한 헬퍼 클래스
class TutorialHelper {
  static Future<void> showTutorial(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 임시로 hasSeenHomeGuide를 false로 설정하여 튜토리얼 표시
    await prefs.setBool('hasSeenHomeGuide', false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SpaceGuideOverlay(
        onComplete: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  static Future<void> resetTutorialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasSeenHomeGuide');
    await prefs.remove('dontShowTutorialAgain');
  }
}

class SpaceGuideOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SpaceGuideOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<SpaceGuideOverlay> createState() => _SpaceGuideOverlayState();
}

class _SpaceGuideOverlayState extends State<SpaceGuideOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  List<String> _getImages(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';
    return [
      isEnglish ? 'assets/images/homeguide01_en.png' : 'assets/images/homeguide01.png',
      isEnglish ? 'assets/images/homeguide02_en.png' : 'assets/images/homeguide02.png',
      isEnglish ? 'assets/images/homeguide03_en.png' : 'assets/images/homeguide03.png',
      isEnglish ? 'assets/images/homeguide04_en.png' : 'assets/images/homeguide04.png',
    ];
  }

  List<String> _getMessages(BuildContext context) {
    return [
      LocaleKeys.home_guide_message_1.tr(),
      LocaleKeys.home_guide_message_2.tr(),
      LocaleKeys.home_guide_message_3.tr(),
      LocaleKeys.home_guide_message_4.tr(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext context) {
    final images = _getImages(context);
    if (_currentPage < images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeGuide();
    }
  }

  Future<void> _completeGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenHomeGuide', true);
    
    // "다시 보지 않기" 옵션이 체크되어 있으면 영구적으로 저장
    if (_dontShowAgain) {
      await prefs.setBool('dontShowTutorialAgain', true);
    }
    
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages(context);
    final messages = _getMessages(context);

    return Stack(
      children: [
        // Full screen blocking container
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {}, // Absorb all taps
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.8),
          ),
        ),

        // Guide content
        AbsorbPointer(
          absorbing: false,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background image
                  Center(
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  
                  // Message container at top
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.15,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            messages[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // "다시 보지 않기" 체크박스 (마지막 페이지에만 표시)
                          if (index == images.length - 1) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _dontShowAgain,
                                  onChanged: (value) {
                                    setState(() {
                                      _dontShowAgain = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF2CB3FF),
                                ),
                                Text(
                                  LocaleKeys.dont_show_again.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _nextPage(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2CB3FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                index == images.length - 1 ? LocaleKeys.start_app.tr() : LocaleKeys.next.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Page indicator dots at bottom
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Skip button at top right (except last page)
                  if (index != images.length - 1)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: _completeGuide,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            LocaleKeys.skip.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}