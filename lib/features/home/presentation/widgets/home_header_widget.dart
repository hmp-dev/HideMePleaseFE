import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/linked_wallet_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/wallets/presentation/screens/connected_wallets_list_view.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
    required this.connectedWallet,
  });

  final List<ConnectedWalletEntity> connectedWallet;

  @override
  Widget build(BuildContext context) {
    final userProfile = getIt<ProfileCubit>().state.userProfileEntity;
    return GestureDetector(
      onTap: () {
        ConnectedWalletsListScreen.push(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: userProfile.pfpImageUrl.isNotEmpty
                  ? CustomImageView(
                      url: userProfile.pfpImageUrl,
                      fit: BoxFit.fill,
                      width: 54,
                      height: 54,
                    )
                  : DefaultImage(
                      path: "assets/images/profile_img.png",
                      width: 54,
                      height: 54,
                    ),
            ),
            const HorizontalSpace(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connectedWallet.isNotEmpty
                        ? formatWalletAddress(connectedWallet[0].publicAddress)
                        : "",
                    textAlign: TextAlign.center,
                    style: fontSB(18, lineHeight: 1.4),
                  ),
                  const VerticalSpace(10),
                  LinkedWalletButton(
                    titleText: userProfile.nickName,
                    count: connectedWallet.length,
                    onTap: () {
                      ConnectedWalletsListScreen.push(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                // getIt<HomeCubit>()
                //     .onUpdateHomeViewType(HomeViewType.beforeWalletConnected);

                // getIt<ProfileCubit>().onUpdateUserProfile(
                //     UpdateProfileRequestDto(nickName: "Dave John"));

                // getIt<NftCubit>().onGetWelcomeNft();

                //getIt<NftCubit>().onGetUserSelectedNfts();

                // getIt<NftCubit>().onGetConsumeWelcomeNft(welcomeNftId: 2);
              },
              child: DefaultImage(
                path: "assets/icons/ic_notification.svg",
                width: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
