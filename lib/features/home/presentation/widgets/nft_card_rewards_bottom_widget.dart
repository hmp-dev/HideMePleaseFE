import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/common/presentation/widgets/web_view_screen.dart';
import 'package:mobile/features/home/presentation/widgets/glassmorphic_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:stacked_services/stacked_services.dart';

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
          WebViewScreen.push(
            context: context,
            title: "선착순 홀더",
            url: state.consumeWelcomeNftUrl,
          );
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
                      style: fontSB(18),
                    ),
                    Text('/${welcomeNftEntity.totalCount}', style: fontR(18))
                  ],
                )
              ],
            ),
            const VerticalSpace(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Floor Price",
                  style: fontSB(18),
                ),
                Text(
                  LocaleKeys.free.tr(),
                  style: fontSB(18),
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
                LocaleKeys.learnMore.tr(),
                style: fontM(16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
