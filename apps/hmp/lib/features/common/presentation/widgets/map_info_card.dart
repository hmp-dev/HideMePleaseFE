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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF132E41), width: 1)
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 매장 이미지
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                _getCategoryIcon(space.category),
                                width: 14,
                                height: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getCategoryDisplayName(space.category),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'LINESeedKR',
                                ),
                              ),
                            ],
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
                                fontFamily: 'LINESeedKR',
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
                      context.locale.languageCode == 'en' && space.nameEn.isNotEmpty
                        ? space.nameEn
                        : space.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'LINESeedKR',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 운영 상태
                    _buildBusinessHoursStatus(space),
                    // 혜택 정보가 있을 때만 구분선과 혜택 표시
                    if (_getBenefitDescription(context, space).isNotEmpty) ...[
                      const SizedBox(height: 10),
                      // 구분선
                      Container(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/ico_infobenefit2.png',
                            width: 12,
                            height: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            LocaleKeys.benefit.tr(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'LINESeedKR',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 2,
                            height: 2,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getBenefitDescription(context, space),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontFamily: 'LINESeedKR',
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
          fontSize: 10,
          fontFamily: 'LINESeedKR',
        ),
      );
    }

    // 영업시간 데이터가 없는 경우
    if (space.businessHours.isEmpty) {
      return Text(
        LocaleKeys.business_hours_info_not_available.tr(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontFamily: 'LINESeedKR',
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
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'LINESeedKR',
                  ),
                ),
                Text(
                  ' • ${todayHours.breakStartTime} ${LocaleKeys.break_time.tr()}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'LINESeedKR',
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
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'LINESeedKR',
              ),
            ),
            Text(
              ' • ${todayHours.closeTime} ${LocaleKeys.closes_at.tr()}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontFamily: 'LINESeedKR',
              ),
            ),
          ],
        );
      } else {
        return Text(
          LocaleKeys.business_open.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontFamily: 'LINESeedKR',
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
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'LINESeedKR',
            ),
          );
        } else {
          return Text(
            LocaleKeys.closed_day.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'LINESeedKR',
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
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'LINESeedKR',
                ),
              ),
              Text(
                ' • ${todayHours.openTime} ${LocaleKeys.opens_at.tr()}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'LINESeedKR',
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
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'LINESeedKR',
                ),
              ),
              Text(
                ' • ${todayHours.breakEndTime} 까지',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'LINESeedKR',
                ),
              ),
            ],
          );
        }
      }
      
      return Text(
        LocaleKeys.business_end.tr(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontFamily: 'LINESeedKR',
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
      case 'BAKERY':
        return LocaleKeys.bakery.tr();
      default:
        return category;
    }
  }

  // 카테고리 아이콘 경로 반환
  String _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'CAFE':
        return 'assets/icons/icon_label_cafe.png';
      case 'MEAL':
        return 'assets/icons/icon_label_food.png';
      case 'PUB':
        return 'assets/icons/icon_label_cocktail.png';
      case 'MUSIC':
        return 'assets/icons/icon_cate_guitar.png';
      case 'BAR':
        return 'assets/icons/icon_label_cocktail.png';
      case 'BAKERY':
        return 'assets/icons/icon_label_bakery.png';
      default:
        return 'assets/icons/icon_label_etc.png';
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

  // 언어에 따른 혜택 설명 반환
  String _getBenefitDescription(BuildContext context, SpaceEntity space) {
    final isEnglish = context.locale.languageCode == 'en';

    // 영어 모드이고 영문 설명이 있으면 영문 반환
    if (isEnglish && space.benefitDescriptionEn.isNotEmpty) {
      return space.benefitDescriptionEn;
    }

    // 그 외의 경우 기본 설명 반환
    return space.benefitDescription;
  }
}