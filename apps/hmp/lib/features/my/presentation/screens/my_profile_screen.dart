import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() {
    print('🎯 MyProfileScreen createState called');
    return _MyProfileScreenState();
  }
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    print('🚀 MyProfileScreen initState called');
    
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
    
    // Always refresh profile data to get latest including profilePartsString
    print('🔄 Refreshing profile data to get latest...');
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
          
          return Stack(
            children: [
              // 그라데이션 배경
              Container(
                height: 450,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFA9F4B6), // 밝은 민트색
                      const Color(0xFFA9F4B6).withOpacity(0.5), // 중간 투명도
                      Colors.black, // 검정색
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
                onTap: () {},
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
          Container(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userProfile?.introduction ?? '을지로에 자주 출물하는 메뚜사',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
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
          _buildStatItem('29', '프렌즈', 'assets/images/ic_myfriend.png'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem('31', '체크인', 'assets/images/ic_mycheckin.png'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem('78', 'SAV', 'assets/images/ic_mysav.png'),
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
            fontSize: 14,
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
          
          // 뱃지 리스트
          Column(
            children: [
              _buildBadgeItemHorizontal(
                '하이드미플리즈 홍제',
                '7회',
                '1일 전 방문',
                const Color(0xFF76CDFF),
                'assets/images/ic_myagit01.png',
              ),
              const SizedBox(height: 12),
              _buildBadgeItemHorizontal(
                '영동호프',
                '5회',
                '오늘 방문',
                Colors.transparent,
                'assets/images/ic_myagit02.png',
              ),
              const SizedBox(height: 12),
              _buildBadgeItemHorizontal(
                '청와옥 을지로점',
                '3회',
                '13일 전 방문',
                Colors.transparent,
                'assets/images/ic_myagit03.png',
              ),
            ],
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
                '2025년 8월',
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
              children: [
                _buildCalendarDay('7', false, true), // 체크인 있음
                _buildCalendarDay('8', false, true), // 체크인 있음
                _buildCalendarDay('9', false, true), // 체크인 있음
                _buildCalendarDay('10', false, false),
                _buildCalendarDay('11', true, false), // 선택된 날짜
                _buildCalendarDay('12', false, false),
                _buildCalendarDay('13', false, false),
              ],
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
      margin: const EdgeInsets.only(right: 12),
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
}