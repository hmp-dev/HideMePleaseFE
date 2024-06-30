import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class ConnectedWalletItemWidget extends StatelessWidget {
  const ConnectedWalletItemWidget({
    super.key,
    required this.connectedWallet,
  });

  final ConnectedWalletEntity connectedWallet;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletsCubit, WalletsState>(
      bloc: getIt<WalletsCubit>(),
      listener: (context, state) {
        if (state.submitStatus == RequestStatus.failure) {
          // Show Error Snackbar If Error in Redeeming Benefit
          context.showErrorSnackBar(state.errorMessage);
        }
      },
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
          height: 68,
          decoration: BoxDecoration(
            color: scaffoldBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: bgNega5,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (connectedWallet.provider == "PHANTOM")
                              ? Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: bgNega5,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: fore2.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: CustomImageView(
                                      imagePath:
                                          "assets/web3-wallet-logos/${connectedWallet.provider.toLowerCase()}_wallet.png",
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                )
                              : CustomImageView(
                                  imagePath:
                                      "assets/web3-wallet-logos/${connectedWallet.provider.toLowerCase()}_wallet.png",
                                  width: 42,
                                  height: 42,
                                  radius: BorderRadius.circular(12),
                                ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                connectedWallet.provider,
                                style: fontBodyMdMedium(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Text(
                                  formatWalletAddress(
                                      connectedWallet.publicAddress),
                                  style: fontCompactXs(color: fore3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    getIt<WalletsCubit>()
                        .onDeleteConnectedWallet(walletId: connectedWallet.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: fore2,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      LocaleKeys.disconnect.tr(),
                      style: fontCompactSm(),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
