import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/widgets/my_membership_widget.dart';
import 'package:mobile/features/my/presentation/widgets/my_points_widget.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MemberDetailsView extends StatelessWidget {
  const MemberDetailsView(
      {super.key,
      required this.user,
      required this.selectedNftTokensList,
      required this.nftPointsList,
      required this.isMembersLoading,
      required this.isPointsLoading});

  final UserProfileEntity user;
  final List<SelectedNFTEntity> selectedNftTokensList;
  final List<NftPointsEntity> nftPointsList;
  final bool isMembersLoading;
  final bool isPointsLoading;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BaseScaffold(
        title: '멤버 상세',
        isCenterTitle: true,
        onBack: () {
          Navigator.pop(context);
        },
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildTitleRow(context, user),
            const SizedBox(height: 24),
            _buildTabView(context),
            const SizedBox(height: 15),
            SizedBox(
              height: 800,
              child: TabBarView(
                children: [
                  MyMembershipWidget(
                    isLoading: isMembersLoading,
                    selectedNftTokensList: selectedNftTokensList,
                  ),
                  MyPointsWidget(
                    isLoading: isPointsLoading,
                    nftPointsList: nftPointsList,
                    isOwner: false,
                    title: '획득 포인트',
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, UserProfileEntity member) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: CustomImageView(
              url: member.pfpImageUrl,
              fit: BoxFit.cover,
              width: 68,
              height: 68,
              placeHolder: "assets/images/launcher-icon.png",
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nickName,
                    style: fontCompactLgBold(),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 226,
                    child: Text(
                      member.introduction,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontCompactSm(color: fore2),
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

  /// Section Widget
  Widget _buildTabView(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: deviceWidth,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: whiteWithOpacityOne,
                width: 0.7,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: TabBar(
            isScrollable: true,
            labelColor: white,
            labelStyle: fontCompactMdBold(),
            unselectedLabelColor: white.withOpacity(0.5),
            dividerColor: Colors.transparent,
            unselectedLabelStyle: fontCompactMdBold(color: fore2),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: white,
            indicatorWeight: 1,
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: white, width: 0.5),
              ),
            ),
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(
                child: SizedBox(
                  width: deviceWidth * 0.45,
                  child: Center(
                    child: Text(
                      LocaleKeys.membership.tr(),
                    ),
                  ),
                ),
              ),
              Tab(
                child: SizedBox(
                  width: deviceWidth * 0.45,
                  child: Center(
                    child: Text(
                      LocaleKeys.points.tr(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
