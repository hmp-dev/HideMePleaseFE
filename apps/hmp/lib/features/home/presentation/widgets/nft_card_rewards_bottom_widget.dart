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
import 'dart:async';

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
  bool _isHandlingClaim = false;

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
                if (!widget.isProcessing && !_isHandlingClaim) {
                  unawaited(_handleNftClaim(context, snackBarService));
                }
              },
              child: (widget.isProcessing || _isHandlingClaim) 
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
                        LocaleKeys.nft_processing.tr(),
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

  // 비동기 NFT 클레임 처리
  Future<void> _handleNftClaim(BuildContext context, SnackbarService snackBarService) async {
    if (_isHandlingClaim) {
      snackBarService.showSnackbar(
        message: LocaleKeys.nft_already_processing.tr(),
        duration: const Duration(seconds: 2),
      );
      return; // 이미 처리 중이면 리턴
    }
    
    setState(() {
      _isHandlingClaim = true;
    });
    
    try {
      "welcomeNftEntity.remainingCount ${widget.welcomeNftEntity.remainingCount}".log();
    
    // Wepin 로그인 상태 확인 및 처리
    final wepinCubit = getIt<WepinCubit>();
    final currentStatus = wepinCubit.state.wepinLifeCycleStatus;
    
    if (currentStatus != WepinLifeCycle.login) {
      try {
        // 초기화되지 않은 경우 초기화 먼저 수행
        if (currentStatus == WepinLifeCycle.notInitialized) {
          "Wepin SDK 초기화 시작".log();
          await wepinCubit.initializeWepinSDK(
            selectedLanguageCode: context.locale.languageCode
          );
          
          // 초기화 완료까지 대기
          await Future.delayed(const Duration(milliseconds: 1500));
        }
        
        // 로그인 시도
        "Wepin 지갑 연결 시작".log();
        await wepinCubit.onConnectWepinWallet(
          context, 
          isFromWePinWalletConnect: true, 
          isFromWePinWelcomeNftRedeem: true, 
          isOpenWepinModel: true
        );
        
        // 로그인 상태 재확인
        final newStatus = wepinCubit.state.wepinLifeCycleStatus;
        if (newStatus == WepinLifeCycle.login) {
          "Wepin 로그인 성공, NFT 클레임 진행".log();
          _proceedWithNftClaim(snackBarService);
        } else if (newStatus == WepinLifeCycle.loginBeforeRegister) {
          "Wepin 등록 필요".log();
          snackBarService.showSnackbar(
            message: LocaleKeys.nft_wallet_registration_required.tr(),
            duration: const Duration(seconds: 3),
          );
        } else {
          "Wepin 로그인 실패".log();
          snackBarService.showSnackbar(
            message: LocaleKeys.nft_wallet_connection_failed.tr(),
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        "Wepin 연결 오류: $e".log();
        snackBarService.showSnackbar(
          message: LocaleKeys.nft_wallet_connection_error.tr(),
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      // 이미 로그인된 상태면 바로 NFT 클레임 진행
      "이미 Wepin 로그인됨, NFT 클레임 진행".log();
      _proceedWithNftClaim(snackBarService);
    }
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingClaim = false;
        });
      }
    }
  }

  // NFT 클레임 로직을 별도 메서드로 분리
  void _proceedWithNftClaim(SnackbarService snackBarService) {
    if (widget.welcomeNftEntity.freeNftAvailable && widget.welcomeNftEntity.remainingCount > 0) {
      // WelcomeNft is no longer used - commented out to prevent requests
      // getIt<NftCubit>().onGetConsumeWelcomeNft();
    } else {
      snackBarService.showSnackbar(
        message: LocaleKeys.youCanNotUseTheFreeNft.tr(),
        duration: const Duration(seconds: 5),
      );
    }
  }
}
