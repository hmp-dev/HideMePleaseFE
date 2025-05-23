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

class NftCardRewardsBottomWidget extends StatefulWidget {
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
  State<NftCardRewardsBottomWidget> createState() => _NftCardRewardsBottomWidgetState();
}

class _NftCardRewardsBottomWidgetState extends State<NftCardRewardsBottomWidget> {
  bool _localProcessing = false;

  @override
  void initState() {
    super.initState();
    _localProcessing = widget.isProcessing;
  }

  Future<void> _handleNftClaim() async {
    if (_localProcessing) return;

    try {
      setState(() => _localProcessing = true);
      "NFT Claim Button Pressed - Starting process".log();

      final wepinCubit = getIt<WepinCubit>();
      final currentStatus = wepinCubit.state.wepinLifeCycleStatus;
      
      "NFT Claim - Current Wepin status: $currentStatus".log();

      if (currentStatus != WepinLifeCycle.login) {
        if (currentStatus == WepinLifeCycle.notInitialized) {
          "NFT Claim - Initializing Wepin SDK".log();
          await wepinCubit.initializeWepinSDK(
              selectedLanguageCode: context.locale.languageCode);
          "NFT Claim - Wepin SDK initialized".log();
          
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        "NFT Claim - Connecting Wepin wallet".log();
        await wepinCubit.onConnectWepinWallet(
          context,
          isFromWePinWalletConnect: true,
          isFromWePinWelcomeNftRedeem: true,
          isOpenWepinModel: true
        );

        final finalStatus = wepinCubit.state.wepinLifeCycleStatus;
        "NFT Claim - Final Wepin status after connection: $finalStatus".log();

        if (finalStatus == WepinLifeCycle.loginBeforeRegister) {
          "NFT Claim - User in loginBeforeRegister state, stopping process".log();
          return;
        }
      }

      if (!widget.welcomeNftEntity.freeNftAvailable || 
          widget.welcomeNftEntity.remainingCount <= 0) {
        "NFT Claim - NFT not available or no remaining count".log();
        getIt<SnackbarService>().showSnackbar(
          message: LocaleKeys.youCanNotUseTheFreeNft.tr(),
          duration: const Duration(seconds: 5),
        );
        return;
      }

      "NFT Claim - Proceeding with NFT consumption".log();
      await getIt<NftCubit>().onGetConsumeWelcomeNft();
      "NFT Claim - NFT consumption completed".log();

    } catch (e) {
      "NFT Claim - Error during process: $e".log();
    } finally {
      if (mounted) {
        setState(() => _localProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listenWhen: (previous, current) =>
          previous.consumeWelcomeNftUrl != current.consumeWelcomeNftUrl,
      listener: (context, state) {
        if (state.isSubmitFailure) {
          getIt<SnackbarService>().showSnackbar(
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
                      widget.welcomeNftEntity.redeemedNfts,
                      style: fontCompactLgBold(),
                    ),
                    Text('/${widget.welcomeNftEntity.totalNfts}',
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
              onPressed: () {
                if (!_localProcessing) {
                  _handleNftClaim();
                }
              },
              child: _localProcessing
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
