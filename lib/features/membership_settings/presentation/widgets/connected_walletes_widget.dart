import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/updated_at_time_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/plus_icon_round_button.dart';

class ConnectedWalletWidget extends StatelessWidget {
  const ConnectedWalletWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //TODO show only wallets which are connected
                          CustomImageView(
                            svgPath: "assets/images/wallet.svg",
                            width: 28,
                            height: 28,
                          ),
                          const HorizontalSpace(8),
                          CustomImageView(
                            imagePath: "assets/images/klip-wallet.png",
                            width: 28,
                            height: 28,
                          ),
                          const HorizontalSpace(8),
                          CustomImageView(
                            svgPath: "assets/images/phantom-wallet.svg",
                            width: 28,
                            height: 28,
                          ),
                          const HorizontalSpace(8),
                          CustomImageView(
                            svgPath: "assets/images/wallet-connect-wallet.svg",
                            width: 28,
                            height: 28,
                          ),
                        ],
                      ),
                      PlusIconRoundButton(
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalSpace(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "대표 NFT 선택",
                    style: fontTitle07Medium(),
                  ),
                  // create separate widget for this

                  UpdateAtTimeWidget(updatedAt: state.collectionFetchTime),
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
