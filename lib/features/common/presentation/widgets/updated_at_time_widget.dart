import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';

class UpdateAtTimeWidget extends StatelessWidget {
  const UpdateAtTimeWidget({
    super.key,
    required this.updatedAt,
  });

  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "${formatDate(updatedAt)} 기준",
          style: fontCompactSm(color: fore3),
        ),
        const HorizontalSpace(3),
        DefaultImage(
          path: "assets/icons/ic_arrow_clockwise.svg",
          color: white,
          height: 16,
        )
      ],
    );
  }
}
