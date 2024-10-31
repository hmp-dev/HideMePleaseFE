import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/nft_video_thumbnail.dart';
import 'package:mobile/features/nft/domain/entities/nft_usage_history_entity.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyNftBenefitsUsageHistoryDetailScreen extends StatefulWidget {
  const MyNftBenefitsUsageHistoryDetailScreen(
      {super.key, required this.nftEntity});

  final SelectedNFTEntity nftEntity;

  static push(BuildContext context, SelectedNFTEntity nftEntity) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MyNftBenefitsUsageHistoryDetailScreen(nftEntity: nftEntity),
      ),
    );
  }

  @override
  State<MyNftBenefitsUsageHistoryDetailScreen> createState() =>
      _MyNftBenefitsUsageHistoryDetailScreenState();
}

class _MyNftBenefitsUsageHistoryDetailScreenState
    extends State<MyNftBenefitsUsageHistoryDetailScreen> {
  bool isReverseShownNftUsageHistoryEntityItems = false;

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
                _buildTitleRow(
                  context: context,
                  nftImageUrl: widget.nftEntity.imageUrl,
                  nftVideoUrl: widget.nftEntity.videoUrl,
                  nftName: widget.nftEntity.name,
                  nftChain: widget.nftEntity.chain,
                  nftUsedCount: "${state.nftUsageHistoryEntity.count}",
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.usageHistory.tr(),
                        style: fontTitle07Medium(),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isReverseShownNftUsageHistoryEntityItems =
                                !isReverseShownNftUsageHistoryEntityItems;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              isReverseShownNftUsageHistoryEntityItems
                                  ? LocaleKeys.oldest.tr()
                                  : LocaleKeys.latest.tr(),
                              style: fontCompactSm(color: fore2),
                            ),
                            CustomImageView(
                              svgPath: 'assets/icons/ic_angle_arrow_down.svg',
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
                  padding: const EdgeInsets.only(
                      left: 20, top: 30, right: 20, bottom: 30),
                  child: ListView.builder(
                    reverse: isReverseShownNftUsageHistoryEntityItems,
                    shrinkWrap: true,
                    itemCount: state.nftUsageHistoryEntity.items.length,
                    itemBuilder: (context, index) {
                      return UsageHistoryDetailItem(
                        item: state.nftUsageHistoryEntity.items[index],
                      );
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

  Widget _buildTitleRow({
    required BuildContext context,
    required String nftImageUrl,
    required String nftVideoUrl,
    required String nftName,
    required String nftChain,
    required String nftUsedCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
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
              nftVideoUrl != ""
                  ? NftVideoThumbnailFromUrl(
                      imageWidth: 48,
                      imgHeight: 64,
                      videoUrl: nftVideoUrl,
                    )
                  : nftImageUrl == ""
                      ? CustomImageView(
                          imagePath: "assets/images/place_holder_card.png",
                          width: 48,
                          height: 64,
                          radius: BorderRadius.circular(2),
                          fit: BoxFit.cover,
                        )
                      : CustomImageView(
                          url: nftImageUrl,
                          width: 48,
                          height: 64,
                          radius: BorderRadius.circular(2),
                          fit: BoxFit.cover,
                        ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, top: 4),
                child: DefaultImage(
                  path: ChainType.fromString(nftChain).chainLogo,
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
                    nftName,
                    style: fontCompactMd(color: fore2),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 226,
                    child: Text(
                      "${LocaleKeys.total.tr()} $nftUsedCount${LocaleKeys.users.tr()}",
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

class UsageHistoryDetailItem extends StatelessWidget {
  const UsageHistoryDetailItem({
    super.key,
    required this.item,
  });

  final UsageHistoryItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                  item.benefitDescription,
                  style: fontCompactSm(color: fore3),
                ),
              ],
            ),
          ],
        ),
        const Divider(
          color: fore5,
          thickness: 1,
          height: 30,
        )
      ],
    );
  }
}
