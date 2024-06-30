import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/linked_wallet_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/my_screen.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/wallets/presentation/screens/connected_wallets_list_view.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
    required this.connectedWallet,
  });

  final List<ConnectedWalletEntity> connectedWallet;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: getIt<ProfileCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        final userProfile = state.userProfileEntity;
        return GestureDetector(
          onTap: () {
            // call to get NFT Points
            getIt<NftCubit>().onGetNftPoints();
            // Navigate to Settings Screen
            MyScreen.push(context);
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
                      : CustomImageView(
                          imagePath: "assets/images/profile_img.png",
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
                        userProfile.nickName,
                        textAlign: TextAlign.center,
                        style: fontCompactLgBold(),
                      ),
                      const VerticalSpace(10),
                      LinkedWalletButton(
                        titleText: LocaleKeys.linkedWallet.tr(),
                        count: connectedWallet.length,
                        onTap: () {
                          ConnectedWalletsListScreen.show(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const AlarmsIconButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}
