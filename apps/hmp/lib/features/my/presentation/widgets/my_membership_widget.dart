import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/empty_data_widget.dart';
import 'package:mobile/features/common/presentation/widgets/updated_at_time_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/screens/my_membership_nft_details.dart';
import 'package:mobile/features/my/presentation/widgets/members_item_widget.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_benefits_cubit.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyMembershipWidget extends StatelessWidget {
  const MyMembershipWidget({
    super.key,
    required this.selectedNftTokensList,
    this.isLoading = false,
  });
  final List<SelectedNFTEntity> selectedNftTokensList;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Column(
            children: [
              Center(
                child: Lottie.asset(
                  'assets/lottie/loader.json',
                ),
              ),
            ],
          )
        : (selectedNftTokensList.isEmpty)
            ? const Column(
                children: [
                  Center(child: EmptyDataWidget()),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${LocaleKeys.total.tr()} ${selectedNftTokensList.length}${LocaleKeys.item.tr()}",
                          style: fontTitle07Medium(),
                        ),
                        UpdateAtTimeWidget(
                          updatedAt: DateTime.now(),
                          isShowIcon: false,
                        )
                      ],
                    ),
                  ),
                  const VerticalSpace(20),
                  Container(
                    height: MediaQuery.of(context).size.height - 325,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: selectedNftTokensList.length,
                      itemBuilder: (context, index) {
                        return MembersItemWidget(
                          isLastItem: index == 3,
                          nft: selectedNftTokensList[index],
                          onTap: () {
                            // call the Benefits for this NFT
                            getIt<NftBenefitsCubit>().onGetNftBenefits(
                                tokenAddress: selectedNftTokensList[index]
                                    .tokenAddress
                                    .trim());
                            // call the NetworkInfo Api for this NFT
                            getIt<NftCubit>().onGetNftNetworkInfo(
                                tokenAddress: selectedNftTokensList[index]
                                    .tokenAddress
                                    .trim());
                            //Navigate to the NFT Details Screen
                            MyMembershipNftDetailScreen.push(
                                context, selectedNftTokensList[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
  }
}
