import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

class WepinIconWidget extends StatelessWidget {
  const WepinIconWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomImageView(
      imagePath: "assets/web3-wallet-logos/wepin_wallet.png",
      width: 28,
      height: 28,
      fit: BoxFit.contain,
    );
  }
}
