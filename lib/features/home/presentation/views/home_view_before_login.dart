import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class HomeViewBeforeLogin extends StatefulWidget {
  const HomeViewBeforeLogin({
    super.key,
    required this.w3mService,
  });

  final W3MService w3mService;

  @override
  State<HomeViewBeforeLogin> createState() => _HomeViewBeforeLoginState();
}

class _HomeViewBeforeLoginState extends State<HomeViewBeforeLogin> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        GestureDetector(
          onTap: () {
            getIt<NftCubit>().onGetNftCollections();
            MyMembershipSettingsScreen.push(context);
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
        W3MConnectWalletButton(service: widget.w3mService),
        // if (widget.w3mService.session?.address != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 20.0),
        //     child: Column(
        //       children: [
        //         ListTile(
        //           dense: true,
        //           title: Text('${widget.w3mService.session?.address}'),
        //           subtitle: const Text("Connected Wallet address"),
        //         ),
        //         ListTile(
        //           dense: true,
        //           title:
        //               Text('${widget.w3mService.session?.connectedWalletName}'),
        //           subtitle: const Text("Connected Wallet Name"),
        //         ),
        //       ],
        //     ),
        //   ),
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
