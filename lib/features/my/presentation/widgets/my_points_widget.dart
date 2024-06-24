import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/page_cubit.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/info_text_tool_tip_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/screens/my_points_detail.dart';
import 'package:mobile/features/my/presentation/widgets/points_info_box_widget.dart';
import 'package:mobile/features/my/presentation/widgets/points_item_widget.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyPointsWidget extends StatefulWidget {
  const MyPointsWidget({
    super.key,
    required this.nftPointsList,
    required this.isOwner,
    this.isLoading = false,
    required this.title,
  });
  final List<NftPointsEntity> nftPointsList;
  final bool isOwner;
  final bool isLoading;
  final String title;

  @override
  State<MyPointsWidget> createState() => _MyPointsWidgetState();
}

class _MyPointsWidgetState extends State<MyPointsWidget> {
  bool _isShowToolTip = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.isLoading)
          Column(
            children: [
              Center(
                child: Lottie.asset(
                  'assets/lottie/loader.json',
                ),
              ),
            ],
          )
        else if (widget.nftPointsList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(widget.title, style: fontTitle07Medium()),
              ],
            ),
          )
        else
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(widget.title, style: fontTitle07Medium()),
                      const HorizontalSpace(10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isShowToolTip = !_isShowToolTip;
                          });
                        },
                        child: DefaultImage(
                          path: "assets/icons/ic_info.svg",
                          width: 20,
                          height: 20,
                          color: white,
                        ),
                      )
                    ],
                  ),
                ),
                const VerticalSpace(20),
                Container(
                  height: widget.nftPointsList.length * 120,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.nftPointsList.length,
                    itemBuilder: (context, index) {
                      // get a value true if the index is the last one in widget.nftPointsList

                      return Container(
                        height: 120,
                        color: Colors.transparent,
                        child: PointsItemWidget(
                          nftPointsEntity: widget.nftPointsList[index],
                          isLastItem: index == widget.nftPointsList.length - 1,
                          onTap: () {
                            //
                            getIt<NftCubit>().onGetNftUsageHistory(
                                tokenAddress:
                                    widget.nftPointsList[index].tokenAddress);

                            MyPointsDetailScreen.push(
                                context, widget.nftPointsList[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (widget.isOwner)
                  const Divider(
                    color: bgNega5,
                    height: 8,
                    thickness: 8,
                  ),
                if (widget.isOwner)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.pointsAccumulationMission.tr(),
                          style: fontTitle07Medium(),
                        ),
                        const VerticalSpace(20),
                        PointsInfoBoxWidget(
                          subTitle: LocaleKeys.spaceVisit.tr(),
                          title: LocaleKeys
                              .whenUsingBenefitsAfterVisitingAffiliateSpace
                              .tr(),
                          buttonTitle: LocaleKeys.useTheBenefitAndGet1P.tr(),
                          onPressed: () {
                            // update device Location
                            getIt<EnableLocationCubit>().onAskDeviceLocation();
                            //Navigate Back and go to Space Screen
                            Navigator.pop(context);
                            getIt<PageCubit>().changePage(
                                MenuType.space.menuIndex, MenuType.space);
                            // fetch Space Related Data
                            // init Cubit function to get all space view data
                            final locationState =
                                getIt<EnableLocationCubit>().state;
                            getIt<SpaceCubit>().onFetchAllSpaceViewData(
                              latitude: locationState.latitude,
                              longitude: locationState.longitude,
                            );
                          },
                        ),
                        const VerticalSpace(20),
                        PointsInfoBoxWidget(
                          subTitle: LocaleKeys.communityInvolvement.tr(),
                          title: LocaleKeys
                              .whenParticipatingInConversationsInTheCommunity30Times
                              .tr(),
                          buttonTitle: LocaleKeys.talkAnd1P.tr(),
                          onPressed: () {},
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        if (_isShowToolTip)
          Positioned(
            top: 50,
            left: 100,
            child: InfoTextToolTipWidget(
              title:
                  "획득한 포인트는 혜택을 이용하고, 대화에 참여한 커뮤니티에 자동으로 기여됩니다. 포인트가 모이면, 멤버십의 혜택을 업그레이드 하는데 활용됩니다.",
              onTap: () {
                setState(() {
                  _isShowToolTip = false;
                });
              },
            ),
          )
      ],
    );
  }
}
