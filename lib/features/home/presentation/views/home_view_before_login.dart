import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/enum/error_codes.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/home/presentation/widgets/glassmorphic_button.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent_local.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class HomeViewBeforeLogin extends StatefulWidget {
  const HomeViewBeforeLogin({
    super.key,
  });

  @override
  State<HomeViewBeforeLogin> createState() => _HomeViewBeforeLoginState();
}

class _HomeViewBeforeLoginState extends State<HomeViewBeforeLogin> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletsCubit, WalletsState>(
      bloc: getIt<WalletsCubit>(),
      listener: (context, state) {
        if (state.submitStatus == RequestStatus.failure) {
          // Map the error message to the appropriate enum message
          String errorMessage = getErrorMessage(state.errorMessage);

          // Show Error Snackbar If Wallet is Already Connected
          context.showErrorSnackBarDismissible(errorMessage);

          "inside listener++++++ error message is $errorMessage".log();
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 50),
          DefaultImage(
            path: "assets/images/hide-me-please-logo.png",
            width: 200,
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
          BlocConsumer<WalletsCubit, WalletsState>(
            bloc: getIt<WalletsCubit>(),
            listener: (context, state) {},
            builder: (context, state) {
              // check if the w3mService is initialized
              if (state.w3mService != null) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(bgNega4),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    )),
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  onPressed: () {
                    state.w3mService!.openModal(context);
                  },
                  child: Text(
                    LocaleKeys.walletConnection.tr(),
                    style: fontCompactMdMedium(color: white),
                  ),
                );

                // W3MConnectWalletButton(
                //   service: state.w3mService!,
                // );
              } else {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(bgNega4),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    )),
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  onPressed: () {},
                  child: Text(
                    LocaleKeys.walletConnection.tr(),
                    style: fontCompactMdMedium(color: white),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 30),
          NFTCardWidgetParentLocal(
            imagePath: "assets/images/home_card_img.png",
            topWidget: const NftCardTopTitleWidget(
              title: "Ready To Hide",
              chain: "ETHEREUM",
            ),
            badgeWidget: CustomImageView(
              imagePath: "assets/images/free-graphic-text.png",
            ),
            bottomWidget: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
              child: GlassmorphicButton(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 60,
                onPressed: () {},
                child: Text(
                  'Klip 연결하고 무료 NFT 받기',
                  style: fontCompactMdMedium(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
