import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/screens/nft_benefits_usage_history_detail.dart';
import 'package:mobile/features/my/presentation/widgets/benefits_item_widget.dart';
import 'package:mobile/features/my/presentation/widgets/nft_network_info_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyMembershipNftDetailScreen extends StatefulWidget {
  const MyMembershipNftDetailScreen({super.key, required this.nftEntity});

  final SelectedNFTEntity nftEntity;

  static push(BuildContext context, SelectedNFTEntity nftEntity) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyMembershipNftDetailScreen(nftEntity: nftEntity),
      ),
    );
  }

  @override
  State<MyMembershipNftDetailScreen> createState() =>
      _MyMembershipNftDetailScreenState();
}

class _MyMembershipNftDetailScreenState
    extends State<MyMembershipNftDetailScreen> with TickerProviderStateMixin {
  late TabController tabViewController;

  @override
  void initState() {
    super.initState();
    tabViewController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.myMembershipDetails.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: SafeArea(
        child: SingleChildScrollView(
            child: BlocConsumer<NftCubit, NftState>(
          bloc: getIt<NftCubit>(),
          listenWhen: (previous, current) =>
              previous.nftUsageHistoryEntity != current.nftUsageHistoryEntity,
          listener: (context, state) {},
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTitleRow(context, widget.nftEntity),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.memberShipBenefits.tr(),
                        style: fontTitle07Medium(),
                      ),
                      GestureDetector(
                        onTap: () {
                          // call NFT Usage History API
                          getIt<NftCubit>().onGetNftUsageHistory(
                              tokenAddress: widget.nftEntity.tokenAddress);

                          MyNftBenefitsUsageHistoryDetailScreen.push(
                              context, widget.nftEntity);
                        },
                        child: Row(
                          children: [
                            Text(
                              LocaleKeys.usageHistory.tr(),
                              style: fontCompactSm(color: fore2),
                            ),
                            CustomImageView(
                              svgPath: 'assets/icons/ic_angle_arrow_right.svg',
                              color: fore2,
                              width: 16,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.nftBenefitList.take(2).length,
                    itemBuilder: (context, index) {
                      return BenefitItemWidget(
                          nftBenefitEntity: state.nftBenefitList[index]);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.seeMore.tr(),
                      style: fontCompactSm(color: fore2),
                    ),
                    CustomImageView(
                      svgPath: 'assets/icons/ic_angle_arrow_down.svg',
                      color: fore2,
                      width: 16,
                    )
                  ],
                ),
                const VerticalSpace(20),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    color: bgNega5,
                    height: 8,
                    thickness: 8,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: Text(
                      LocaleKeys.moreInformation.tr(),
                      style: fontTitle07Medium(color: fore2),
                    ),
                  ),
                ),
                const NftNetworkInfoWidget(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, bottom: 30, top: 50),
                  child: HMPCustomButton(
                    text: LocaleKeys.enterTheChatRoom.tr(),
                    onPressed: () {},
                  ),
                ),
              ],
            );
          },
        )),
      ),
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    SelectedNFTEntity nftPointsEntity,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            nftPointsEntity.imageUrl == ""
                ? CustomImageView(
                    imagePath: "assets/images/place_holder_card.png",
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    radius: BorderRadius.circular(4),
                    fit: BoxFit.cover,
                  )
                : CustomImageView(
                    url: nftPointsEntity.imageUrl,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    radius: BorderRadius.circular(4),
                    fit: BoxFit.cover,
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20),
              child: DefaultImage(
                path: "assets/chain-logos/ethereum_chain.svg",
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            nftPointsEntity.name,
            style: fontTitle03Bold(),
          ),
        ),
      ],
    );
  }
}
