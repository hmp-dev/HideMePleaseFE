import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';

class CollectionTitleWidget extends StatelessWidget {
  final String title;
  final String chainSymbol;

  const CollectionTitleWidget({
    super.key,
    required this.title,
    required this.chainSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          DefaultImage(
            path: ChainType.fromString(chainSymbol).chainLogo,
            width: 30,
            height: 30,
          ),
          const HorizontalSpace(10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: fontTitle06Medium(),
            ),
          )
        ],
      ),
    );
  }
}
