import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NftCardTopWidget extends StatelessWidget {
  const NftCardTopWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultImage(
            path: "assets/icons/ethereum_chain_icon.svg",
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 10),
          Text(
            "Ready To Hide",
            style: fontB(32),
          ),
        ],
      ),
    );
  }
}
