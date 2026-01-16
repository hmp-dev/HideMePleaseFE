import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:mobile/features/friends/presentation/widgets/friend_request_button.dart';
import 'package:mobile/features/friends/presentation/widgets/friend_request_dialog.dart';
import 'package:mobile/features/friends/presentation/widgets/friend_request_success_dialog.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/infrastructure/data_sources/profile_remote_data_source.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/widgets/profile_image_fullscreen_viewer.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/siren_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  static Future<void> push(BuildContext context, {required String userId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Color _dominantColor = const Color(0xFFEAF8FF);
  bool _isLoadingColor = false;
  bool _colorExtracted = false;
  final GlobalKey _profileKey = GlobalKey();

  UserProfileEntity? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    print('🚀 UserProfileScreen initState - userId: ${widget.userId}');

    // 친구 관계 상태 체크
    final friendsCubit = getIt<FriendsCubit>();
    friendsCubit.resetFriendshipStatus();
    friendsCubit.checkFriendshipStatus(widget.userId);

    // 친구 통계 로드 (친구 수 표시를 위해)
    friendsCubit.getFriendStats();

    // 사용자 프로필 로드
    _loadUserProfile();

    // 위젯이 빌드된 후 색상 추출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_colorExtracted) {
        _extractDominantColorFromWidget();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoadingProfile = true);

    try {
      final dataSource = getIt<ProfileRemoteDataSource>();
      final profileDto = await dataSource.getUserProfile(userId: widget.userId);

      if (mounted) {
        setState(() {
          _userProfile = profileDto.toEntity();
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('❌ Failed to load user profile: $e');
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _extractDominantColorFromWidget() async {
    if (!mounted) return;
    if (_colorExtracted) return;

    setState(() => _isLoadingColor = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final RenderRepaintBoundary? boundary =
          _profileKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final Uint8List pngBytes = byteData.buffer.asUint8List();

          final paletteGenerator = await PaletteGenerator.fromImageProvider(
            MemoryImage(pngBytes),
          );

          if (mounted) {
            setState(() {
              _dominantColor = paletteGenerator.vibrantColor?.color ??
                             paletteGenerator.dominantColor?.color ??
                             const Color(0xFFA9F4B6);
              _isLoadingColor = false;
              _colorExtracted = true;
            });
          }
        }
      }
    } catch (e) {
      print('색상 추출 실패: $e');
      if (mounted) {
        setState(() {
          _dominantColor = const Color(0xFFA9F4B6);
          _isLoadingColor = false;
          _colorExtracted = true;
        });
      }
    }
  }

  Future<void> _handleFriendRequest() async {
    if (_userProfile == null) return;

    // 세이보리 잔액 확인 (친구 신청에 5 SAV 필요)
    final profileCubit = getIt<ProfileCubit>();
    final currentBalance = profileCubit.state.userProfileEntity.availableBalance;

    if (currentBalance < 5) {
      // 잔액 부족 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF000000), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.insufficient_savory_balance.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff00A3FF), Color(0xff5FC5FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF000000), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        LocaleKeys.confirm.tr(),
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // 다이얼로그 표시 (신청 모드)
    final confirmed = await FriendRequestDialog.show(
      context,
      nickName: _userProfile!.nickName,
      profileImageUrl: _userProfile!.finalProfileImageUrl ?? _userProfile!.pfpImageUrl,
      introduction: _userProfile!.introduction,
      isAcceptMode: false, // 신청 모드
    );

    if (confirmed == true) {
      // 친구 신청 보내기
      final friendsCubit = getIt<FriendsCubit>();
      await friendsCubit.sendFriendRequest(widget.userId);

      // 성공 다이얼로그 표시
      if (mounted && friendsCubit.state.submitStatus == RequestStatus.success) {
        // 현재 사용자의 프로필을 다시 로드하여 최신 포인트 가져오기
        final profileCubit = getIt<ProfileCubit>();
        await profileCubit.init();

        await FriendRequestSuccessDialog.show(
          context,
          savoryBalance: profileCubit.state.userProfileEntity.availableBalance,
          isAcceptMode: false, // 신청 모드
        );

        // 상대방 프로필 새로고침
        await _loadUserProfile();
      }
    }
  }

  Future<void> _handleAcceptFriendRequest() async {
    if (_userProfile == null) return;

    final friendsCubit = getIt<FriendsCubit>();
    final friendshipId = friendsCubit.state.friendshipId;

    if (friendshipId == null) {
      print('❌ friendshipId is null, cannot accept request');
      return;
    }

    // 다이얼로그 표시 (수락 모드)
    final confirmed = await FriendRequestDialog.show(
      context,
      nickName: _userProfile!.nickName,
      profileImageUrl: _userProfile!.finalProfileImageUrl ?? _userProfile!.pfpImageUrl,
      introduction: _userProfile!.introduction,
      isAcceptMode: true, // 수락 모드
    );

    if (confirmed == true) {
      // 친구 신청 수락
      await friendsCubit.acceptFriendRequest(friendshipId);

      // 성공 다이얼로그 표시
      if (mounted && friendsCubit.state.submitStatus == RequestStatus.success) {
        // 현재 사용자의 프로필을 다시 로드하여 최신 포인트 가져오기
        final profileCubit = getIt<ProfileCubit>();
        await profileCubit.init();

        await FriendRequestSuccessDialog.show(
          context,
          savoryBalance: profileCubit.state.userProfileEntity.availableBalance,
          isAcceptMode: true, // 수락 모드
        );

        // 상대방 프로필 새로고침
        await _loadUserProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAF8FF),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAF8FF),
        body: Center(
          child: Text(
            LocaleKeys.somethingError.tr(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      body: Stack(
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
                  const Color(0xFFEAF8FF),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 상단 헤더 (백 버튼)
                  _buildTopHeader(),

                  const SizedBox(height: 20),

                  // 프로필 이미지
                  _buildProfileImage(),

                  const SizedBox(height: 20),

                  // 이름과 소개
                  _buildNameAndIntro(),

                  const SizedBox(height: 30),

                  // 통계 섹션
                  _buildStatsSection(),

                  const SizedBox(height: 20),

                  // 친구 신청 버튼 (타인일 경우)
                  _buildFriendRequestButton(),

                  const SizedBox(height: 12),

                  // 차단 버튼 (타인일 경우)
                  _buildBlockButton(),

                  const SizedBox(height: 100), // 바텀바 공간
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    final isHiding = _userProfile?.checkInStats?.activeCheckIn != null;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
          // 하이딩 중 태그 - 가운데 정렬 (탭하면 매장으로 이동)
          GestureDetector(
            onTap: isHiding ? () async {
              final activeCheckIn = _userProfile?.checkInStats?.activeCheckIn;
              if (activeCheckIn != null) {
                final spaceId = activeCheckIn.spaceId;
                final spaceCubit = getIt<SpaceCubit>();
                await spaceCubit.onGetSpaceDetailBySpaceId(spaceId: spaceId);
                if (mounted) {
                  SpaceDetailScreen.push(context);
                }
              }
            } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF132E41), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isHiding ? const Color(0xFF19BAFF) : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isHiding ? LocaleKeys.hiding_status.tr() : LocaleKeys.before_hiding.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF132E41),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // 백 버튼 - 왼쪽 고정
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF132E41),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _showProfileImageFullscreen();
        },
        child: RepaintBoundary(
          key: _profileKey,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: ProfileAvatarWidget(
                profilePartsString: _userProfile?.profilePartsString,
                imageUrl: _userProfile?.finalProfileImageUrl ?? _userProfile?.pfpImageUrl,
                size: 300,
                borderRadius: 0,
                placeholderPath: 'assets/images/profile_img.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndIntro() {
    return Column(
      children: [
        // 이름
        Text(
          _userProfile?.nickName ?? 'Unknown',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // 소개
        if (_userProfile?.introduction?.isNotEmpty == true)
          Text(
            _userProfile!.introduction!,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final friendCount = _userProfile?.friendsCount?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF72CCFF),
            const Color(0xFFBED7FF),
            const Color(0xFFF9F395),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(friendCount, LocaleKeys.friends.tr(), 'assets/icons/icon_status_friends.png'),
          _buildStatItem(_userProfile?.checkInStats?.totalCheckIns?.toString() ?? '0', LocaleKeys.check_in.tr(), 'assets/icons/icon_status_checkin.png'),
          _buildStatItem(_userProfile?.availableBalance?.toString() ?? '0', 'SAVORY', 'assets/icons/icon_status_sav.png'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, String iconPath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              color: Colors.black.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFriendRequestButton() {
    // 자신의 프로필인 경우 버튼을 표시하지 않음
    final currentUserId = getIt<ProfileCubit>().state.userProfileEntity.id;
    if (currentUserId == widget.userId) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<FriendsCubit, FriendsState>(
      bloc: getIt<FriendsCubit>(),
      builder: (context, state) {
        return FriendRequestButton(
          friendshipStatus: state.friendshipStatus,
          onPressed: () {
            if (state.friendshipStatus == null) {
              // 친구 관계 없음 → 친구 신청
              _handleFriendRequest();
            } else if (state.friendshipStatus == FriendshipStatus.PENDING_RECEIVED) {
              // 받은 신청 → 수락
              _handleAcceptFriendRequest();
            }
            // PENDING_SENT, ACCEPTED는 클릭 불가 (버튼 비활성화)
          },
          isLoading: state.submitStatus == RequestStatus.loading,
        );
      },
    );
  }

  void _showProfileImageFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileImageFullscreenViewer(
          profilePartsString: _userProfile?.profilePartsString,
          imageUrl: _userProfile?.finalProfileImageUrl ?? _userProfile?.pfpImageUrl,
        ),
      ),
    );
  }

  Widget _buildBlockButton() {
    // 자신의 프로필인 경우 버튼을 표시하지 않음
    final currentUserId = getIt<ProfileCubit>().state.userProfileEntity.id;
    if (currentUserId == widget.userId) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _showBlockDialog,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFF000000), width: 1),
          ),
          child: Center(
            child: Text(
              LocaleKeys.block_user.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFEAF8FF),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF132E41),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Text(
                  LocaleKeys.block_user_title.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
                const SizedBox(height: 16),

                // 메시지
                Text(
                  LocaleKeys.block_user_message.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0x4D000000),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(0xFF000000),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.block_user_cancel.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'LINESeedKR',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 차단하기 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          getIt<SirenCubit>().blockUser(widget.userId);
                          _showBlockSuccessDialog();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(0xFF000000),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.block_user_confirm.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'LINESeedKR',
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
  }

  void _showBlockSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        // 2초 후 자동 닫힘 + 이전 화면으로 이동
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          }
          if (mounted && Navigator.of(this.context).canPop()) {
            Navigator.of(this.context).pop(); // 프로필 화면 닫기
          }
        });

        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            Navigator.of(this.context).pop(); // 프로필 화면 닫기
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFEAF8FF),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF132E41),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.block_user_success_title.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132E41),
                      fontFamily: 'LINESeedKR',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocaleKeys.block_user_success_message.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF132E41),
                      fontFamily: 'LINESeedKR',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
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
                  LocaleKeys.coming_soon.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.coming_soon.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19BAFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      LocaleKeys.confirm.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
