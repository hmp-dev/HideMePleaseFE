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
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

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

        if (state.isFailure) {
          snackBarService.showSnackbar(
            message: state.errorMessage,
            duration: const Duration(seconds: 2),
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
                      "${welcomeNftEntity.usedCount}",
                      style: fontCompactLgBold(),
                    ),
                    Text('/${welcomeNftEntity.totalCount}',
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
            GlassmorphicButton(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 60,
              onPressed: () {
                if (welcomeNftEntity.id != 0) {
                  getIt<NftCubit>().onGetConsumeWelcomeNft(
                      welcomeNftId: welcomeNftEntity.id);
                } else {
                  snackBarService.showSnackbar(
                      message: "No Free NFT Available",
                      duration: const Duration(seconds: 2));
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
