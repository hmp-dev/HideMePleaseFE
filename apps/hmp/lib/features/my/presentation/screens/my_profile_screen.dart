import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/wallets/presentation/screens/connected_wallets_list_view.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() {
    print('🎯 MyProfileScreen createState called');
    return _MyProfileScreenState();
  }
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Color _dominantColor = const Color(0xFFA9F4B6); // 기본 민트색
  bool _isLoadingColor = false;
  final GlobalKey _profileKey = GlobalKey(); // 프로필 위젯 캡처용
  
  // 나의 아지트 데이터 배열 (TODO: 서버 데이터로 교체)
  final List<Map<String, dynamic>> myHidingSpots = [
    // 임시로 빈 배열로 설정
    // {
    //   'title': '하이드미플리즈 홍제',
    //   'count': '7회',
    //   'lastVisit': '1일 전 방문',
    //   'color': const Color(0xFF76CDFF),
    //   'icon': 'assets/images/ic_myagit01.png',
    // },
    // {
    //   'title': '영동호프',
    //   'count': '5회',
    //   'lastVisit': '오늘 방문',
    //   'color': Colors.transparent,
    //   'icon': 'assets/images/ic_myagit02.png',
    // },
    // {
    //   'title': '청와옥 을지로점',
    //   'count': '3회',
    //   'lastVisit': '13일 전 방문',
    //   'color': Colors.transparent,
    //   'icon': 'assets/images/ic_myagit03.png',
    // },
  ];

  @override
  void initState() {
    super.initState();
    print('🚀 MyProfileScreen initState called');
    
    // Google 토큰 새로고침 (WePIN 사용을 위해)
    final authCubit = getIt<AuthCubit>();
    authCubit.refreshGoogleAccessToken().then((token) {
      if (token != null && token.isNotEmpty) {
        print('✅ Google 토큰 새로고침 성공');
      } else {
        print('⚠️ Google 토큰 새로고침 실패 또는 비어있음');
      }
    });
    
    // WePIN SDK 초기화 확인 및 실행
    final wepinCubit = getIt<WepinCubit>();
    if (wepinCubit.state.wepinWidgetSDK == null) {
      print('⚠️ WePIN SDK가 초기화되지 않음, 초기화 시도');
      wepinCubit.initializeWepinSDK(
        selectedLanguageCode: context.locale.languageCode,
      );
    } else {
      print('✅ WePIN SDK 이미 초기화됨: ${wepinCubit.state.wepinLifeCycleStatus}');
    }
    
    // ProfileCubit is already initialized in start_up_screen
    // Just get the current state and refresh if needed
    final profileCubit = getIt<ProfileCubit>();
    final currentState = profileCubit.state;
    
    print('📊 Current ProfileState:');
    print('  - userProfileEntity: ${currentState.userProfileEntity}');
    print('  - nickName: ${currentState.userProfileEntity?.nickName}');
    if (currentState.userProfileEntity?.profilePartsString != null && 
        currentState.userProfileEntity!.profilePartsString!.isNotEmpty) {
      print('  - profilePartsString length: ${currentState.userProfileEntity!.profilePartsString!.length}');
      print('  - profilePartsString preview: ${currentState.userProfileEntity!.profilePartsString!.substring(0, math.min(50, currentState.userProfileEntity!.profilePartsString!.length))}...');
    } else {
      print('  - profilePartsString: NULL or EMPTY');
    }
    
    // Only refresh profile data if it's missing
    if (currentState.userProfileEntity?.profilePartsString == null || 
        currentState.userProfileEntity!.profilePartsString!.isEmpty) {
      print('🔄 Profile data missing, refreshing...');
      profileCubit.onGetUserProfile().then((_) {
        print('✅ Profile data refreshed');
        final newState = profileCubit.state;
        print('📊 After refresh:');
        print('  - nickName: ${newState.userProfileEntity?.nickName}');
        if (newState.userProfileEntity?.profilePartsString != null && 
            newState.userProfileEntity!.profilePartsString!.isNotEmpty) {
          print('  - profilePartsString length: ${newState.userProfileEntity!.profilePartsString!.length}');
          print('  - profilePartsString preview: ${newState.userProfileEntity!.profilePartsString!.substring(0, math.min(50, newState.userProfileEntity!.profilePartsString!.length))}...');
        } else {
          print('  - profilePartsString: STILL NULL or EMPTY');
        }
      }).catchError((error) {
        print('❌ Profile refresh error: $error');
      });
    }
    
    // 위젯이 빌드된 후 색상 추출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractDominantColorFromWidget();
    });
  }

  Future<void> _extractDominantColorFromWidget() async {
    setState(() => _isLoadingColor = true);
    
    try {
      // 잠시 대기하여 위젯이 완전히 렌더링되도록 함
      await Future.delayed(const Duration(milliseconds: 500));
      
      // RenderRepaintBoundary를 사용하여 위젯을 이미지로 캡처
      final RenderRepaintBoundary? boundary = 
          _profileKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final ByteData? byteData = 
            await image.toByteData(format: ui.ImageByteFormat.png);
        
        if (byteData != null) {
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          
          // 메모리 이미지에서 팔레트 생성
          final paletteGenerator = await PaletteGenerator.fromImageProvider(
            MemoryImage(pngBytes),
          );
          
          setState(() {
            // 주요 색상 선택 (우선순위: vibrant > dominant > 기본색)
            _dominantColor = paletteGenerator.vibrantColor?.color ??
                           paletteGenerator.dominantColor?.color ??
                           const Color(0xFFA9F4B6);
            _isLoadingColor = false;
          });
        }
      }
    } catch (e) {
      print('색상 추출 실패: $e');
      setState(() {
        _dominantColor = const Color(0xFFA9F4B6);
        _isLoadingColor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ MyProfileScreen build() called');
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        bloc: getIt<ProfileCubit>(),
        builder: (context, state) {
          print('🔨 BlocBuilder builder called');
          final userProfile = state.userProfileEntity;
          
          // 디버깅용 로그
          print('🔍 MyProfile Widget Build:');
          if (userProfile != null) {
            print('  - nickName: ${userProfile.nickName}');
            if (userProfile.profilePartsString != null && userProfile.profilePartsString!.isNotEmpty) {
              print('  - profilePartsString length: ${userProfile.profilePartsString!.length}');
              print('  - profilePartsString preview: ${userProfile.profilePartsString!.substring(0, math.min(100, userProfile.profilePartsString!.length))}...');
            } else {
              print('  - profilePartsString: NULL or EMPTY');
            }
            print('  - finalProfileImageUrl: ${userProfile.finalProfileImageUrl ?? "NULL"}');
            print('  - pfpImageUrl: ${userProfile.pfpImageUrl ?? "NULL"}');
          } else {
            print('  - userProfile is NULL');
          }
          print('  - state.submitStatus: ${state.submitStatus}');
          
          // 프로필 데이터 변경 시 색상 재추출
          if (userProfile?.profilePartsString != null && !_isLoadingColor) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _extractDominantColorFromWidget();
            });
          }
          
          return Stack(
            children: [
              // 그라데이션 배경
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 450,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _dominantColor,
                      _dominantColor.withOpacity(0.5),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // 하이딩 중 태그 (프로필 위 중앙)
                      _buildHidingStatus(),
                      
                      const SizedBox(height: 20),
                      
                      // 프로필 섹션 (좌우 버튼 포함)
                      _buildProfileWithButtons(userProfile),
                      
                      const SizedBox(height: 16),
                      
                      // 이름과 소개
                      _buildNameAndIntro(userProfile),
                      
                      const SizedBox(height: 30),
                      
                      // 통계 섹션
                      _buildStatsSection(),
                      
                      const SizedBox(height: 30),
                      
                      // 나의 아지트 섹션
                      _buildMyHidingSpotsSection(),
                      
                      // 나의 캘린더 섹션
                      _buildMyCalendarSection(),
                      
                      const SizedBox(height: 100), // 바텀바 공간
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHidingStatus() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF19BAFF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '하이딩 중',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF333333),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileWithButtons(userProfile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 왼쪽 버튼들 (찜, 지갑)
          Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 34,
                  height: 34,
                  color: Colors.transparent,
                  child: Image.asset(
                    'assets/icons/ic_myzzim.png',
                    width: 34,
                    height: 34,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '찜',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  print('🔘 지갑 버튼 클릭됨');
                  
                  try {
                    final wepinCubit = getIt<WepinCubit>();
                    // openWepinWidget이 모든 상태를 처리
                    // initialized 상태에서 loginSocialAuthProvider가 토큰 새로고침을 처리
                    await wepinCubit.openWepinWidget(context);
                  } catch (e) {
                    print('❌ 지갑 버튼 에러: $e');
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.transparent,
                  child: Image.asset(
                    'assets/icons/ic_mywallet.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '지갑',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 20),
          
          // 프로필 이미지 - 더 크게 (버튼 2개 높이 + 간격보다 크게)
          RepaintBoundary(
            key: _profileKey,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF72CCFF),
                    const Color(0xFFF9F395),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: ProfileAvatarWidget(
                        profilePartsString: userProfile?.profilePartsString,
                        imageUrl: userProfile?.finalProfileImageUrl ?? userProfile?.pfpImageUrl,
                        size: 154,
                        borderRadius: 0, // Already clipped by parent ClipRRect
                        placeholderPath: 'assets/images/profile_img.png',  // Use launcher icon as default
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // 오른쪽 버튼들 (알림, 설정)
          Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 30,
                      height: 30,
                      color: Colors.transparent,
                      child: Image.asset(
                        'assets/icons/ic_mynoti.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '알림',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // 설정 화면으로 이동
                  getIt<SettingsCubit>().onGetSettingBannerInfo();
                  SettingsScreen.push(context);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.transparent,
                  child: Image.asset(
                    'assets/icons/ic_mysetting.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '설정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndIntro(userProfile) {
    return Column(
      children: [
        // 이름
        Text(
          userProfile?.nickName ?? 'Jaeleah',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 소개
        GestureDetector(
          onTap: () => _showEditIntroDialog(context, userProfile?.introduction ?? ''),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userProfile?.introduction?.isNotEmpty == true 
                    ? userProfile!.introduction! 
                    : '너를 소개해봐',
                style: TextStyle(
                  color: userProfile?.introduction?.isNotEmpty == true
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontStyle: userProfile?.introduction?.isNotEmpty == true
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('0', '프렌즈', 'assets/images/ic_myfriend.png'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem('0', '체크인', 'assets/images/ic_mycheckin.png'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem('0', 'SAV', 'assets/images/ic_mysav.png'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, String iconPath) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyHidingSpotsSection() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '나의 아지트',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '누적 방문횟수',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          // 뱃지 리스트 - 데이터 배열 기반 렌더링
          myHidingSpots.isNotEmpty 
            ? Column(
                children: myHidingSpots.map((spot) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBadgeItemHorizontal(
                      spot['title'] as String,
                      spot['count'] as String,
                      spot['lastVisit'] as String,
                      spot['color'] as Color,
                      spot['icon'] as String,
                    ),
                  ),
                ).toList(),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        '🏠',
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '너만의 숨을 곳을 만들어봐 :)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildBadgeItemHorizontal(String title, String count, String lastVisit, Color color, String iconPath) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: (color == Colors.transparent) ? BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ) : BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            Color(0xFFC8EBFF).withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 50,
            height: 50,
            child: Center(
              child: Image.asset(
                iconPath,
                width: 35,
                height: 35,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: (color != Colors.transparent) ? Colors.black : Colors.white,
                    fontSize: (color != Colors.transparent) ? 17 :15,
                    fontWeight: (color != Colors.transparent) ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                Text(
                  lastVisit,
                  style: TextStyle(
                    color: (color != Colors.transparent) ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 방문 횟수
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: (color != Colors.transparent) ? Colors.black : Colors.white,
                fontSize: (color != Colors.transparent) ? 18 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCalendarSection() {
    final now = DateTime.now();
    final DateFormat monthYearFormat = DateFormat('yyyy년 M월', 'ko');
    
    // 오늘 기준으로 전후 3일씩 날짜 생성 (총 7일)
    final List<DateTime> weekDays = [];
    for (int i = -3; i <= 3; i++) {
      weekDays.add(now.add(Duration(days: i)));
    }
    
    // 임시 체크인 데이터 (TODO: 서버 데이터로 교체)
    final Map<int, bool> checkInData = {
      now.subtract(const Duration(days: 3)).day: true,
      now.subtract(const Duration(days: 2)).day: true,
      now.subtract(const Duration(days: 1)).day: true,
    };
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '나의 캘린더',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                monthYearFormat.format(now),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 캘린더 날짜들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weekDays.map((date) {
                final bool isToday = date.day == now.day && 
                                    date.month == now.month &&
                                    date.year == now.year;
                final bool hasCheckIn = checkInData[date.day] ?? false;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCalendarDay(
                    date.day.toString(),
                    isToday,  // 오늘 날짜면 선택된 것으로 표시
                    hasCheckIn,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () {},
            child: const Text(
              '전체보기',
              style: TextStyle(
                color: Color(0xFF19BAFF),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(String day, bool isSelected, bool hasCheckIn) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected 
            ? Colors.transparent
            : hasCheckIn
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF19BAFF)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasCheckIn && day == '7')
            Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage('assets/images/profile_img.png'),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (hasCheckIn && day == '8')
            Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.orange.withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  '🍺',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else if (hasCheckIn && day == '9')
            Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.brown.withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  '☕',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            const SizedBox(height: 30),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              color: isSelected ? const Color(0xFF19BAFF) : Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditIntroDialog(BuildContext context, String currentIntro) {
    final TextEditingController textController = TextEditingController(text: currentIntro);
    int characterCount = currentIntro.length;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth * 0.9;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: (screenWidth - dialogWidth) / 2),
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF23B0FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목
                    const Text(
                      '자기소개',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 입력 필드
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: textController,
                            maxLength: 20,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '너에 대해 설명해봐!',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (value) {
                              setState(() {
                                characterCount = value.length;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$characterCount/20',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 버튼들
                    Row(
                      children: [
                        // 취소 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF878787),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 확인 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // 프로필 업데이트
                              getIt<ProfileCubit>().onUpdateUserProfile(
                                UpdateProfileRequestDto(
                                  introduction: textController.text,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2CB3FF),
                                    Color(0xFF7CD0FF),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Text(
                                  '이렇게 할게!',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}