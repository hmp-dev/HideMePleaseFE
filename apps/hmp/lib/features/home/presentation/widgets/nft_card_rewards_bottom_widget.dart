// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/glassmorphic_button.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class NftCardRewardsBottomWidget extends StatelessWidget {
  const NftCardRewardsBottomWidget({
    super.key,
    required this.welcomeNftEntity,
    required this.onTapClaimButton,
    this.isProcessing = false,
  });

  final WelcomeNftEntity welcomeNftEntity;
  final VoidCallback onTapClaimButton;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final snackBarService = getIt<SnackbarService>();
    final connectedWallets = getIt<WalletsCubit>().state.connectedWallets;

    return BlocListener<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listenWhen: (previous, current) =>
          previous.consumeWelcomeNftUrl != current.consumeWelcomeNftUrl,
      listener: (context, state) {
        if (state.isSubmitFailure) {
          snackBarService.showSnackbar(
            message: state.errorMessage,
            duration: const Duration(seconds: 5),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.numberOfMembers.tr(),
                  style: fontCompactMd(),
                ),
                Row(
                  children: [
                    Text(
                      welcomeNftEntity.redeemedNfts,
                      style: fontCompactLgBold(),
                    ),
                    Text('/${welcomeNftEntity.totalNfts}',
                        style: fontCompactLg())
                  ],
                )
              ],
            ),

            /// Floor Price value row made hidden as per Jayden advice
            // const VerticalSpace(10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       LocaleKeys.floorPrice.tr(),
            //       style: fontCompactMd(),
            //     ),
            //     Text(
            //       LocaleKeys.free.tr(),
            //       style: fontCompactLgBold(),
            //     )
            //   ],
            // ),
            const VerticalSpace(15),
            // if (!getIt<WalletsCubit>().state.isKlipWalletConnected) ...[
            //   GlassmorphicButton(
            //     width: MediaQuery.of(context).size.width * 0.80,
            //     height: 60,
            //     onPressed: () async {
            //       if (Platform.isAndroid) {
            //         launchUrlString(
            //             'https://play.google.com/store/apps/details?id=com.klipwallet.app');
            //       } else {
            //         launchUrlString('https://apps.apple.com/app/id1627665524');
            //       }
            //     },
            //     child: Text(
            //       'Klip 설치',
            //       style: fontCompactLgMedium(),
            //     ),
            //   ),
            //   const VerticalSpace(12),
            //   GlassmorphicButton(
            //     width: MediaQuery.of(context).size.width * 0.80,
            //     height: 60,
            //     onPressed: () {
            //       getIt<WalletsCubit>().onConnectWallet(context);
            //     },
            //     child: Text(
            //       'Klip 연동',
            //       style: fontCompactLgMedium(),
            //     ),
            //   ),
            //   const VerticalSpace(12),
            // ],
            GlassmorphicButton(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 60,
              onPressed: isProcessing ? () {} : () {
                // if (!getIt<WalletsCubit>().state.isKlipWalletConnected) {
                //   return snackBarService.showSnackbar(
                //     message: "Klip월렛에 연동해주세요.",
                //     duration: const Duration(seconds: 5),
                //   );
                // }

                "welcomeNftEntity.remainingCount ${welcomeNftEntity.remainingCount}"
                    .log();
                if(getIt<WepinCubit>().state.wepinLifeCycleStatus != WepinLifeCycle.login){
                  if(getIt<WepinCubit>().state.wepinLifeCycleStatus == WepinLifeCycle.notInitialized) {
                    getIt<WepinCubit>().initializeWepinSDK(
                        selectedLanguageCode: context.locale.languageCode);
                    Future.delayed(const Duration(milliseconds: 1000));
                    getIt<WepinCubit>().onConnectWepinWallet(context, isFromWePinWalletConnect: true, isFromWePinWelcomeNftRedeem:true, isOpenWepinModel:true);
                  }else{
                    getIt<WepinCubit>().onConnectWepinWallet(context, isFromWePinWalletConnect: true, isFromWePinWelcomeNftRedeem:true, isOpenWepinModel:true);
                  }
                  if(getIt<WepinCubit>().state.wepinLifeCycleStatus == WepinLifeCycle.loginBeforeRegister){

                  }
                  //getIt<WepinCubit>().onResetWepinSDKFetchedWallets();
                }else {
                  if (welcomeNftEntity.freeNftAvailable &&
                      welcomeNftEntity.remainingCount > 0) {
                    getIt<NftCubit>().onGetConsumeWelcomeNft();
                  } else {
                    snackBarService.showSnackbar(
                      message: LocaleKeys.youCanNotUseTheFreeNft
                          .tr(), //"무료 NFT를 사용할 수 없습니다",
                      duration: const Duration(seconds: 5),
                    );
                  }
                }
              },
              child: isProcessing 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      ),
                      SizedBox(width: 10),
                      Text(
                        "처리 중...",
                        style: fontCompactLgMedium(),
                      ),
                    ],
                  )
                : Text(
                    LocaleKeys.getNftForFree.tr(),
                    style: fontCompactLgMedium(),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
