import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_usage_history_entity.dart';

class PointsUsageDetailItem extends StatelessWidget {
  const PointsUsageDetailItem({
    super.key,
    required this.item,
  });

  final UsageHistoryItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Text(
            formatDateGetMonthYear(item.createdAt),
            style: fontCompactSm(color: fore3),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.spaceName,
              style: fontCompactLgMedium(),
            ),
            Text(
              item.benefitDescription,
              style: fontCompactSm(color: fore3),
            ),
          ],
        ),
        const Spacer(),
        Text(
          "+${item.pointsEarned}P",
          style: fontCompactMdMedium(color: hmpBlue),
        ),
      ],
    );
  }
}
