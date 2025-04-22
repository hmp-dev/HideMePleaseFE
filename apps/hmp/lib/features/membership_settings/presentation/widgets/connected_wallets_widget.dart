// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/common/presentation/widgets/wepin_icon_widget.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/plus_icon_round_button.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class ConnectedWalletsWidget extends StatelessWidget {
  const ConnectedWalletsWidget({
    super.key,
  });

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
                height: 64,
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
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: state.connectedWallets.length,
                          itemBuilder: (context, index) {
                            if (state.connectedWallets[index].provider ==
                                    'WEPIN_EVM' ||
                                state.connectedWallets[index].provider ==
                                    'WEPIN_SOLANA') {
                              return const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: WepinIconWidget(),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CustomImageView(
                                svgPath:
                                    "assets/wallet-logos/${state.connectedWallets[index].provider.toLowerCase()}_wallet.svg",
                                width: 28,
                                height: 28,
                              ),
                            );
                          },
                        ),
                      ),

                      //
                      // tapping on this connect

                      PlusIconRoundButton(
                        onTap: () async {
                          try {
                            //if (!mounted) return;
                            
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            
                            //if (!mounted) return;
                            
                            final walletsCubit = getIt<WalletsCubit>();
                            if (walletsCubit != null) {
                              //await walletsCubit.initReownAppKitSdk();
                              await walletsCubit.onOpenReownAppKitBottomModal(
                                context: context,
                                isFromWePinWalletConnect: true,
                              );
                            }
                          } catch (e) {
                            debugPrint('Error opening wallet modal: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "지갑 연결 중 오류가 발생했습니다.",
                                ),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              const VerticalSpace(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.nftSelection.tr(),
                    //"대표 NFT 선택",
                    style: fontTitle07Medium(),
                  ),
                  // create separate widget for this

                  //UpdateAtTimeWidget(updatedAt: "state.collectionFetchTime"),
                ],
              ),
              const VerticalSpace(10),
            ],
          ),
        );
      },
    );
  }
}
