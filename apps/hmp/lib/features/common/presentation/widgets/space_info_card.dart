import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/screens/space_detail_screen.dart';

class SpaceInfoCard extends StatelessWidget {
  final SpaceEntity space;
  final bool showDetailButton;
  final VoidCallback? onTap;

  const SpaceInfoCard({
    Key? key,
    required this.space,
    this.showDetailButton = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () async {
        final spaceCubit = getIt<SpaceCubit>();
        await spaceCubit.onGetSpaceDetailBySpaceId(spaceId: space.id);
        SpaceDetailScreen.push(context);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0E).withOpacity(0.5),
          border: Border.all(color: const Color(0xFF19BAFF), width: 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (space.category != null && space.category!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF19BAFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  space.category!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (showDetailButton)
                              GestureDetector(
                                onTap: () async {
                                  final spaceCubit = getIt<SpaceCubit>();
                                  await spaceCubit.onGetSpaceDetailBySpaceId(spaceId: space.id);
                                  SpaceDetailScreen.push(context);
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      '상세보기',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          space.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${space.latitude.toStringAsFixed(4)}, ${space.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (_getBenefitDescription(context, space).isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                size: 14,
                                color: Color(0xFF19BAFF),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _getBenefitDescription(context, space),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF19BAFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
  }
}

// Helper function to get benefit description based on language
String _getBenefitDescription(BuildContext context, SpaceEntity space) {
  final isEnglish = context.locale.languageCode == 'en';

  // 영어 모드이고 영문 설명이 있으면 영문 반환
  if (isEnglish && space.benefitDescriptionEn.isNotEmpty) {
    return space.benefitDescriptionEn;
  }

  // 그 외의 경우 기본 설명 반환
  return space.benefitDescription;
}