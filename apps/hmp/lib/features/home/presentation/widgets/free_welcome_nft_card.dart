import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_rewards_bottom_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_top_title_widget.dart';
import 'package:mobile/features/home/presentation/widgets/nft_card_widget_parent.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';

/// A widget that displays a welcome NFT card.
///
/// This widget is used to display a welcome NFT card with its image, name, and rewards.
/// It also includes an optional free graphic overlay.
class FreeWelcomeNftCard extends StatefulWidget {
  /// Creates a [FreeWelcomeNftCard].
  ///
  /// The [enableFreeGraphic] parameter determines whether the free graphic overlay should be shown.
  /// The [welcomeNftEntity] parameter is the entity containing the details of the welcome NFT.
  const FreeWelcomeNftCard({
    super.key,
    this.enableFreeGraphic = true,
    required this.welcomeNftEntity,
    required this.onTapClaimButton,
  });

  /// Determines whether the free graphic overlay should be shown.
  final bool enableFreeGraphic;

  /// The entity containing the details of the welcome NFT.
  final WelcomeNftEntity welcomeNftEntity;
  final VoidCallback onTapClaimButton;

  @override
  State<FreeWelcomeNftCard> createState() => _FreeWelcomeNftCardState();
}

class _FreeWelcomeNftCardState extends State<FreeWelcomeNftCard> {
  // 처리 중인지 여부를 추적하는 상태 변수
  bool _isProcessing = false;

  // 안전한 버튼 클릭 처리
  void _handleClaimButtonTap() {
    if (!_isProcessing) {
      setState(() {
        _isProcessing = true;
      });

      // 원래 콜백 실행
      widget.onTapClaimButton();
      
      // 충분한 시간(예: 3초) 후에 상태 초기화
      // 실제 완료 상태를 감지하는 방법이 있다면 그것을 사용하는 것이 더 좋습니다
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container for the NFT card widget parent
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: NFTCardWidgetParent(
            imagePath: widget.welcomeNftEntity.image,
            videoUrl: '',
            topWidget: NftCardTopTitleWidget(
              title: widget.welcomeNftEntity.name,
              chain: (widget.welcomeNftEntity.contractType == "AVAX") ? "AVALANCHE" : "KLAYTN",
            ),
            bottomWidget: NftCardRewardsBottomWidget(
              welcomeNftEntity: widget.welcomeNftEntity,
              onTapClaimButton: _handleClaimButtonTap,
              isProcessing: _isProcessing, // 처리 중 상태 전달
            ),
            index: 0,
          ),
        ),
        // Optional free graphic overlay
        if (widget.enableFreeGraphic)
          Positioned(
            right: 0,
            top: 0,
            child: CustomImageView(
              imagePath: "assets/images/free-graphic-text.png",
            ),
          ),
      ],
    );
  }
}
