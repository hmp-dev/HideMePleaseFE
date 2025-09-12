import 'dart:ui';
import 'package:flutter/material.dart';
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

  final List<String> _images = [
    'assets/images/homeguide01.png',
    'assets/images/homeguide02.png',
    'assets/images/homeguide03.png',
    'assets/images/homeguide04.png',
  ];

  final List<String> _messages = [
    '블루체크 매장들은 우리를 숨겨주는 장소야 :)\n블루체크를 클릭하면 이 곳에 대한 정보와\n우리가 받을 수 있는 혜택을 확인할 수 있어!',
    '혜택을 받으려면 아래 체크인 버튼을 눌러봐!\n블루체크 매장에서 NFC 태그 장치에 스캔을 한 후,\n사장님이나 직원에게 확인을 받으면 돼 :)',
    '하이더들은 블루체크 매장에 자신의 목소리를\n남길 수 있고 우린 그걸 [사이렌]이라고 불러.\n사이렌 버튼을 누르고 하이더들의 사이렌을 확인해봐!',
    '그럼, 이제 하미플 세계를 즐겨봐!',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _images.length - 1) {
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
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background image
                  Center(
                    child: Image.asset(
                      _images[index],
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
                            _messages[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // "다시 보지 않기" 체크박스 (마지막 페이지에만 표시)
                          if (index == _images.length - 1) ...[
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
                                const Text(
                                  '다시 보지 않기',
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
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2CB3FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                index == _images.length - 1 ? '앱 시작하기' : '다음',
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
                        _images.length,
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
                  if (index != _images.length - 1)
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
                          child: const Text(
                            '건너뛰기',
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