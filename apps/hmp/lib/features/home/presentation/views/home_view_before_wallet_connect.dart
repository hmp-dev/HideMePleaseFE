import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/error_codes.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/home/presentation/widgets/free_welcome_nft_card.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// [HomeViewBeforeWalletConnect] is a stateless widget that displays
/// the home view before the wallet is connected.
///
/// It listens to the [WalletsCubit] state and shows an error snackbar
/// if there is an error in connecting the wallet. It also listens to the
/// [NftCubit] state and shows the welcome NFT card if it is available.
class HomeViewBeforeWalletConnect extends StatelessWidget {
  /// Creates a [HomeViewBeforeWalletConnect].
  ///
  /// The [onConnectWallet] callback is called when the user taps the
  /// connect wallet button.
  const HomeViewBeforeWalletConnect({
    super.key,
    required this.onConnectWallet,
  });

  /// The callback function that is called when the user taps the connect
  /// wallet button.
  final VoidCallback onConnectWallet;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletsCubit, WalletsState>(
      // Listen to the wallets cubit state
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
      child: BlocConsumer<NftCubit, NftState>(
        // Listen to the NFT cubit state
        bloc: getIt<NftCubit>(),
        listener: (context, nftState) {},
        builder: (context, nftState) {
          return Column(
            children: [
              const SizedBox(height: 50),
              // Display the logo image
              DefaultImage(
                path: "assets/images/hide-me-please-logo.png",
                width: 200,
              ),
              const SizedBox(height: 20),
              Center(
                // Display the welcome message
                child: Text(
                  "지갑을 연결하고\n웹컴 NFT를 받아보세요!",
                  textAlign: TextAlign.center,
                  style: fontR(18, lineHeight: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              // Display the connect wallet button
              ElevatedButton(
                style: _elevatedButtonStyle(),
                onPressed: onConnectWallet,
                child: Text(
                  LocaleKeys.walletConnection.tr(),
                  style: fontCompactMdMedium(color: white),
                ),
              ),
              const SizedBox(height: 5),
              // Display the welcome NFT card if it is available
              FreeWelcomeNftCard(
                welcomeNftEntity: nftState.welcomeNftEntity,
              )
            ],
          );
        },
      ),
    );
  }

  /// Returns the style for the elevated button.
  ButtonStyle _elevatedButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(bgNega4),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
    );
  }
}
