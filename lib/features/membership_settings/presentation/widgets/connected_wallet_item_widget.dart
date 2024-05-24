import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';

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
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.only(bottom: 20),
                height: 68,
                decoration: BoxDecoration(
                  color: bgNega5,
                  borderRadius: BorderRadius.circular(10),
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
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CustomImageView(
                                    svgPath:
                                        "assets/wallet-logos/${connectedWallet.provider.toLowerCase()}_wallet.svg",
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                                Text(
                                  connectedWallet.provider,
                                  style: fontTitle06(),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, bottom: 5),
                              child: Text(
                                formatWalletAddress(
                                    connectedWallet.publicAddress),
                                style: fontBody2Medium(color: fore2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //
                      // tapping on this connect

                      IconButton.outlined(
                        onPressed: () {
                          // getIt<WalletsCubit>().onDeleteConnectedWallet(
                          //     walletId: connectedWallet.id);
                        },
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
