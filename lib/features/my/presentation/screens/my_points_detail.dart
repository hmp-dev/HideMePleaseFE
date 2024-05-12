import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/usage_type_enum.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/common/domain/entities/nft_usage_history_entity.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/my/presentation/widgets/rounded_select_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyPointsDetailScreen extends StatefulWidget {
  const MyPointsDetailScreen({super.key, required this.nftPointsEntity});

  final NftPointsEntity nftPointsEntity;

  static push(BuildContext context, NftPointsEntity nftPointsEntity) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyPointsDetailScreen(nftPointsEntity: nftPointsEntity),
      ),
    );
  }

  @override
  State<MyPointsDetailScreen> createState() => _MyPointsDetailScreenState();
}

class _MyPointsDetailScreenState extends State<MyPointsDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.myPointDetails.tr(),
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
                _buildTitleRow(context, widget.nftPointsEntity),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      RoundedSelectButton(
                        title: LocaleKeys.entire.tr(),
                        isSelected: true,
                        onTap: () {
                          getIt<NftCubit>().onGetNftUsageHistory(
                              tokenAddress:
                                  widget.nftPointsEntity.tokenAddress);
                        },
                      ),
                      RoundedSelectButton(
                        title: LocaleKeys.spaceVisit.tr(),
                        isSelected: false,
                        onTap: () {
                          getIt<NftCubit>().onGetNftUsageHistory(
                            tokenAddress: widget.nftPointsEntity.tokenAddress,
                            type: UsageType.SPACE_VISIT.name,
                          );
                        },
                      ),
                      RoundedSelectButton(
                        title: LocaleKeys.community.tr(),
                        isSelected: false,
                        onTap: () {
                          getIt<NftCubit>().onGetNftUsageHistory(
                            tokenAddress: widget.nftPointsEntity.tokenAddress,
                            type: UsageType.COMMUNITY.name,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.nftUsageHistoryEntity.items.length,
                    itemBuilder: (context, index) {
                      // get a value true if the index is the last one in state.nftPointsList

                      return PointsUsageDetailItem(
                          item: state.nftUsageHistoryEntity.items[index]);
                    },
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
    NftPointsEntity nftPointsEntity,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: fore5,
        border: const Border(
          bottom: BorderSide(
            color: fore5,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              nftPointsEntity.imageUrl == ""
                  ? CustomImageView(
                      imagePath: "assets/images/place_holder_card.png",
                      width: 48,
                      height: 64,
                      radius: BorderRadius.circular(2),
                      fit: BoxFit.cover,
                    )
                  : CustomImageView(
                      url: nftPointsEntity.imageUrl,
                      width: 48,
                      height: 64,
                      radius: BorderRadius.circular(2),
                      fit: BoxFit.cover,
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, top: 4),
                child: DefaultImage(
                  path: "assets/chain-logos/ethereum_chain.svg",
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nftPointsEntity.name,
                    style: fontCompactMd(color: fore2),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 226,
                    child: Text(
                      "${nftPointsEntity.totalPoints}P ${LocaleKeys.earned.tr()}",
                      // introduction Text
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontTitle05Medium(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PointsUsageDetailItem extends StatelessWidget {
  const PointsUsageDetailItem({
    super.key,
    required this.item,
  });

  final UsageHistoryItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Text(
            formatDateGetMonthYear(item.createdAt),
            style: fontCompactSm(color: fore3),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.spaceName,
              style: fontCompactLgMedium(),
            ),
            Text(
              getTypeString(item.type),
              style: fontCompactSm(color: fore3),
            ),
          ],
        ),
        const Spacer(),
        Text(
          "+${item.pointsEarned}P",
          style: fontCompactMdMedium(color: hmpBlue),
        ),
      ],
    );
  }

  String getTypeString(String input) {
    if (input == "SPACE_VISIT") {
      return "Space Visit";
    } else if (input == "COMMUNITY") {
      return "Community";
    } else {
      return "Unknown"; // Handle other cases if necessary
    }
  }
}
