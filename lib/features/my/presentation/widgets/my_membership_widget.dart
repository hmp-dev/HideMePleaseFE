import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/updated_at_time_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/screens/my_membership_nft_details.dart';
import 'package:mobile/features/my/presentation/widgets/members_item_widget.dart';

class MyMembershipWidget extends StatefulWidget {
  const MyMembershipWidget({super.key});

  @override
  State<MyMembershipWidget> createState() => _MyMembershipWidgetState();
}

class _MyMembershipWidgetState extends State<MyMembershipWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "총 ${state.selectedNftTokensList.length}개",
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.selectedNftTokensList.length,
                itemBuilder: (context, index) {
                  return MembersItemWidget(
                    isLastItem: index == 3,
                    nft: state.selectedNftTokensList[index],
                    onTap: () {
                      // call the Benefits for this NFT
                      getIt<NftCubit>().onGetNftBenefits(
                          tokenAddress: state
                              .selectedNftTokensList[index].tokenAddress
                              .trim());
                      // call the NetworkInfo Api for this NFT
                      getIt<NftCubit>().onGetNftNetworkInfo(
                          tokenAddress: state
                              .selectedNftTokensList[index].tokenAddress
                              .trim());
                      //Navigate to the NFT Details Screen
                      MyMembershipNftDetailScreen.push(
                          context, state.selectedNftTokensList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
