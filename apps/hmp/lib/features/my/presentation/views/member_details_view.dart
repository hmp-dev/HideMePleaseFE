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

/// A view that displays the details of a member, including their profile picture,
/// nickname, introduction, membership, and points.
class MemberDetailsView extends StatelessWidget {
  /// Creates a [MemberDetailsView] widget with the given parameters.
  ///
  /// The [user] parameter is the user profile entity of the member.
  /// The [selectedNftTokensList] parameter is a list of selected NFT tokens.
  /// The [nftPointsList] parameter is a list of NFT points.
  /// The [isMembersLoading] parameter indicates whether the membership is loading.
  /// The [isPointsLoading] parameter indicates whether the points are loading.
  const MemberDetailsView(
      {super.key,
      required this.user,
      required this.selectedNftTokensList,
      required this.nftPointsList,
      required this.isMembersLoading,
      required this.isPointsLoading});

  /// The user profile entity of the member.
  final UserProfileEntity user;

  /// A list of selected NFT tokens.
  final List<SelectedNFTEntity> selectedNftTokensList;

  /// A list of NFT points.
  final List<NftPointsEntity> nftPointsList;

  /// Indicates whether the membership is loading.
  final bool isMembersLoading;

  /// Indicates whether the points are loading.
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
          ),
        ),
      ),
    );
  }

  /// A widget that displays the member's information, including their profile picture, nickname, and introduction.
  ///
  /// The [context] parameter is the build context of the widget.
  /// The [member] parameter is the user profile entity of the member.
  ///
  /// Returns a [Widget] that displays the member's information.
  Widget _buildTitleRow(BuildContext context, UserProfileEntity member) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile picture of the member
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
          // Information about the member, including their nickname and introduction
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nickname of the member
                  Text(
                    member.nickName,
                    style: fontCompactLgBold(),
                  ),
                  const SizedBox(height: 7),
                  // Introduction of the member, with a maximum of 2 lines and an ellipsis if it exceeds that limit
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
    ); // Padding
  }

  /// Section Widget
  ///
  /// This widget builds a tab view that displays tabs for membership and points.
  /// It uses a [Stack] widget to overlay a border on top of a [Container] that represents the tab bar.
  /// The [TabBar] widget is used to display the tabs, and the [isScrollable] property is set to true
  /// to allow horizontal scrolling if there are more tabs than the available width.
  /// The [labelColor] property is set to white to specify the color of the selected tab label,
  /// and the [unselectedLabelColor] property is set to white with opacity 0.5 to specify the color of
  /// the unselected tab labels.
  /// The [indicatorColor] property is set to white to specify the color of the tab indicator,
  /// and the [indicatorWeight] property is set to 1 to specify the thickness of the tab indicator.
  /// The [indicator] property is set to a [BoxDecoration] with a bottom border of color white and width 0.5
  /// to specify the shape of the tab indicator.
  Widget _buildTabView(BuildContext context) {
    // Get the device width
    var deviceWidth = MediaQuery.of(context).size.width;

    // Build the tab bar
    return Stack(
      children: [
        // Container for the tab bar
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
            // Configure the tabs
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
