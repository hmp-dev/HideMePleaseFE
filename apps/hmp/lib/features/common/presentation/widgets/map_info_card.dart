import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MapInfoCard extends StatelessWidget {
  final SpaceEntity space;
  final bool showAnimation;
  final double opacity;

  const MapInfoCard({
    super.key,
    required this.space,
    this.showAnimation = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final widget = GestureDetector(
      onTap: () async {
        // 인포카드 클릭 시 상세 화면으로 이동
        final spaceCubit = getIt<SpaceCubit>();
        await spaceCubit.onGetSpaceDetailBySpaceId(spaceId: space.id);
        
        if (context.mounted && spaceCubit.state.spaceDetailEntity != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SpaceDetailScreen(),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8F8F8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 배경 패턴 - 지그재그
            Positioned(
              top: -10,
              right: -10,
              child: Transform.rotate(
                angle: 0.1,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A3FF).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // 컨텐츠
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 매장 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFF3A3A3A),
                      child: space.image.isNotEmpty && !space.image.contains('undefined')
                          ? Image.network(
                              space.image,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A3FF)),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ 이미지 로드 에러: ${space.image}');
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[600],
                                    size: 30,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xFF3A3A3A),
                              child: Center(
                                child: Icon(
                                  Icons.store,
                                  color: Colors.grey[600],
                                  size: 30,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 매장 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 카테고리 배지와 상세보기
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getCategoryDisplayName(space.category),
                                style: const TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                            // 상세보기
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  LocaleKeys.view_details.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[500],
                                  size: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 매장명
                        Text(
                          space.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard',
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // 운영 상태
                        _buildBusinessHoursStatus(space),
                        // 혜택 정보가 있을 때만 구분선과 혜택 표시
                        if (space.benefitDescription.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          // 구분선
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/ico_infobenefit.png',
                                width: 12,
                                height: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                LocaleKeys.benefit.tr(),
                                style: const TextStyle(
                                  color: Color(0xFF00A3FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 2,
                                height: 2,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  space.benefitDescription,
                                  style: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 12,
                                    fontFamily: 'Pretendard',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (showAnimation) {
      return AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 300),
        child: widget,
      );
    }
    return widget;
  }

  // 영업시간 상태 위젯 생성
  Widget _buildBusinessHoursStatus(SpaceEntity space) {
    // 임시 휴무 체크
    if (space.isTemporarilyClosed) {
      return Text(
        LocaleKeys.temporarily_closed.tr(),
        style: TextStyle(
          color: Colors.red[300],
          fontSize: 14,
          fontFamily: 'Pretendard',
        ),
      );
    }

    // 영업시간 데이터가 없는 경우
    if (space.businessHours.isEmpty) {
      return Text(
        LocaleKeys.business_hours_info_not_available.tr(),
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontFamily: 'Pretendard',
        ),
      );
    }

    // 현재 영업 상태 확인
    final isOpen = space.isCurrentlyOpen;
    final now = DateTime.now();
    final currentDay = _getDayOfWeekFromDateTime(now);
    
    // 오늘의 영업시간 찾기
    final todayHours = space.businessHours.firstWhere(
      (hours) => hours.dayOfWeek == currentDay,
      orElse: () => BusinessHoursEntity(
        dayOfWeek: currentDay,
        isClosed: true,
      ),
    );

    if (isOpen) {
      // 영업 중 - 마감 시간 표시
      if (todayHours.closeTime != null) {
        // 휴게시간 체크
        if (todayHours.breakStartTime != null && todayHours.breakEndTime != null) {
          final breakStartParts = todayHours.breakStartTime!.split(':');
          final breakEndParts = todayHours.breakEndTime!.split(':');
          final currentMinutes = now.hour * 60 + now.minute;
          final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
          final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);
          
          // 휴게시간 30분 전
          if (currentMinutes >= breakStartMinutes - 30 && currentMinutes < breakStartMinutes) {
            return Row(
              children: [
                Text(
                  LocaleKeys.business_open.tr(),
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                ),
                Text(
                  ' • ${todayHours.breakStartTime} ${LocaleKeys.break_time.tr()}',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            );
          }
        }
        
        return Row(
          children: [
            Text(
              LocaleKeys.business_open.tr(),
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            ),
            Text(
              ' • ${todayHours.closeTime} ${LocaleKeys.closes_at.tr()}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        );
      } else {
        return Text(
          LocaleKeys.business_open.tr(),
          style: TextStyle(
            color: Colors.green[400],
            fontSize: 14,
            fontFamily: 'Pretendard',
          ),
        );
      }
    } else {
      // 영업 종료 - 다음 영업 시간 표시
      final nextOpenTime = space.nextOpeningTime;
      
      // 오늘 휴무인지 확인
      if (todayHours.isClosed) {
        if (nextOpenTime != null) {
          return Text(
            '${LocaleKeys.closed_day.tr()} • 다음 영업 시작',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          );
        } else {
          return Text(
            LocaleKeys.closed_day.tr(),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Pretendard',
            ),
          );
        }
      }
      
      // 영업 종료
      if (nextOpenTime != null && todayHours.openTime != null) {
        // 오늘 아직 열기 전인지 확인
        final openParts = todayHours.openTime!.split(':');
        final openHour = int.parse(openParts[0]);
        final openMinute = int.parse(openParts[1]);
        final currentMinutes = now.hour * 60 + now.minute;
        final openMinutes = openHour * 60 + openMinute;
        
        if (currentMinutes < openMinutes) {
          return Row(
            children: [
              Text(
                LocaleKeys.business_before_open.tr(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
              Text(
                ' • ${todayHours.openTime} ${LocaleKeys.opens_at.tr()}',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          );
        }
      }
      
      // 휴게시간 중인지 확인
      if (todayHours.breakStartTime != null && todayHours.breakEndTime != null && !todayHours.isClosed) {
        final breakStartParts = todayHours.breakStartTime!.split(':');
        final breakEndParts = todayHours.breakEndTime!.split(':');
        final currentMinutes = now.hour * 60 + now.minute;
        final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);
        
        if (currentMinutes >= breakStartMinutes && currentMinutes < breakEndMinutes) {
          return Row(
            children: [
              Text(
                LocaleKeys.break_time.tr(),
                style: TextStyle(
                  color: Colors.orange[300],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
              Text(
                ' • ${todayHours.breakEndTime} 까지',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          );
        }
      }
      
      return Text(
        LocaleKeys.business_end.tr(),
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontFamily: 'Pretendard',
        ),
      );
    }
  }

  // 카테고리 표시 이름 변환
  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'CAFE':
        return LocaleKeys.category_cafe.tr();
      case 'MEAL':
        return LocaleKeys.category_restaurant.tr();
      case 'PUB':
        return LocaleKeys.category_pub.tr();
      case 'MUSIC':
        return LocaleKeys.category_music.tr();
      case 'BAR':
        return LocaleKeys.category_bar.tr();
      default:
        return category;
    }
  }

  // DateTime에서 DayOfWeek로 변환하는 헬퍼 메서드
  DayOfWeek _getDayOfWeekFromDateTime(DateTime dateTime) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    switch (dateTime.weekday) {
      case 1:
        return DayOfWeek.MONDAY;
      case 2:
        return DayOfWeek.TUESDAY;
      case 3:
        return DayOfWeek.WEDNESDAY;
      case 4:
        return DayOfWeek.THURSDAY;
      case 5:
        return DayOfWeek.FRIDAY;
      case 6:
        return DayOfWeek.SATURDAY;
      case 7:
        return DayOfWeek.SUNDAY;
      default:
        return DayOfWeek.MONDAY;
    }
  }
}