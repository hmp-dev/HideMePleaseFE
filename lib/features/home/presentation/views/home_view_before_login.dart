import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class HomeViewBeforeLogin extends StatelessWidget {
  const HomeViewBeforeLogin({
    super.key,
    required this.w3mService,
  });

  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        GestureDetector(
          onTap: () {
            getIt<HomeCubit>()
                .onUpdateHomeViewType(HomeViewType.AfterLoginWithOutNFT);
          },
          child: DefaultImage(
            path: "assets/images/hide-me-please-logo.png",
            width: 200,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "지갑을 연결하고\n웹컴 NFT를 받아보세요!",
            textAlign: TextAlign.center,
            style: fontR(18, lineHeight: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        W3MConnectWalletButton(service: w3mService),
        const SizedBox(height: 20),
        if (w3mService.session?.address != null)
          Column(
            children: [
              ListTile(
                dense: true,
                title: Text('${w3mService.session?.address}'),
                subtitle: const Text("Connected Wallet address"),
              ),
              ListTile(
                dense: true,
                title: Text('${w3mService.session?.connectedWalletName}'),
                subtitle: const Text("Connected Wallet Name"),
              ),
            ],
          ),
        const SizedBox(height: 50),
        const NFTCardWidgetParent(
          imagePath: "assets/images/home_card_img.png",
          topWidget: NftCardTopWidget(),
          bottomWidget: NftCardTopWidget(),
        )
      ],
    );
  }
}
