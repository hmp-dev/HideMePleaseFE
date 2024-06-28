import 'dart:io';

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
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NftCardRewardsBottomWidget extends StatelessWidget {
  NftCardRewardsBottomWidget({
    super.key,
    required this.welcomeNftEntity,
  });

  final WelcomeNftEntity welcomeNftEntity;

  final SnackbarService snackBarService = getIt<SnackbarService>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listenWhen: (previous, current) =>
          previous.consumeWelcomeNftUrl != current.consumeWelcomeNftUrl,
      listener: (context, state) {
        if (state.consumeWelcomeNftUrl.isNotEmpty) {
          //klipwallet://wc?uri=wc%3A62eb85e29589e38710517c3391d12e9f21875ea495c5eb9b5badd4f56c0d755e%402%3Frelay-protocol%3Dirn%26symKey%3Dc3a3426d4c3ad540e8401b726eaee27f56c0e1fbcc4cee50e62367e3366d5651%26methods%3D%255Bwc_sessionPropose%252Cwc_sessionRequest%255D%252C%255Bwc_authRequest%255D

          try {
            _launchUrl(state.consumeWelcomeNftUrl);
          } on Exception catch (e) {
            "Could not launch ${state.consumeWelcomeNftUrl}: $e".log();
          }
        }

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
                  LocaleKeys.firstComeFirstServed.tr(),
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
            const VerticalSpace(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.floorPrice.tr(),
                  style: fontCompactMd(),
                ),
                Text(
                  LocaleKeys.free.tr(),
                  style: fontCompactLgBold(),
                )
              ],
            ),
            const VerticalSpace(10),
            if (!getIt<WalletsCubit>().state.isKlipWalletConnected) ...[
              GlassmorphicButton(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 60,
                onPressed: () {
                  if (Platform.isAndroid) {
                    launchUrlString(
                        'https://play.google.com/store/apps/details?id=com.klipwallet.app');
                  } else {
                    launchUrlString('https://apps.apple.com/app/id1627665524');
                  }
                },
                child: Text(
                  'Klip 설치',
                  style: fontCompactLgMedium(),
                ),
              ),
              const VerticalSpace(20),
              GlassmorphicButton(
                width: MediaQuery.of(context).size.width * 0.80,
                height: 60,
                onPressed: () {
                  getIt<WalletsCubit>().state.w3mService?.openModal(context);
                },
                child: Text(
                  'Klip 연동',
                  style: fontCompactLgMedium(),
                ),
              ),
              const VerticalSpace(20),
            ],
            GlassmorphicButton(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 60,
              onPressed: () {
                if (!getIt<WalletsCubit>().state.isKlipWalletConnected) {
                  return snackBarService.showSnackbar(
                    message: "클립월렛에 접속해주세요",
                    duration: const Duration(seconds: 5),
                  );
                }

                if (welcomeNftEntity.remainingCount > 0) {
                  getIt<NftCubit>().onGetConsumeWelcomeNft();
                } else {
                  snackBarService.showSnackbar(
                    message: "무료 NFT를 사용할 수 없습니다",
                    duration: const Duration(seconds: 5),
                  );
                }
              },
              child: Text(
                LocaleKeys.getNftForFree.tr(),
                style: fontCompactLgMedium(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlToOpen) async {
    if (!await launchUrl(Uri.parse(urlToOpen))) {
      throw Exception('Could not launch $urlToOpen');
    }
  }
}
