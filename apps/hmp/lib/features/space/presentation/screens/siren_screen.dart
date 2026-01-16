import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/space/presentation/cubit/siren_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/siren_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/features/friends/presentation/screens/user_profile_screen.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/profile_avatar_widget.dart';

class SirenScreen extends StatefulWidget {
  const SirenScreen({Key? key}) : super(key: key);

  @override
  State<SirenScreen> createState() => _SirenScreenState();
}

class _SirenScreenState extends State<SirenScreen> {
  final SirenCubit _sirenCubit = getIt<SirenCubit>();
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    _sirenCubit.loadReportedSirenIds();
    _sirenCubit.loadBlockedUserIds();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _loadSirens();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _loadSirens();
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });

      _loadSirens();
    } catch (e) {
      print('❌ Error getting location: $e');
      // 위치 정보 없이도 사이렌 로드 (거리 정보는 표시되지 않음)
      _loadSirens();
    }
  }

  void _loadSirens() {
    print('🔄 [SirenScreen] Loading sirens - sortBy: ${_sirenCubit.state.sortBy}, location: ($_currentLatitude, $_currentLongitude)');
    _sirenCubit.fetchSirenList(
      sortBy: _sirenCubit.state.sortBy,
      latitude: _currentLatitude,
      longitude: _currentLongitude,
    );
  }

  void _onChangeSortBy(String sortBy) {
    _sirenCubit.changeSortBy(sortBy);
    _loadSirens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.15, 0.85, 1.0],
            colors: [
              Color(0x9923B0FF),
              Color(0xFFEAF8FF),
              Color(0xFFEAF8FF),
              Color(0xff23B0FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더 (탭 + 정보 아이콘)
              _buildHeader(),

              // 안내 메시지
              _buildInfoMessage(),

              // 사이렌 리스트
              Expanded(
                child: BlocBuilder<SirenCubit, SirenState>(
                  bloc: _sirenCubit,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.sirenList.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadSirens();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 16,
                          bottom: 100,
                        ),
                        itemCount: state.sirenList.length,
                        itemBuilder: (context, index) {
                          final siren = state.sirenList[index];
                          return _buildSirenCard(siren);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<SirenCubit, SirenState>(
      bloc: _sirenCubit,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Spacer(),
              // 탭 (거리순/최신순) - 가운데 정렬
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _onChangeSortBy('distance'),
                    child: Text(
                      LocaleKeys.siren_sort_distance.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: state.sortBy == 'distance' ? FontWeight.bold : FontWeight.normal,
                        color: state.sortBy == 'distance'
                            ? const Color(0xFF132E41)
                            : const Color(0xFF132E41).withOpacity(0.4),
                        fontFamily: 'LINESeedKR',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _onChangeSortBy('time'),
                    child: Text(
                      LocaleKeys.siren_sort_time.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: state.sortBy == 'time' ? FontWeight.bold : FontWeight.normal,
                        color: state.sortBy == 'time'
                            ? const Color(0xFF132E41)
                            : const Color(0xFF132E41).withOpacity(0.4),
                        fontFamily: 'LINESeedKR',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 정보 아이콘 - 우측
              GestureDetector(
                onTap: _showSirenInfoDialog,
                child: Image.asset(
                  'assets/icons/siren2_deact.png',
                  width: 22,
                  height: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A3FF), width: 1),
      ),
      child: Row(
        children: [
          const Text(
            '안내',
            style: TextStyle(
              color: Color(0xFF00A3FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'LINESeedKR',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LocaleKeys.siren_info_message.tr(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF132E41),
                fontFamily: 'LINESeedKR',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -60), // 헤더+인포 높이 절반만큼 위로
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            LocaleKeys.siren_empty_message.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF132E41),
              fontFamily: 'LINESeedKR',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSirenCard(dynamic siren) {
    final locale = context.locale.languageCode;
    final isEnglish = locale == 'en';
    final spaceName = isEnglish && siren.space?.nameEn.isNotEmpty == true
        ? siren.space!.nameEn
        : siren.space?.name ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF132E41), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 닉네임 @매장명 + 신고 버튼
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final spaceId = siren.space?.id;
                      if (spaceId != null && spaceId.isNotEmpty) {
                        getIt<SpaceCubit>().onGetSpaceDetailBySpaceId(spaceId: spaceId);
                        SpaceDetailScreen.push(context);
                      }
                    },
                    child: Text(
                      '${siren.author?.nickName ?? 'Unknown'} ${spaceName.isNotEmpty ? '@$spaceName' : '@Unknown'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132E41),
                        fontFamily: 'LINESeedKR',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 신고 버튼
                GestureDetector(
                  onTap: () => _showReportDialog(siren),
                  child: Image.asset(
                    'assets/icons/ico_report.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 프로필 이미지 + 메시지/시간 Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 프로필 이미지
                GestureDetector(
                  onTap: () {
                    final userId = siren.author?.userId ?? '';
                    if (userId.isNotEmpty) {
                      UserProfileScreen.push(context, userId: userId);
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF132E41), width: 1),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: ProfileAvatarWidget(
                        profilePartsString: null,
                        imageUrl: siren.author?.profileImageUrl,
                        size: 90,
                        borderRadius: 0,
                        placeholderPath: 'assets/images/profile_img.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 메시지와 시간/거리
                Expanded(
                  child: SizedBox(
                    height: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 메시지
                        Text(
                          siren.message ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF132E41),
                            fontFamily: 'LINESeedKR',
                          ),
                        ),
                        // 시간 | 거리
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _getTimeAgo(siren.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF132E41).withOpacity(0.6),
                                fontFamily: 'LINESeedKR',
                              ),
                            ),
                            if (_currentLatitude != null && _currentLongitude != null) ...[
                              Text(
                                ' | ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF132E41).withOpacity(0.6),
                                  fontFamily: 'LINESeedKR',
                                ),
                              ),
                              Text(
                                LocaleKeys.siren_distance_from_me.tr(args: [
                                  '${(siren.distance / 1000).toStringAsFixed(1)}'
                                ]),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF132E41).withOpacity(0.6),
                                  fontFamily: 'LINESeedKR',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(String createdAt) {
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);

      if (difference.inDays > 0) {
        return LocaleKeys.siren_time_days_ago.tr(args: ['${difference.inDays}']);
      } else if (difference.inHours > 0) {
        return LocaleKeys.siren_time_hours_ago.tr(args: ['${difference.inHours}']);
      } else if (difference.inMinutes > 0) {
        return LocaleKeys.siren_time_minutes_ago.tr(args: ['${difference.inMinutes}']);
      } else {
        return LocaleKeys.siren_time_just_now.tr();
      }
    } catch (e) {
      return '';
    }
  }

  void _showSirenInfoDialog() {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/ico_siren_info.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.siren_info_title.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132E41),
                        fontFamily: 'LINESeedKR',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 설명
                Text(
                  LocaleKeys.siren_info_description.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 확인 버튼
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A3FF),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF000000),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        LocaleKeys.got_it_button.tr(),
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(dynamic siren) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  LocaleKeys.siren_report_title.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132E41),
                    fontFamily: 'LINESeedKR',
                  ),
                ),
                const SizedBox(height: 20),

                // 신고 사유 목록
                _buildReportReasonItem(LocaleKeys.siren_report_reason_sexual.tr()),
                const SizedBox(height: 8),
                _buildReportReasonItem(LocaleKeys.siren_report_reason_hate.tr()),
                const SizedBox(height: 8),
                _buildReportReasonItem(LocaleKeys.siren_report_reason_violence.tr()),
                const SizedBox(height: 8),
                _buildReportReasonItem(LocaleKeys.siren_report_reason_other.tr()),

                const SizedBox(height: 20),

                // 안내 문구
                Text(
                  LocaleKeys.siren_report_notice.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF132E41).withOpacity(0.7),
                    fontFamily: 'LINESeedKR',
                  ),
                ),

                const SizedBox(height: 24),

                // 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      flex: 1,
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
                              LocaleKeys.siren_report_cancel.tr(),
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
                    // 신고하기 버튼
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _sirenCubit.reportSiren(siren.id);
                          _showReportSuccessDialog();
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
                              LocaleKeys.siren_report_submit.tr(),
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

  Widget _buildReportReasonItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF132E41),
            fontFamily: 'LINESeedKR',
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF132E41),
              fontFamily: 'LINESeedKR',
            ),
          ),
        ),
      ],
    );
  }

  void _showReportSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        // 2초 후 자동 닫힘
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
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
                  // 아이콘 + 제목
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/ico_siren_info.png',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleKeys.siren_report_success_title.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF132E41),
                          fontFamily: 'LINESeedKR',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 부제목
                  Text(
                    LocaleKeys.siren_report_success_message.tr(),
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

  @override
  void dispose() {
    // SirenCubit은 lazySingleton이므로 close하지 않음
    super.dispose();
  }
}
