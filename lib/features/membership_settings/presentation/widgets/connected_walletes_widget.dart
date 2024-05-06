import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

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
                          CustomImageView(
                            svgPath: "assets/images/wallet.svg",
                            width: 24,
                            height: 24,
                          ),
                          const HorizontalSpace(7),
                          CustomImageView(
                            imagePath: "assets/images/klip-wallet.png",
                            width: 24,
                            height: 24,
                          ),
                          const HorizontalSpace(7),
                          CustomImageView(
                            svgPath: "assets/images/phantom-wallet.svg",
                            width: 24,
                            height: 24,
                          ),
                          const HorizontalSpace(7),
                          CustomImageView(
                            svgPath: "assets/images/wallet-connect-wallet.svg",
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: bgNega4,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CustomImageView(
                            svgPath: "assets/images/ic_plus.svg",
                          ),
                        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${formatDate(state.collectionFetchTime)} 기준",
                        style: fontCompactSm(color: fore3),
                      ),
                      const HorizontalSpace(3),
                      DefaultImage(
                        path: "assets/icons/ic_arrow_clockwise.svg",
                        color: white,
                        height: 16,
                      )
                    ],
                  ),
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
