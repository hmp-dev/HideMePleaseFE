import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NftCardTopTitleWidget extends StatelessWidget {
  const NftCardTopTitleWidget({
    super.key,
    required this.title,
    required this.chain,
  });

  final String title;
  final String chain;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultImage(
            path: ChainType.fromString(chain).chainLogo,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: fontTitle01Bold(),
          ),
        ],
      ),
    );
  }
}
